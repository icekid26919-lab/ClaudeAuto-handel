unit AutoHandel.ViewModel.Verkauf;

{
  AutoHandel - ViewModel: Autoverkauf
  =====================================
  MVVM ViewModel für den Verkaufs-Workflow.
  Trennt UI-Logik von Geschäftslogik.
  Ermöglicht Unit-Tests ohne UI-Abhängigkeit.
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  AutoHandel.Interfaces, AutoHandel.Models,
  AutoHandel.BusinessCase.Verkauf, AutoHandel.StateMachine;

type
  // -------------------------------------------------------
  // Basis-ViewModel mit Property-Changed Notifier
  // -------------------------------------------------------
  TBaseViewModel = class(TInterfacedObject,
    IViewModel, IPropertyChangedNotifier)
  private
    FObservers   : TList<IPropertyChangedObserver>;
    FIsBusy      : Boolean;
    FErrorMessage: string;
  protected
    procedure SetBusy(AValue: Boolean);
    procedure SetError(const AMessage: string);
    procedure ClearError;
    procedure SetProperty<T>(var AField: T; const AValue: T;
      const APropName: string);
  public
    constructor Create;
    destructor Destroy; override;
    // IPropertyChangedNotifier
    procedure AddObserver(AObserver: IPropertyChangedObserver);
    procedure RemoveObserver(AObserver: IPropertyChangedObserver);
    procedure NotifyPropertyChanged(const APropertyName: string);
    // IViewModel
    procedure Initialize; virtual; abstract;
    procedure Refresh; virtual; abstract;
    function  Validate: TValidationResult; virtual;
    function  IsBusy: Boolean;
    function  GetErrorMessage: string;
  end;

  // -------------------------------------------------------
  // FahrzeugSuche ViewModel
  // -------------------------------------------------------
  TFahrzeugSucheViewModel = class(TBaseViewModel)
  private
    FFilter          : TFahrzeugFilterImpl;
    FSuchergebnisse  : TList<TFahrzeugSuchErgebnis>;
    FSelectedIndex   : Integer;
    FPartialMatches  : Boolean;
    FOnSucheGestartet: TNotifyEvent;
    FOnErgebnisse    : TNotifyEvent;
    // Commands
    FSuchenCommand   : ICommand;
    FResetCommand    : ICommand;
    procedure DoSuche;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize; override;
    procedure Refresh; override;
    function  Validate: TValidationResult; override;
    // Filter Properties
    procedure SetMarkeId(AValue: Integer);
    procedure SetModellId(AValue: Integer);
    procedure SetPreisVon(AValue: Double);
    procedure SetPreisBis(AValue: Double);
    procedure SetKmVon(AValue: Integer);
    procedure SetKmBis(AValue: Integer);
    procedure SetBaujahrVon(AValue: Integer);
    procedure SetBaujahrBis(AValue: Integer);
    procedure SetSuchtext(const AValue: string);
    procedure SetPartialMatch(AValue: Boolean);
    procedure SetAusstattungFilter(const AIds: TArray<Integer>);
    // Ergebnisse
    function  GetSuchergebnisse: TList<TFahrzeugSuchErgebnis>;
    function  GetSelectedIndex: Integer;
    procedure SetSelectedIndex(AValue: Integer);
    function  GetSelectedFahrzeugId: Integer;
    // Commands
    function  GetSuchenCommand: ICommand;
    function  GetResetCommand: ICommand;
    // Events
    property  OnSucheGestartet: TNotifyEvent read FOnSucheGestartet write FOnSucheGestartet;
    property  OnErgebnisse: TNotifyEvent read FOnErgebnisse write FOnErgebnisse;
    property  Filter: TFahrzeugFilterImpl read FFilter;
  end;

  // -------------------------------------------------------
  // Fahrzeug-Detail ViewModel
  // -------------------------------------------------------
  TFahrzeugDetailViewModel = class(TBaseViewModel)
  private
    FFahrzeugId      : Integer;
    FFahrzeug        : TFahrzeug;
    FAnfrageArt      : string;  // 'Kauf','Probefahrt','Besichtigung'
    FOnTerminAnfrage : TNotifyEvent;
  public
    constructor Create(AFahrzeugId: Integer);
    destructor Destroy; override;
    procedure Initialize; override;
    procedure Refresh; override;
    procedure StarteKaufProzess;
    procedure StarteProbefahrtTermin;
    procedure StarteBesichtigungsTermin;
    procedure StarteOnlineBeuch;
    property  Fahrzeug: TFahrzeug read FFahrzeug;
    property  AnfrageArt: string read FAnfrageArt;
    property  OnTerminAnfrage: TNotifyEvent read FOnTerminAnfrage write FOnTerminAnfrage;
  end;

  // -------------------------------------------------------
  // Termin ViewModel (für Kauf, Probefahrt, Besichtigung)
  // -------------------------------------------------------
  TTerminViewModel = class(TBaseViewModel)
  private
    FTermin          : TTermin;
    FFahrzeugId      : Integer;
    FKundeId         : Integer;
    FArt             : string;
    FGewuenschtesDatum: TDateTime;
    FFiliale         : TFiliale;
    FRouteInfo       : string;
    FOnTerminBestaetigt: TNotifyEvent;
    procedure BerechneRoute;
  public
    constructor Create(AFahrzeugId, AKundeId: Integer; const AArt: string);
    destructor Destroy; override;
    procedure Initialize; override;
    procedure Refresh; override;
    function  Validate: TValidationResult; override;
    procedure SetGewuenschtesDatum(AValue: TDateTime);
    procedure SetFiliale(AFiliale: TFiliale);
    procedure AnfrageStellen;
    property  Termin: TTermin read FTermin;
    property  RouteInfo: string read FRouteInfo;
    property  OnTerminBestaetigt: TNotifyEvent read FOnTerminBestaetigt write FOnTerminBestaetigt;
  end;

  // -------------------------------------------------------
  // Mitarbeiter-ViewModel (für Terminbestätigung)
  // -------------------------------------------------------
  TMitarbeiterVerkaufViewModel = class(TBaseViewModel)
  private
    FMitarbeiterId   : Integer;
    FOffeneTermine   : TObjectList<TTermin>;
    FVerkaufBC       : TVerkaufBC;
    FOnVerkaufAdvanced: TStateChangedEvent;
  public
    constructor Create(AMitarbeiterId: Integer);
    destructor Destroy; override;
    procedure Initialize; override;
    procedure Refresh; override;
    procedure LadeTermine;
    procedure TerminBestaetigen(ATerminId: Integer);
    procedure TerminAbsagen(ATerminId: Integer; const AGrund: string);
    procedure FuehrerscheinPruefungOK(ATerminId: Integer);
    procedure AngebotVersenden(AKundeId, AVerkaufId: Integer);
    // Probefahrt Security Check
    function  PruefeFuehrerschein(AKundeId: Integer): Boolean;
    property  OffeneTermine: TObjectList<TTermin> read FOffeneTermine;
    property  VerkaufBC: TVerkaufBC read FVerkaufBC write FVerkaufBC;
  end;

  // -------------------------------------------------------
  // Verifikations-ViewModel (Schufa, Postident, Bank)
  // -------------------------------------------------------
  TVerifikationViewModel = class(TBaseViewModel)
  private
    FVerkaufId       : Integer;
    FVerkauf         : TVerkauf;
    FSchufaDokument  : TStream;
    FPostidentRef    : string;
    FBankIBAN        : string;
    FBankBIC         : string;
  public
    constructor Create(AVerkaufId: Integer);
    destructor Destroy; override;
    procedure Initialize; override;
    procedure Refresh; override;
    function  Validate: TValidationResult; override;
    procedure SchufaDokumentHochladen(AStream: TStream);
    procedure SetPostidentRef(const ARef: string);
    procedure BankdatenSetzen(const AIBAN, ABIC: string);
    procedure VerifikationAbschliessen;
    property  Verkauf: TVerkauf read FVerkauf;
    property  SchufaDokument: TStream read FSchufaDokument;
    property  PostidentRef: string read FPostidentRef;
  end;

  // -------------------------------------------------------
  // Übergabe-ViewModel
  // -------------------------------------------------------
  TUebergabeViewModel = class(TBaseViewModel)
  private
    FVerkaufId         : Integer;
    FVerkauf           : TVerkauf;
    FSchluessselOK     : Boolean;
    FKaufvertragScan   : TStream;
    FQuittungScan      : TStream;
  public
    constructor Create(AVerkaufId: Integer);
    destructor Destroy; override;
    procedure Initialize; override;
    procedure Refresh; override;
    function  Validate: TValidationResult; override;
    procedure SchluessselUebergebenBestaetigen;
    procedure KaufvertragScanHochladen(AStream: TStream);
    procedure QuittungScanHochladen(AStream: TStream);
    procedure UebergabeAbschliessen;
    property  Verkauf: TVerkauf read FVerkauf;
    property  SchluessselOK: Boolean read FSchluessselOK;
  end;

  // -------------------------------------------------------
  // Simple Command Implementations
  // -------------------------------------------------------
  TDelegateCommand = class(TInterfacedObject, ICommand)
  private
    FExecute   : TProc;
    FCanExecute: TFunc<Boolean>;
  public
    constructor Create(AExecute: TProc; ACanExecute: TFunc<Boolean> = nil);
    function  CanExecute: Boolean;
    procedure Execute;
  end;

implementation

{ TBaseViewModel }

constructor TBaseViewModel.Create;
begin
  inherited;
  FObservers := TList<IPropertyChangedObserver>.Create;
end;

destructor TBaseViewModel.Destroy;
begin
  FObservers.Free;
  inherited;
end;

procedure TBaseViewModel.AddObserver(AObserver: IPropertyChangedObserver);
begin
  if not FObservers.Contains(AObserver) then
    FObservers.Add(AObserver);
end;

procedure TBaseViewModel.RemoveObserver(AObserver: IPropertyChangedObserver);
begin
  FObservers.Remove(AObserver);
end;

procedure TBaseViewModel.NotifyPropertyChanged(const APropertyName: string);
var
  Obs: IPropertyChangedObserver;
begin
  for Obs in FObservers do
    Obs.OnPropertyChanged(APropertyName);
end;

procedure TBaseViewModel.SetBusy(AValue: Boolean);
begin
  if FIsBusy <> AValue then
  begin
    FIsBusy := AValue;
    NotifyPropertyChanged('IsBusy');
  end;
end;

procedure TBaseViewModel.SetError(const AMessage: string);
begin
  FErrorMessage := AMessage;
  NotifyPropertyChanged('ErrorMessage');
end;

procedure TBaseViewModel.ClearError;
begin
  SetError('');
end;

procedure TBaseViewModel.SetProperty<T>(var AField: T; const AValue: T;
  const APropName: string);
begin
  AField := AValue;
  NotifyPropertyChanged(APropName);
end;

function TBaseViewModel.Validate: TValidationResult;
begin
  Result := TValidationResult.OK;
end;

function TBaseViewModel.IsBusy: Boolean;      begin Result := FIsBusy; end;
function TBaseViewModel.GetErrorMessage: string; begin Result := FErrorMessage; end;

{ TFahrzeugSucheViewModel }

constructor TFahrzeugSucheViewModel.Create;
begin
  inherited Create;
  FFilter         := TFahrzeugFilterImpl.Create;
  FSuchergebnisse := TList<TFahrzeugSuchErgebnis>.Create;
  FSelectedIndex  := -1;
  FPartialMatches := True;
end;

destructor TFahrzeugSucheViewModel.Destroy;
begin
  FSuchergebnisse.Free;
  FFilter.Free;
  inherited;
end;

procedure TFahrzeugSucheViewModel.Initialize;
begin
  FFilter.Reset;
  FSuchergebnisse.Clear;
  FSelectedIndex := -1;
end;

procedure TFahrzeugSucheViewModel.Refresh;
begin
  DoSuche;
end;

procedure TFahrzeugSucheViewModel.DoSuche;
begin
  SetBusy(True);
  try
    // Repository-Aufruf würde hier erfolgen
    // FSuchergebnisse := FRepository.SucheAutos(FFilter);
    FSuchergebnisse.Clear;
    NotifyPropertyChanged('Suchergebnisse');
    if Assigned(FOnErgebnisse) then FOnErgebnisse(Self);
  finally
    SetBusy(False);
  end;
end;

procedure TFahrzeugSucheViewModel.SetMarkeId(AValue: Integer);
begin SetProperty(FFilter.FMarkeId, AValue, 'MarkeId'); end;

procedure TFahrzeugSucheViewModel.SetModellId(AValue: Integer);
begin SetProperty(FFilter.FModellId, AValue, 'ModellId'); end;

procedure TFahrzeugSucheViewModel.SetPreisVon(AValue: Double);
begin SetProperty(FFilter.FPreisVon, AValue, 'PreisVon'); end;

procedure TFahrzeugSucheViewModel.SetPreisBis(AValue: Double);
begin SetProperty(FFilter.FPreisBis, AValue, 'PreisBis'); end;

procedure TFahrzeugSucheViewModel.SetKmVon(AValue: Integer);
begin SetProperty(FFilter.FKmVon, AValue, 'KmVon'); end;

procedure TFahrzeugSucheViewModel.SetKmBis(AValue: Integer);
begin SetProperty(FFilter.FKmBis, AValue, 'KmBis'); end;

procedure TFahrzeugSucheViewModel.SetBaujahrVon(AValue: Integer);
begin SetProperty(FFilter.FBaujahrVon, AValue, 'BaujahrVon'); end;

procedure TFahrzeugSucheViewModel.SetBaujahrBis(AValue: Integer);
begin SetProperty(FFilter.FBaujahrBis, AValue, 'BaujahrBis'); end;

procedure TFahrzeugSucheViewModel.SetSuchtext(const AValue: string);
begin SetProperty(FFilter.FSuchtext, AValue, 'Suchtext'); end;

procedure TFahrzeugSucheViewModel.SetPartialMatch(AValue: Boolean);
begin SetProperty(FFilter.FPartialMatch, AValue, 'PartialMatch'); end;

procedure TFahrzeugSucheViewModel.SetAusstattungFilter(const AIds: TArray<Integer>);
begin
  FFilter.FAusstattungIds := AIds;
  NotifyPropertyChanged('AusstattungIds');
end;

function TFahrzeugSucheViewModel.GetSuchergebnisse: TList<TFahrzeugSuchErgebnis>;
begin Result := FSuchergebnisse; end;

function TFahrzeugSucheViewModel.GetSelectedIndex: Integer;
begin Result := FSelectedIndex; end;

procedure TFahrzeugSucheViewModel.SetSelectedIndex(AValue: Integer);
begin SetProperty(FSelectedIndex, AValue, 'SelectedIndex'); end;

function TFahrzeugSucheViewModel.GetSelectedFahrzeugId: Integer;
begin
  if (FSelectedIndex >= 0) and (FSelectedIndex < FSuchergebnisse.Count) then
    Result := FSuchergebnisse[FSelectedIndex].FahrzeugId
  else
    Result := 0;
end;

function TFahrzeugSucheViewModel.GetSuchenCommand: ICommand;
begin
  if not Assigned(FSuchenCommand) then
    FSuchenCommand := TDelegateCommand.Create(DoSuche);
  Result := FSuchenCommand;
end;

function TFahrzeugSucheViewModel.GetResetCommand: ICommand;
begin
  if not Assigned(FResetCommand) then
    FResetCommand := TDelegateCommand.Create(
      procedure begin
        FFilter.Reset;
        FSuchergebnisse.Clear;
        FSelectedIndex := -1;
        NotifyPropertyChanged('Filter');
        NotifyPropertyChanged('Suchergebnisse');
      end);
  Result := FResetCommand;
end;

function TFahrzeugSucheViewModel.Validate: TValidationResult;
begin
  Result := TValidationResult.OK;
end;

{ TFahrzeugDetailViewModel }

constructor TFahrzeugDetailViewModel.Create(AFahrzeugId: Integer);
begin
  inherited Create;
  FFahrzeugId := AFahrzeugId;
  FFahrzeug   := nil;
end;

destructor TFahrzeugDetailViewModel.Destroy;
begin
  FFahrzeug.Free;
  inherited;
end;

procedure TFahrzeugDetailViewModel.Initialize;
begin
  Refresh;
end;

procedure TFahrzeugDetailViewModel.Refresh;
begin
  SetBusy(True);
  try
    // FFahrzeug := FRepository.GetById(FFahrzeugId);
    NotifyPropertyChanged('Fahrzeug');
  finally
    SetBusy(False);
  end;
end;

procedure TFahrzeugDetailViewModel.StarteKaufProzess;
begin
  FAnfrageArt := 'Kauf';
  if Assigned(FOnTerminAnfrage) then FOnTerminAnfrage(Self);
end;

procedure TFahrzeugDetailViewModel.StarteProbefahrtTermin;
begin
  FAnfrageArt := 'Probefahrt';
  if Assigned(FOnTerminAnfrage) then FOnTerminAnfrage(Self);
end;

procedure TFahrzeugDetailViewModel.StarteBesichtigungsTermin;
begin
  FAnfrageArt := 'Besichtigung';
  if Assigned(FOnTerminAnfrage) then FOnTerminAnfrage(Self);
end;

procedure TFahrzeugDetailViewModel.StarteOnlineBeuch;
begin
  FAnfrageArt := 'Online_Besuch';
  if Assigned(FOnTerminAnfrage) then FOnTerminAnfrage(Self);
end;

{ TTerminViewModel }

constructor TTerminViewModel.Create(AFahrzeugId, AKundeId: Integer; const AArt: string);
begin
  inherited Create;
  FFahrzeugId := AFahrzeugId;
  FKundeId    := AKundeId;
  FArt        := AArt;
  FTermin     := TTermin.Create;
  FTermin.Art := AArt;
  FTermin.FahrzeugId := AFahrzeugId;
  FTermin.KundeId    := AKundeId;
end;

destructor TTerminViewModel.Destroy;
begin
  FTermin.Free;
  FFiliale.Free;
  inherited;
end;

procedure TTerminViewModel.Initialize;
begin
  BerechneRoute;
end;

procedure TTerminViewModel.Refresh;
begin
  BerechneRoute;
end;

procedure TTerminViewModel.BerechneRoute;
begin
  // OpenStreetMap Integration würde hier erfolgen
  // Nominatim API für Geocoding der Filiale
  FRouteInfo := 'Route wird berechnet...';
  NotifyPropertyChanged('RouteInfo');
end;

procedure TTerminViewModel.SetGewuenschtesDatum(AValue: TDateTime);
begin
  FGewuenschtesDatum := AValue;
  FTermin.TerminDatum := AValue;
  NotifyPropertyChanged('GewuenschtesDatum');
end;

procedure TTerminViewModel.SetFiliale(AFiliale: TFiliale);
begin
  FFiliale := AFiliale;
  if Assigned(FTermin) then
    FTermin.FilialeId := AFiliale.Id;
  BerechneRoute;
  NotifyPropertyChanged('Filiale');
end;

function TTerminViewModel.Validate: TValidationResult;
var
  Errors: TArray<string>;
begin
  Errors := [];
  if FTermin.TerminDatum <= Now then
    Errors := Errors + ['Termin muss in der Zukunft liegen'];
  if FTermin.FilialeId <= 0 then
    Errors := Errors + ['Bitte eine Filiale auswählen'];
  if Length(Errors) > 0 then
    Result := TValidationResult.Fail(Errors)
  else
    Result := TValidationResult.OK;
end;

procedure TTerminViewModel.AnfrageStellen;
var
  Val: TValidationResult;
begin
  Val := Validate;
  if not Val.IsValid then
    raise TValidationException.Create(string.Join(', ', Val.Errors));
  // FTerminRepository.Save(FTermin);
  FTermin.Status := 'Angefragt';
  NotifyPropertyChanged('Termin');
  if Assigned(FOnTerminBestaetigt) then
    FOnTerminBestaetigt(Self);
end;

{ TMitarbeiterVerkaufViewModel }

constructor TMitarbeiterVerkaufViewModel.Create(AMitarbeiterId: Integer);
begin
  inherited Create;
  FMitarbeiterId := AMitarbeiterId;
  FOffeneTermine := TObjectList<TTermin>.Create(True);
end;

destructor TMitarbeiterVerkaufViewModel.Destroy;
begin
  FOffeneTermine.Free;
  inherited;
end;

procedure TMitarbeiterVerkaufViewModel.Initialize;
begin
  LadeTermine;
end;

procedure TMitarbeiterVerkaufViewModel.Refresh;
begin
  LadeTermine;
end;

procedure TMitarbeiterVerkaufViewModel.LadeTermine;
begin
  SetBusy(True);
  try
    FOffeneTermine.Clear;
    // FTerminRepository.GetByMitarbeiter(FMitarbeiterId, ['Angefragt'])
    NotifyPropertyChanged('OffeneTermine');
  finally
    SetBusy(False);
  end;
end;

procedure TMitarbeiterVerkaufViewModel.TerminBestaetigen(ATerminId: Integer);
begin
  // Repository: Termin.Status := 'Bestätigt'
  NotifyPropertyChanged('OffeneTermine');
end;

procedure TMitarbeiterVerkaufViewModel.TerminAbsagen(ATerminId: Integer; const AGrund: string);
begin
  // Repository: Termin.Status := 'Abgesagt'
  NotifyPropertyChanged('OffeneTermine');
end;

procedure TMitarbeiterVerkaufViewModel.FuehrerscheinPruefungOK(ATerminId: Integer);
begin
  // Sicherheitsabfrage: Mitarbeiter bestätigt Führerschein
  // Notiz am Termin + Übergang zu Probefahrt im VerkaufBC
end;

function TMitarbeiterVerkaufViewModel.PruefeFuehrerschein(AKundeId: Integer): Boolean;
begin
  // Führerschein-Nummer des Kunden laden und prüfen
  Result := False;
  // Hier wird die eigentliche Prüfung implementiert
end;

procedure TMitarbeiterVerkaufViewModel.AngebotVersenden(AKundeId, AVerkaufId: Integer);
begin
  // Angebot per E-Mail an Kunden senden
  // PDF-Generator + E-Mail-Service
end;

{ TVerifikationViewModel }

constructor TVerifikationViewModel.Create(AVerkaufId: Integer);
begin
  inherited Create;
  FVerkaufId := AVerkaufId;
end;

destructor TVerifikationViewModel.Destroy;
begin
  FVerkauf.Free;
  FSchufaDokument.Free;
  inherited;
end;

procedure TVerifikationViewModel.Initialize;
begin
  Refresh;
end;

procedure TVerifikationViewModel.Refresh;
begin
  // FVerkauf := FRepository.GetById(FVerkaufId);
  NotifyPropertyChanged('Verkauf');
end;

function TVerifikationViewModel.Validate: TValidationResult;
var
  Errors: TArray<string>;
begin
  Errors := [];
  if not Assigned(FSchufaDokument) then
    Errors := Errors + ['Schufa-Dokument muss hochgeladen sein'];
  if FPostidentRef = '' then
    Errors := Errors + ['Postident-Referenz fehlt'];
  if (FBankIBAN = '') then
    Errors := Errors + ['IBAN fehlt'];
  if Length(Errors) > 0 then
    Result := TValidationResult.Fail(Errors)
  else
    Result := TValidationResult.OK;
end;

procedure TVerifikationViewModel.SchufaDokumentHochladen(AStream: TStream);
begin
  FreeAndNil(FSchufaDokument);
  FSchufaDokument := AStream;
  NotifyPropertyChanged('SchufaDokument');
end;

procedure TVerifikationViewModel.SetPostidentRef(const ARef: string);
begin
  SetProperty(FPostidentRef, ARef, 'PostidentRef');
end;

procedure TVerifikationViewModel.BankdatenSetzen(const AIBAN, ABIC: string);
begin
  FBankIBAN := AIBAN;
  FBankBIC  := ABIC;
  NotifyPropertyChanged('Bankdaten');
end;

procedure TVerifikationViewModel.VerifikationAbschliessen;
var
  Val: TValidationResult;
begin
  Val := Validate;
  if not Val.IsValid then
    raise TValidationException.Create(string.Join(', ', Val.Errors));
  // Dokumente speichern, Verkauf.State → VERIFIKATION abgeschlossen
  NotifyPropertyChanged('Verkauf');
end;

{ TUebergabeViewModel }

constructor TUebergabeViewModel.Create(AVerkaufId: Integer);
begin
  inherited Create;
  FVerkaufId := AVerkaufId;
end;

destructor TUebergabeViewModel.Destroy;
begin
  FVerkauf.Free;
  FKaufvertragScan.Free;
  FQuittungScan.Free;
  inherited;
end;

procedure TUebergabeViewModel.Initialize;
begin
  Refresh;
end;

procedure TUebergabeViewModel.Refresh;
begin
  // FVerkauf := FRepository.GetById(FVerkaufId);
  NotifyPropertyChanged('Verkauf');
end;

function TUebergabeViewModel.Validate: TValidationResult;
var
  Errors: TArray<string>;
begin
  Errors := [];
  if not FSchluessselOK then
    Errors := Errors + ['Schlüsselübergabe noch nicht bestätigt'];
  if not Assigned(FKaufvertragScan) then
    Errors := Errors + ['Kaufvertrag-Scan fehlt'];
  if not Assigned(FQuittungScan) then
    Errors := Errors + ['Quittung-Scan fehlt'];
  if Length(Errors) > 0 then
    Result := TValidationResult.Fail(Errors)
  else
    Result := TValidationResult.OK;
end;

procedure TUebergabeViewModel.SchluessselUebergebenBestaetigen;
begin
  SetProperty(FSchluessselOK, True, 'SchluessselOK');
end;

procedure TUebergabeViewModel.KaufvertragScanHochladen(AStream: TStream);
begin
  FreeAndNil(FKaufvertragScan);
  FKaufvertragScan := AStream;
  NotifyPropertyChanged('KaufvertragScan');
end;

procedure TUebergabeViewModel.QuittungScanHochladen(AStream: TStream);
begin
  FreeAndNil(FQuittungScan);
  FQuittungScan := AStream;
  NotifyPropertyChanged('QuittungScan');
end;

procedure TUebergabeViewModel.UebergabeAbschliessen;
var
  Val: TValidationResult;
begin
  Val := Validate;
  if not Val.IsValid then
    raise TValidationException.Create(string.Join(', ', Val.Errors));
  // Scans speichern, VerkaufBC.Advance(SC_V_ABGESCHLOSSEN)
  NotifyPropertyChanged('Verkauf');
end;

{ TDelegateCommand }

constructor TDelegateCommand.Create(AExecute: TProc; ACanExecute: TFunc<Boolean>);
begin
  inherited Create;
  FExecute    := AExecute;
  FCanExecute := ACanExecute;
end;

function TDelegateCommand.CanExecute: Boolean;
begin
  if Assigned(FCanExecute) then
    Result := FCanExecute()
  else
    Result := True;
end;

procedure TDelegateCommand.Execute;
begin
  if Assigned(FExecute) then FExecute;
end;

end.
