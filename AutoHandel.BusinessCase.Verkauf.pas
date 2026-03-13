unit AutoHandel.BusinessCase.Verkauf;

{
  AutoHandel - Business Case: Autoverkauf
  =========================================
  State Machine mit allen Verkaufs-Zuständen.
  Jeder State ist eine eigene Klasse die IState<TVerkauf> implementiert.

  Workflow:
  INTERESSENT → PROBEFAHRT → ANGEBOT → VERIFIKATION
               → KAUFVERTRAG → ZAHLUNG → ÜBERGABE → ABGESCHLOSSEN
               → ABGEBROCHEN (von jedem State)
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  AutoHandel.Interfaces, AutoHandel.Models, AutoHandel.StateMachine;

const
  // State Codes Verkauf
  SC_V_INTERESSENT   = 'INTERESSENT';
  SC_V_PROBEFAHRT    = 'PROBEFAHRT';
  SC_V_ANGEBOT       = 'ANGEBOT';
  SC_V_VERIFIKATION  = 'VERIFIKATION';
  SC_V_KAUFVERTRAG   = 'KAUFVERTRAG';
  SC_V_ZAHLUNG       = 'ZAHLUNG';
  SC_V_ÜBERGABE      = 'ÜBERGABE';
  SC_V_ABGESCHLOSSEN = 'ABGESCHLOSSEN';
  SC_V_ABGEBROCHEN   = 'ABGEBROCHEN';

type
  // -------------------------------------------------------
  // State: Interessent
  // -------------------------------------------------------
  TVerkaufState_Interessent = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
    function  Validate(AContext: TVerkauf): TValidationResult; override;
  end;

  // -------------------------------------------------------
  // State: Probefahrt
  // -------------------------------------------------------
  TVerkaufState_Probefahrt = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
    function  Validate(AContext: TVerkauf): TValidationResult; override;
    procedure OnEnter(AContext: TVerkauf); override;
  end;

  // -------------------------------------------------------
  // State: Angebot
  // -------------------------------------------------------
  TVerkaufState_Angebot = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
  end;

  // -------------------------------------------------------
  // State: Verifikation (Schufa, Postident, Bank)
  // -------------------------------------------------------
  TVerkaufState_Verifikation = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
    function  Validate(AContext: TVerkauf): TValidationResult; override;
  end;

  // -------------------------------------------------------
  // State: Kaufvertrag
  // -------------------------------------------------------
  TVerkaufState_Kaufvertrag = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
    function  Validate(AContext: TVerkauf): TValidationResult; override;
  end;

  // -------------------------------------------------------
  // State: Zahlung
  // -------------------------------------------------------
  TVerkaufState_Zahlung = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
    function  Validate(AContext: TVerkauf): TValidationResult; override;
  end;

  // -------------------------------------------------------
  // State: Übergabe
  // -------------------------------------------------------
  TVerkaufState_Übergabe = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
    function  Validate(AContext: TVerkauf): TValidationResult; override;
  end;

  // -------------------------------------------------------
  // State: Abgeschlossen (Final)
  // -------------------------------------------------------
  TVerkaufState_Abgeschlossen = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
    procedure OnEnter(AContext: TVerkauf); override;
  end;

  // -------------------------------------------------------
  // State: Abgebrochen (Final)
  // -------------------------------------------------------
  TVerkaufState_Abgebrochen = class(TBaseState<TVerkauf>)
  public
    constructor Create;
    procedure Execute(AContext: TVerkauf); override;
  end;

  // -------------------------------------------------------
  // Factory - baut die vollständige State Machine auf
  // -------------------------------------------------------
  TVerkaufStateMachineFactory = class
  public
    class function Create(AVerkauf: TVerkauf): TStateMachine<TVerkauf>;
  end;

  // -------------------------------------------------------
  // Business Case Klasse
  // -------------------------------------------------------
  TVerkaufBC = class(TInterfacedObject, IBusinessCase<TVerkauf>)
  private
    FVerkauf      : TVerkauf;
    FStateMachine : TStateMachine<TVerkauf>;
  public
    constructor Create(AVerkauf: TVerkauf);
    destructor Destroy; override;
    function  GetId: Integer;
    function  GetCurrentStateCode: TStateCode;
    function  GetStateMachine: IStateMachine<TVerkauf>;
    function  Validate: TValidationResult;
    procedure Advance(const ATargetState: TStateCode);
    procedure Abort(const AReason: string);
    function  CanAdvanceTo(const ATargetState: TStateCode): Boolean;
    property  Verkauf: TVerkauf read FVerkauf;
  end;

implementation

{ TVerkaufState_Interessent }

constructor TVerkaufState_Interessent.Create;
begin
  inherited Create(SC_V_INTERESSENT, 'Interessent');
  AddAllowedTransition(SC_V_PROBEFAHRT);
  AddAllowedTransition(SC_V_ANGEBOT);
  AddAllowedTransition(SC_V_ABGEBROCHEN);
end;

procedure TVerkaufState_Interessent.Execute(AContext: TVerkauf);
begin
  // Interessent registriert - keine Aktion nötig
end;

function TVerkaufState_Interessent.Validate(AContext: TVerkauf): TValidationResult;
begin
  if AContext.KundeId <= 0 then
    Result := TValidationResult.Fail(['Kunde muss zugeordnet sein'])
  else if AContext.FahrzeugId <= 0 then
    Result := TValidationResult.Fail(['Fahrzeug muss zugeordnet sein'])
  else
    Result := TValidationResult.OK;
end;

{ TVerkaufState_Probefahrt }

constructor TVerkaufState_Probefahrt.Create;
begin
  inherited Create(SC_V_PROBEFAHRT, 'Probefahrt');
  AddAllowedTransition(SC_V_ANGEBOT);
  AddAllowedTransition(SC_V_ABGEBROCHEN);
end;

procedure TVerkaufState_Probefahrt.OnEnter(AContext: TVerkauf);
begin
  // Führerschein-Prüfung wird durch Mitarbeiter ausgelöst
end;

procedure TVerkaufState_Probefahrt.Execute(AContext: TVerkauf);
begin
  // Probefahrt-Termin wird über Terminverwaltung gehandelt
end;

function TVerkaufState_Probefahrt.Validate(AContext: TVerkauf): TValidationResult;
begin
  // Beim Wechsel in diesen State: Mitarbeiter muss bestätigen
  Result := TValidationResult.OK;
end;

{ TVerkaufState_Angebot }

constructor TVerkaufState_Angebot.Create;
begin
  inherited Create(SC_V_ANGEBOT, 'Angebot');
  AddAllowedTransition(SC_V_VERIFIKATION);
  AddAllowedTransition(SC_V_ABGEBROCHEN);
end;

procedure TVerkaufState_Angebot.Execute(AContext: TVerkauf);
begin
  // Angebot wurde erstellt und an Kunden versendet
end;

{ TVerkaufState_Verifikation }

constructor TVerkaufState_Verifikation.Create;
begin
  inherited Create(SC_V_VERIFIKATION, 'Verifikation');
  AddAllowedTransition(SC_V_KAUFVERTRAG);
  AddAllowedTransition(SC_V_ABGEBROCHEN);
end;

procedure TVerkaufState_Verifikation.Execute(AContext: TVerkauf);
begin
  // Warten auf Schufa/Postident/Bank
end;

function TVerkaufState_Verifikation.Validate(AContext: TVerkauf): TValidationResult;
var
  Errors: TArray<string>;
begin
  Errors := [];
  if not AContext.IsVerifiziert then
  begin
    if AContext.SchufaDocPfad = '' then
      Errors := Errors + ['Schufa-Dokument fehlt'];
    if AContext.PostidentRef = '' then
      Errors := Errors + ['Postident-Referenz fehlt'];
    if not AContext.BankBestaetigt then
      Errors := Errors + ['Bankverbindung nicht bestätigt'];
  end;
  if Length(Errors) > 0 then
    Result := TValidationResult.Fail(Errors)
  else
    Result := TValidationResult.OK;
end;

{ TVerkaufState_Kaufvertrag }

constructor TVerkaufState_Kaufvertrag.Create;
begin
  inherited Create(SC_V_KAUFVERTRAG, 'Kaufvertrag');
  AddAllowedTransition(SC_V_ZAHLUNG);
  AddAllowedTransition(SC_V_ABGEBROCHEN);
end;

procedure TVerkaufState_Kaufvertrag.Execute(AContext: TVerkauf);
begin
  // Kaufvertrag wurde manuell durch Mitarbeiter verifiziert
end;

function TVerkaufState_Kaufvertrag.Validate(AContext: TVerkauf): TValidationResult;
begin
  if AContext.VereinbarterPreis <= 0 then
    Result := TValidationResult.Fail(['Kaufpreis muss angegeben sein'])
  else
    Result := TValidationResult.OK;
end;

{ TVerkaufState_Zahlung }

constructor TVerkaufState_Zahlung.Create;
begin
  inherited Create(SC_V_ZAHLUNG, 'Zahlung');
  AddAllowedTransition(SC_V_ÜBERGABE);
  AddAllowedTransition(SC_V_ABGEBROCHEN);
end;

procedure TVerkaufState_Zahlung.Execute(AContext: TVerkauf);
begin
  // Warten auf Zahlungseingang
end;

function TVerkaufState_Zahlung.Validate(AContext: TVerkauf): TValidationResult;
begin
  if AContext.ZahlungseingangAm = 0 then
    Result := TValidationResult.Fail(['Zahlungseingang noch nicht bestätigt'])
  else
    Result := TValidationResult.OK;
end;

{ TVerkaufState_Übergabe }

constructor TVerkaufState_Übergabe.Create;
begin
  inherited Create(SC_V_ÜBERGABE, 'Übergabe');
  AddAllowedTransition(SC_V_ABGESCHLOSSEN);
  AddAllowedTransition(SC_V_ABGEBROCHEN);
end;

procedure TVerkaufState_Übergabe.Execute(AContext: TVerkauf);
begin
  // Übergabe vorbereiten
end;

function TVerkaufState_Übergabe.Validate(AContext: TVerkauf): TValidationResult;
var
  Errors: TArray<string>;
begin
  Errors := [];
  if not AContext.SchluessselUebergabe then
    Errors := Errors + ['Schlüsselübergabe nicht bestätigt'];
  if AContext.KaufvertragPfad = '' then
    Errors := Errors + ['Digitalisierter Kaufvertrag fehlt'];
  if AContext.QuittungPfad = '' then
    Errors := Errors + ['Quittung fehlt'];
  if Length(Errors) > 0 then
    Result := TValidationResult.Fail(Errors)
  else
    Result := TValidationResult.OK;
end;

{ TVerkaufState_Abgeschlossen }

constructor TVerkaufState_Abgeschlossen.Create;
begin
  inherited Create(SC_V_ABGESCHLOSSEN, 'Abgeschlossen', True);
end;

procedure TVerkaufState_Abgeschlossen.OnEnter(AContext: TVerkauf);
begin
  // Fahrzeug-Status auf Verkauft setzen (via Repository)
end;

procedure TVerkaufState_Abgeschlossen.Execute(AContext: TVerkauf);
begin
  // Finaler Zustand
end;

{ TVerkaufState_Abgebrochen }

constructor TVerkaufState_Abgebrochen.Create;
begin
  inherited Create(SC_V_ABGEBROCHEN, 'Abgebrochen', True);
end;

procedure TVerkaufState_Abgebrochen.Execute(AContext: TVerkauf);
begin
  // Abbruch - Fahrzeug wieder freigeben
end;

{ TVerkaufStateMachineFactory }

class function TVerkaufStateMachineFactory.Create(AVerkauf: TVerkauf): TStateMachine<TVerkauf>;
var
  SM: TStateMachine<TVerkauf>;
begin
  SM := TStateMachine<TVerkauf>.Create;
  SM.RegisterState(TVerkaufState_Interessent.Create);
  SM.RegisterState(TVerkaufState_Probefahrt.Create);
  SM.RegisterState(TVerkaufState_Angebot.Create);
  SM.RegisterState(TVerkaufState_Verifikation.Create);
  SM.RegisterState(TVerkaufState_Kaufvertrag.Create);
  SM.RegisterState(TVerkaufState_Zahlung.Create);
  SM.RegisterState(TVerkaufState_Übergabe.Create);
  SM.RegisterState(TVerkaufState_Abgeschlossen.Create);
  SM.RegisterState(TVerkaufState_Abgebrochen.Create);

  if AVerkauf.StateCode = '' then
    SM.SetInitialState(SC_V_INTERESSENT)
  else
    SM.SetInitialState(AVerkauf.StateCode);

  Result := SM;
end;

{ TVerkaufBC }

constructor TVerkaufBC.Create(AVerkauf: TVerkauf);
begin
  inherited Create;
  FVerkauf      := AVerkauf;
  FStateMachine := TVerkaufStateMachineFactory.Create(AVerkauf);
end;

destructor TVerkaufBC.Destroy;
begin
  FStateMachine.Free;
  inherited;
end;

function TVerkaufBC.GetId: Integer;                begin Result := FVerkauf.Id; end;
function TVerkaufBC.GetCurrentStateCode: TStateCode; begin Result := FStateMachine.GetCurrentStateCode; end;
function TVerkaufBC.GetStateMachine: IStateMachine<TVerkauf>; begin Result := FStateMachine; end;

function TVerkaufBC.Validate: TValidationResult;
begin
  Result := FStateMachine.GetCurrentState.Validate(FVerkauf);
end;

procedure TVerkaufBC.Advance(const ATargetState: TStateCode);
var
  ValidationResult: TValidationResult;
begin
  ValidationResult := Validate;
  if not ValidationResult.IsValid then
    raise TValidationException.Create(
      'Validierung fehlgeschlagen: ' + string.Join(', ', ValidationResult.Errors));
  FStateMachine.TransitionTo(ATargetState, FVerkauf);
  FVerkauf.StateCode := ATargetState;
end;

procedure TVerkaufBC.Abort(const AReason: string);
begin
  FStateMachine.TransitionTo(SC_V_ABGEBROCHEN, FVerkauf);
  FVerkauf.StateCode := SC_V_ABGEBROCHEN;
end;

function TVerkaufBC.CanAdvanceTo(const ATargetState: TStateCode): Boolean;
begin
  Result := FStateMachine.CanTransitionTo(ATargetState);
end;

end.
