unit AutoHandel.StateMachine;

{
  AutoHandel - Generic State Machine
  ====================================
  Wiederverwendbare State Machine für alle Business Cases.
  Jeder State implementiert IState<T>.
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  AutoHandel.Interfaces;

type
  // -------------------------------------------------------
  // Abstrakte State-Basisklasse
  // -------------------------------------------------------
  TBaseState<T: class> = class abstract(TInterfacedObject, IState<T>)
  private
    FStateCode  : TStateCode;
    FStateName  : string;
    FIsFinal    : Boolean;
    FAllowedTransitions: TList<TStateCode>;
  protected
    function  GetStateCode: TStateCode;
    function  GetStateName: string;
    function  IsFinalState: Boolean;
    function  CanTransitionTo(const ATargetState: TStateCode): Boolean;
    procedure AddAllowedTransition(const ATargetState: TStateCode);
  public
    constructor Create(const ACode: TStateCode; const AName: string; AIsFinal: Boolean = False);
    destructor Destroy; override;
    procedure OnEnter(AContext: T); virtual;
    procedure OnExit(AContext: T); virtual;
    procedure Execute(AContext: T); virtual; abstract;
    function  Validate(AContext: T): TValidationResult; virtual;
  end;

  // -------------------------------------------------------
  // State Machine Implementation
  // -------------------------------------------------------
  TStateMachine<T: class> = class(TInterfacedObject, IStateMachine<T>)
  private
    FStates        : TDictionary<TStateCode, IState<T>>;
    FCurrentState  : IState<T>;
    FHistory       : TList<TStateCode>;
    FOnStateChanged: TStateChangedEvent;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterState(AState: IState<T>);
    procedure SetInitialState(const AStateCode: TStateCode);
    function  GetCurrentState: IState<T>;
    function  GetCurrentStateCode: TStateCode;
    function  CanTransitionTo(const ATargetState: TStateCode): Boolean;
    procedure TransitionTo(const ATargetState: TStateCode; AContext: T);
    function  GetStateHistory: TArray<TStateCode>;
    property  OnStateChanged: TStateChangedEvent read FOnStateChanged write FOnStateChanged;
  end;

implementation

{ TBaseState<T> }

constructor TBaseState<T>.Create(const ACode: TStateCode; const AName: string; AIsFinal: Boolean);
begin
  inherited Create;
  FStateCode           := ACode;
  FStateName           := AName;
  FIsFinal             := AIsFinal;
  FAllowedTransitions  := TList<TStateCode>.Create;
end;

destructor TBaseState<T>.Destroy;
begin
  FAllowedTransitions.Free;
  inherited;
end;

function TBaseState<T>.GetStateCode: TStateCode; begin Result := FStateCode; end;
function TBaseState<T>.GetStateName: string;     begin Result := FStateName; end;
function TBaseState<T>.IsFinalState: Boolean;    begin Result := FIsFinal; end;

procedure TBaseState<T>.AddAllowedTransition(const ATargetState: TStateCode);
begin
  if not FAllowedTransitions.Contains(ATargetState) then
    FAllowedTransitions.Add(ATargetState);
end;

function TBaseState<T>.CanTransitionTo(const ATargetState: TStateCode): Boolean;
begin
  Result := FAllowedTransitions.Contains(ATargetState);
end;

procedure TBaseState<T>.OnEnter(AContext: T); begin end;
procedure TBaseState<T>.OnExit(AContext: T);  begin end;

function TBaseState<T>.Validate(AContext: T): TValidationResult;
begin
  Result := TValidationResult.OK;
end;

{ TStateMachine<T> }

constructor TStateMachine<T>.Create;
begin
  inherited;
  FStates   := TDictionary<TStateCode, IState<T>>.Create;
  FHistory  := TList<TStateCode>.Create;
end;

destructor TStateMachine<T>.Destroy;
begin
  FHistory.Free;
  FStates.Free;
  inherited;
end;

procedure TStateMachine<T>.RegisterState(AState: IState<T>);
begin
  FStates.AddOrSetValue(AState.GetStateCode, AState);
end;

procedure TStateMachine<T>.SetInitialState(const AStateCode: TStateCode);
begin
  if not FStates.ContainsKey(AStateCode) then
    raise TStateException.CreateFmt('State "%s" nicht registriert.', [AStateCode]);
  FCurrentState := FStates[AStateCode];
  FHistory.Add(AStateCode);
end;

function TStateMachine<T>.GetCurrentState: IState<T>;  begin Result := FCurrentState; end;
function TStateMachine<T>.GetCurrentStateCode: TStateCode;
begin
  if Assigned(FCurrentState) then
    Result := FCurrentState.GetStateCode
  else
    Result := '';
end;

function TStateMachine<T>.CanTransitionTo(const ATargetState: TStateCode): Boolean;
begin
  Result := Assigned(FCurrentState)
    and FStates.ContainsKey(ATargetState)
    and FCurrentState.CanTransitionTo(ATargetState);
end;

procedure TStateMachine<T>.TransitionTo(const ATargetState: TStateCode; AContext: T);
var
  OldCode  : TStateCode;
  NewState : IState<T>;
begin
  if not CanTransitionTo(ATargetState) then
    raise TStateException.CreateFmt(
      'Übergang von "%s" nach "%s" nicht erlaubt.',
      [GetCurrentStateCode, ATargetState]);

  OldCode  := GetCurrentStateCode;
  NewState := FStates[ATargetState];

  FCurrentState.OnExit(AContext);
  FCurrentState := NewState;
  FCurrentState.OnEnter(AContext);
  FHistory.Add(ATargetState);

  if Assigned(FOnStateChanged) then
    FOnStateChanged(OldCode, ATargetState);
end;

function TStateMachine<T>.GetStateHistory: TArray<TStateCode>;
begin
  Result := FHistory.ToArray;
end;

end.
