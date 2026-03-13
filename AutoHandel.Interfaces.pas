unit AutoHandel.Interfaces;

{
  AutoHandel - Core Interfaces
  MVVM + State Machine Foundation
  ================================
  Alle Business Cases implementieren IBusinessCase<T>.
  Jeder Zustand implementiert IState<T>.
  ViewModels implementieren IViewModel.
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Rtti, System.TypInfo;

type
  // -------------------------------------------------------
  // Basis-Typen
  // -------------------------------------------------------
  TAutoHandelException = class(Exception);
  TStateException      = class(TAutoHandelException);
  TValidationException = class(TAutoHandelException);

  TStateCode = string;

  TValidationResult = record
    IsValid  : Boolean;
    Errors   : TArray<string>;
    class function OK: TValidationResult; static;
    class function Fail(const AErrors: TArray<string>): TValidationResult; static;
  end;

  // -------------------------------------------------------
  // Observer Pattern für MVVM
  // -------------------------------------------------------
  IPropertyChangedObserver = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    procedure OnPropertyChanged(const APropertyName: string);
  end;

  IPropertyChangedNotifier = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    procedure AddObserver(AObserver: IPropertyChangedObserver);
    procedure RemoveObserver(AObserver: IPropertyChangedObserver);
    procedure NotifyPropertyChanged(const APropertyName: string);
  end;

  // -------------------------------------------------------
  // Command Pattern für MVVM
  // -------------------------------------------------------
  ICommand = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-012345678902}']
    function  CanExecute: Boolean;
    procedure Execute;
  end;

  // -------------------------------------------------------
  // State Machine Interfaces
  // -------------------------------------------------------
  IStateMachine<T: class> = interface;

  IState<T: class> = interface
    ['{D4E5F6A7-B8C9-0123-DEF0-123456789003}']
    function  GetStateCode: TStateCode;
    function  GetStateName: string;
    function  IsFinalState: Boolean;
    function  CanTransitionTo(const ATargetState: TStateCode): Boolean;
    procedure OnEnter(AContext: T);
    procedure OnExit(AContext: T);
    procedure Execute(AContext: T);
    function  Validate(AContext: T): TValidationResult;
  end;

  IStateMachine<T: class> = interface
    ['{E5F6A7B8-C9D0-1234-EF01-234567890004}']
    function  GetCurrentState: IState<T>;
    function  GetCurrentStateCode: TStateCode;
    function  CanTransitionTo(const ATargetState: TStateCode): Boolean;
    procedure TransitionTo(const ATargetState: TStateCode; AContext: T);
    procedure RegisterState(AState: IState<T>);
    function  GetStateHistory: TArray<TStateCode>;
  end;

  // -------------------------------------------------------
  // Business Case Interface
  // -------------------------------------------------------
  IBusinessCase<T: class> = interface
    ['{F6A7B8C9-D0E1-2345-F012-345678900005}']
    function  GetId: Integer;
    function  GetCurrentStateCode: TStateCode;
    function  GetStateMachine: IStateMachine<T>;
    function  Validate: TValidationResult;
    procedure Advance(const ATargetState: TStateCode);
    procedure Abort(const AReason: string);
    function  CanAdvanceTo(const ATargetState: TStateCode): Boolean;
  end;

  // -------------------------------------------------------
  // ViewModel Interface
  // -------------------------------------------------------
  IViewModel = interface(IPropertyChangedNotifier)
    ['{A7B8C9D0-E1F2-3456-0123-456789000006}']
    procedure Initialize;
    procedure Refresh;
    function  Validate: TValidationResult;
    function  IsBusy: Boolean;
    function  GetErrorMessage: string;
  end;

  // -------------------------------------------------------
  // Repository Interface (Data Layer)
  // -------------------------------------------------------
  IRepository<T: class> = interface
    ['{B8C9D0E1-F2A3-4567-1234-567890000007}']
    function  GetById(AId: Integer): T;
    function  GetAll: TObjectList<T>;
    procedure Save(AEntity: T);
    procedure Delete(AId: Integer);
    function  Exists(AId: Integer): Boolean;
  end;

  // -------------------------------------------------------
  // Filter Interface
  // -------------------------------------------------------
  IFahrzeugFilter = interface
    ['{C9D0E1F2-A3B4-5678-2345-678900000008}']
    function  GetMarkeId: Integer;
    function  GetModellId: Integer;
    function  GetKraftstoffId: Integer;
    function  GetPreisVon: Double;
    function  GetPreisBis: Double;
    function  GetKmVon: Integer;
    function  GetKmBis: Integer;
    function  GetBaujahrVon: Integer;
    function  GetBaujahrBis: Integer;
    function  GetAusstattungIds: TArray<Integer>;
    function  GetSuchtext: string;
    function  GetPartialMatch: Boolean;
    property  MarkeId: Integer read GetMarkeId;
    property  ModellId: Integer read GetModellId;
    property  KraftstoffId: Integer read GetKraftstoffId;
    property  PreisVon: Double read GetPreisVon;
    property  PreisBis: Double read GetPreisBis;
    property  KmVon: Integer read GetKmVon;
    property  KmBis: Integer read GetKmBis;
    property  BaujahrVon: Integer read GetBaujahrVon;
    property  BaujahrBis: Integer read GetBaujahrBis;
    property  AusstattungIds: TArray<Integer> read GetAusstattungIds;
    property  Suchtext: string read GetSuchtext;
    property  PartialMatch: Boolean read GetPartialMatch;
  end;

  // -------------------------------------------------------
  // Fahrzeug Such-Ergebnis
  // -------------------------------------------------------
  TFahrzeugSuchErgebnis = record
    FahrzeugId      : Integer;
    MarkeModell     : string;
    Preis           : Double;
    Kilometerstand  : Integer;
    TitelbildUrl    : string;
    MatchScore      : Integer;  // 0-100, 100 = vollständiger Match
    FehlendeFilter  : TArray<string>;
  end;

  // -------------------------------------------------------
  // Event Typen
  // -------------------------------------------------------
  TStateChangedEvent = procedure(const AOldState, ANewState: TStateCode) of object;
  TValidationEvent   = procedure(const AResult: TValidationResult) of object;

implementation

{ TValidationResult }

class function TValidationResult.OK: TValidationResult;
begin
  Result.IsValid := True;
  Result.Errors  := [];
end;

class function TValidationResult.Fail(const AErrors: TArray<string>): TValidationResult;
begin
  Result.IsValid := False;
  Result.Errors  := AErrors;
end;

end.
