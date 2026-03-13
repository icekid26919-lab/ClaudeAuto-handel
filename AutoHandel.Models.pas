unit AutoHandel.Models;

{
  AutoHandel - Domain-Modelle
  ============================
  Alle Entitäten als Plain-Old-Object Klassen.
  Keine DB-Abhängigkeiten hier.
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Math;

type
  // -------------------------------------------------------
  // Stammdaten
  // -------------------------------------------------------
  TMarke = class
  public
    Id   : Integer;
    Name : string;
    Land : string;
  end;

  TModell = class
  public
    Id        : Integer;
    MarkeId   : Integer;
    Name      : string;
    BaujahrVon: Integer;
    BaujahrBis: Integer;
  end;

  TAusstattungMerkmal = class
  public
    Id         : Integer;
    Kategorie  : string;
    Name       : string;
  end;

  TFiliale = class
  public
    Id      : Integer;
    Name    : string;
    Strasse : string;
    PLZ     : string;
    Ort     : string;
    Land    : string;
    Lat     : Double;
    Lng     : Double;
    Telefon : string;
    Email   : string;
  end;

  TMitarbeiter = class
  public
    Id       : Integer;
    Vorname  : string;
    Nachname : string;
    Email    : string;
    Telefon  : string;
    Rolle    : string;
    FilialeId: Integer;
    Aktiv    : Boolean;
    function VollerName: string;
  end;

  TKunde = class
  public
    Id                : Integer;
    Anrede            : string;
    Vorname           : string;
    Nachname          : string;
    Firma             : string;
    Strasse           : string;
    PLZ               : string;
    Ort               : string;
    Email             : string;
    Telefon           : string;
    Mobil             : string;
    Geburtsdatum      : TDate;
    FuehrerscheinNr   : string;
    IBAN              : string;
    BIC               : string;
    BankName          : string;
    SchufaStatus      : string;
    PostidentStatus   : string;
    function VollerName: string;
  end;

  // -------------------------------------------------------
  // Fahrzeug
  // -------------------------------------------------------
  TFahrzeugStatus = (fsVerfuegbar, fsReserviert, fsVerkauft, fsInReparatur,
                     fsAngekauft, fsLeasing, fsGeloescht);

  TFahrzeugBild = class
  public
    Id           : Integer;
    FahrzeugId   : Integer;
    Dateiname    : string;
    Url          : string;
    IstTitelbild : Boolean;
    Reihenfolge  : Integer;
  end;

  TRabatt = class
  public
    Id          : Integer;
    FahrzeugId  : Integer;
    Art         : string;
    Bezeichnung : string;
    Betrag      : Double;
    Prozent     : Double;
    GueltigVon  : TDate;
    GueltigBis  : TDate;
    function BerechneterBetrag(AGrundpreis: Double): Double;
  end;

  TFahrzeug = class
  public
    Id                : Integer;
    InterneNr         : string;
    MarkeId           : Integer;
    ModellId          : Integer;
    Marke             : string;   // Denormalisiert für Anzeige
    Modell            : string;
    Baujahr           : Integer;
    Erstzulassung     : TDate;
    KraftstoffId      : Integer;
    Kraftstoff        : string;
    GetriebeId        : Integer;
    Getriebe          : string;
    FarbeId           : Integer;
    Farbe             : string;
    HubraumCCM        : Integer;
    LeistungKW        : Integer;
    Kilometerstand    : Integer;
    TuevDatum         : TDate;
    AnzahlVorbesitzer : Integer;
    Unfallfahrzeug    : Boolean;
    RaucherFahrzeug   : Boolean;
    VIN               : string;
    Einkaufspreis     : Double;
    Verkaufspreis     : Double;
    Minimalpreis      : Double;
    Status            : TFahrzeugStatus;
    Beschreibung      : string;
    EingestelltAm     : TDateTime;
    // Zugehörige Objekte
    Bilder            : TObjectList<TFahrzeugBild>;
    Ausstattung       : TObjectList<TAusstattungMerkmal>;
    Rabatte           : TObjectList<TRabatt>;
    constructor Create;
    destructor Destroy; override;
    function TitelbildUrl: string;
    function LeistungPS: Integer;
    function MarkeModellBaujahr: string;
    function EffektiverPreis: Double;
    function StatusText: string;
  end;

  // -------------------------------------------------------
  // Termin
  // -------------------------------------------------------
  TTermin = class
  public
    Id             : Integer;
    Art            : string;
    FahrzeugId     : Integer;
    KundeId        : Integer;
    MitarbeiterId  : Integer;
    FilialeId      : Integer;
    TerminDatum    : TDateTime;
    DauerMinuten   : Integer;
    Status         : string;
    Notizen        : string;
    VideoUrl       : string;
    ErstelltAm     : TDateTime;
  end;

  // -------------------------------------------------------
  // Verkauf
  // -------------------------------------------------------
  TVerkauf = class
  public
    Id                 : Integer;
    FahrzeugId         : Integer;
    KundeId            : Integer;
    MitarbeiterId      : Integer;
    StateCode          : string;
    SchufaDocPfad      : string;
    SchufaGeprueftAm   : TDateTime;
    PostidentRef       : string;
    PostidentGeprueftAm: TDateTime;
    BankBestaetigt     : Boolean;
    VereinbarterPreis  : Double;
    Anzahlung          : Double;
    Finanzierung       : Boolean;
    ZahlungseingangAm  : TDateTime;
    UebergabeDatum     : TDateTime;
    UebergabeOrt       : string;
    SchluessselUebergabe: Boolean;
    KaufvertragNr      : string;
    KaufvertragPfad    : string;
    QuittungPfad       : string;
    ErstelltAm         : TDateTime;
    function IsVerifiziert: Boolean;
  end;

  // -------------------------------------------------------
  // Ankauf
  // -------------------------------------------------------
  TAnkauf = class
  public
    Id                  : Integer;
    FahrzeugId          : Integer;
    KundeId             : Integer;
    MitarbeiterId       : Integer;
    StateCode           : string;
    SchaetzungMarke     : string;
    SchaetzungModell    : string;
    SchaetzungBaujahr   : Integer;
    SchaetzungKM        : Integer;
    SchaetzungZustand   : string;
    SchaetzungPreisMin  : Double;
    SchaetzungPreisMax  : Double;
    SchaetzungErgebnis  : Double;
    SchaetzungBericht   : string;
    VorfuehrungDatum    : TDateTime;
    VorfuehrungOK       : Boolean;
    VereinbarterPreis   : Double;
    AuszahlungDatum     : TDateTime;
    AuszahlungBetrag    : Double;
    ErstelltAm          : TDateTime;
  end;

  // -------------------------------------------------------
  // Leasing
  // -------------------------------------------------------
  TLeasingZahlung = class
  public
    Id                : Integer;
    LeasingId         : Integer;
    Faelligkeit       : TDate;
    Betrag            : Double;
    Art               : string;
    Status            : string;
    EingegangenerBetrag: Double;
    EingegangenenAm   : TDateTime;
    function Differenz: Double;
    function IstUeberfaellig: Boolean;
  end;

  TLeasing = class
  public
    Id                  : Integer;
    FahrzeugId          : Integer;
    KundeId             : Integer;
    MitarbeiterId       : Integer;
    StateCode           : string;
    LaufzeitMonate      : Integer;
    MonatlicheRate      : Double;
    Anzahlung           : Double;
    Restwert            : Double;
    KmLimitJaehrlich    : Integer;
    KmPreisUeber        : Double;
    VertragNr           : string;
    VertragBeginn       : TDate;
    VertragEnde         : TDate;
    VertragPfad         : string;
    RueckgabeKM         : Integer;
    RueckgabeDatum      : TDate;
    RueckgabeZustand    : string;
    SchlussrechnungBetrag: Double;
    Zahlungen           : TObjectList<TLeasingZahlung>;
    ErstelltAm          : TDateTime;
    constructor Create;
    destructor Destroy; override;
    function GesamtKosten: Double;
    function OffeneZahlungen: Double;
    function NaechsteFaelligkeit: TDate;
  end;

  // -------------------------------------------------------
  // Reparatur
  // -------------------------------------------------------
  TReparaturPosition = class
  public
    Id           : Integer;
    ReparaturId  : Integer;
    Art          : string;
    ErsatzteilId : Integer;
    Bezeichnung  : string;
    Menge        : Double;
    Einheit      : string;
    Einzelpreis  : Double;
    function Gesamtpreis: Double;
  end;

  TReparatur = class
  public
    Id                 : Integer;
    FahrzeugId         : Integer;
    KundeId            : Integer;
    MechanikerId       : Integer;
    StateCode          : string;
    Art                : string;
    DiagnoseDatum      : TDateTime;
    DiagnoseText       : string;
    KmBeiAnnahme       : Integer;
    KvaErstelltAm      : TDateTime;
    KvaArbeit          : Double;
    KvaMaterial        : Double;
    KvaGenehmigt       : Boolean;
    KvaGenehmigAm      : TDateTime;
    RechnungNr         : string;
    RechnungArbeit     : Double;
    RechnungMaterial   : Double;
    RechnungGesamt     : Double;
    RechnungDatum      : TDateTime;
    IstGarantiefall    : Boolean;
    GarantieRef        : string;
    FertiggestelltAm   : TDateTime;
    AbgeholtAm         : TDateTime;
    ErstelltAm         : TDateTime;
    Positionen         : TObjectList<TReparaturPosition>;
    constructor Create;
    destructor Destroy; override;
    function KvaGesamt: Double;
    function RechnungGesamtBerechnet: Double;
  end;

  // -------------------------------------------------------
  // Angebot
  // -------------------------------------------------------
  TAngebot = class
  public
    Id            : Integer;
    BcArt         : string;
    BcId          : Integer;
    KundeId       : Integer;
    MitarbeiterId : Integer;
    GueltigBis    : TDate;
    GesamtBetrag  : Double;
    Status        : string;
    Notizen       : string;
    PdfPfad       : string;
    ErstelltAm    : TDateTime;
    function IsAbgelaufen: Boolean;
  end;

  // -------------------------------------------------------
  // Ersatzteil
  // -------------------------------------------------------
  TErsatzteil = class
  public
    Id              : Integer;
    Artikelnummer   : string;
    Bezeichnung     : string;
    Hersteller      : string;
    KompatiblelMit  : string;
    Einkaufspreis   : Double;
    Verkaufspreis   : Double;
    Lagerbestand    : Integer;
    Mindestbestand  : Integer;
    Lagerort        : string;
    function IstUnterMindestbestand: Boolean;
    function Marge: Double;
  end;

  // -------------------------------------------------------
  // Such-Filter
  // -------------------------------------------------------
  TFahrzeugFilterImpl = class(TInterfacedObject, IFahrzeugFilter)
  private
    FMarkeId       : Integer;
    FModellId      : Integer;
    FKraftstoffId  : Integer;
    FPreisVon      : Double;
    FPreisBis      : Double;
    FKmVon         : Integer;
    FKmBis         : Integer;
    FBaujahrVon    : Integer;
    FBaujahrBis    : Integer;
    FAusstattungIds: TArray<Integer>;
    FSuchtext      : string;
    FPartialMatch  : Boolean;
  public
    constructor Create;
    procedure Reset;
    function GetMarkeId: Integer;
    function GetModellId: Integer;
    function GetKraftstoffId: Integer;
    function GetPreisVon: Double;
    function GetPreisBis: Double;
    function GetKmVon: Integer;
    function GetKmBis: Integer;
    function GetBaujahrVon: Integer;
    function GetBaujahrBis: Integer;
    function GetAusstattungIds: TArray<Integer>;
    function GetSuchtext: string;
    function GetPartialMatch: Boolean;
    property MarkeId: Integer read GetMarkeId write FMarkeId;
    property ModellId: Integer read GetModellId write FModellId;
    property KraftstoffId: Integer read GetKraftstoffId write FKraftstoffId;
    property PreisVon: Double read GetPreisVon write FPreisVon;
    property PreisBis: Double read GetPreisBis write FPreisBis;
    property KmVon: Integer read GetKmVon write FKmVon;
    property KmBis: Integer read GetKmBis write FKmBis;
    property BaujahrVon: Integer read GetBaujahrVon write FBaujahrVon;
    property BaujahrBis: Integer read GetBaujahrBis write FBaujahrBis;
    property AusstattungIds: TArray<Integer> read GetAusstattungIds write FAusstattungIds;
    property Suchtext: string read GetSuchtext write FSuchtext;
    property PartialMatch: Boolean read GetPartialMatch write FPartialMatch;
  end;

implementation

{ TMitarbeiter }
function TMitarbeiter.VollerName: string;
begin
  Result := Trim(Vorname + ' ' + Nachname);
end;

{ TKunde }
function TKunde.VollerName: string;
begin
  if Firma <> '' then
    Result := Firma
  else
    Result := Trim(Vorname + ' ' + Nachname);
end;

{ TRabatt }
function TRabatt.BerechneterBetrag(AGrundpreis: Double): Double;
begin
  if Prozent > 0 then
    Result := AGrundpreis * Prozent / 100
  else
    Result := Betrag;
end;

{ TFahrzeug }
constructor TFahrzeug.Create;
begin
  inherited;
  Bilder     := TObjectList<TFahrzeugBild>.Create(True);
  Ausstattung:= TObjectList<TAusstattungMerkmal>.Create(True);
  Rabatte    := TObjectList<TRabatt>.Create(True);
end;

destructor TFahrzeug.Destroy;
begin
  Bilder.Free;
  Ausstattung.Free;
  Rabatte.Free;
  inherited;
end;

function TFahrzeug.TitelbildUrl: string;
var
  B: TFahrzeugBild;
begin
  Result := '';
  for B in Bilder do
    if B.IstTitelbild then Exit(B.Url);
  if Bilder.Count > 0 then
    Result := Bilder[0].Url;
end;

function TFahrzeug.LeistungPS: Integer;
begin
  Result := Round(LeistungKW * 1.35962);
end;

function TFahrzeug.MarkeModellBaujahr: string;
begin
  Result := Format('%s %s (%d)', [Marke, Modell, Baujahr]);
end;

function TFahrzeug.EffektiverPreis: Double;
var
  Rabatt: TRabatt;
begin
  Result := Verkaufspreis;
  for Rabatt in Rabatte do
    Result := Result - Rabatt.BerechneterBetrag(Verkaufspreis);
  Result := Max(Result, 0);
end;

function TFahrzeug.StatusText: string;
const
  StatusTexte: array[TFahrzeugStatus] of string = (
    'Verfügbar','Reserviert','Verkauft','In Reparatur',
    'Angekauft','Leasing','Gelöscht');
begin
  Result := StatusTexte[Status];
end;

{ TVerkauf }
function TVerkauf.IsVerifiziert: Boolean;
begin
  Result := (SchufaDocPfad <> '') and
            (PostidentRef <> '') and
            BankBestaetigt;
end;

{ TLeasingZahlung }
function TLeasingZahlung.Differenz: Double;
begin
  Result := Betrag - EingegangenerBetrag;
end;

function TLeasingZahlung.IstUeberfaellig: Boolean;
begin
  Result := (Status = 'Ausstehend') and (Faelligkeit < Date);
end;

{ TLeasing }
constructor TLeasing.Create;
begin
  inherited;
  Zahlungen := TObjectList<TLeasingZahlung>.Create(True);
end;

destructor TLeasing.Destroy;
begin
  Zahlungen.Free;
  inherited;
end;

function TLeasing.GesamtKosten: Double;
begin
  Result := Anzahlung + (MonatlicheRate * LaufzeitMonate);
end;

function TLeasing.OffeneZahlungen: Double;
var
  Z: TLeasingZahlung;
begin
  Result := 0;
  for Z in Zahlungen do
    if Z.Status = 'Ausstehend' then
      Result := Result + Z.Betrag;
end;

function TLeasing.NaechsteFaelligkeit: TDate;
var
  Z: TLeasingZahlung;
begin
  Result := 0;
  for Z in Zahlungen do
    if (Z.Status = 'Ausstehend') and
       ((Result = 0) or (Z.Faelligkeit < Result)) then
      Result := Z.Faelligkeit;
end;

{ TReparaturPosition }
function TReparaturPosition.Gesamtpreis: Double;
begin
  Result := Menge * Einzelpreis;
end;

{ TReparatur }
constructor TReparatur.Create;
begin
  inherited;
  Positionen := TObjectList<TReparaturPosition>.Create(True);
end;

destructor TReparatur.Destroy;
begin
  Positionen.Free;
  inherited;
end;

function TReparatur.KvaGesamt: Double;
begin
  Result := KvaArbeit + KvaMaterial;
end;

function TReparatur.RechnungGesamtBerechnet: Double;
var
  P: TReparaturPosition;
begin
  Result := 0;
  for P in Positionen do
    Result := Result + P.Gesamtpreis;
end;

{ TAngebot }
function TAngebot.IsAbgelaufen: Boolean;
begin
  Result := (GueltigBis > 0) and (GueltigBis < Date);
end;

{ TErsatzteil }
function TErsatzteil.IstUnterMindestbestand: Boolean;
begin
  Result := Lagerbestand < Mindestbestand;
end;

function TErsatzteil.Marge: Double;
begin
  if Einkaufspreis > 0 then
    Result := (Verkaufspreis - Einkaufspreis) / Einkaufspreis * 100
  else
    Result := 0;
end;

{ TFahrzeugFilterImpl }
constructor TFahrzeugFilterImpl.Create;
begin
  inherited;
  Reset;
end;

procedure TFahrzeugFilterImpl.Reset;
begin
  FMarkeId       := 0;
  FModellId      := 0;
  FKraftstoffId  := 0;
  FPreisVon      := 0;
  FPreisBis      := 0;
  FKmVon         := 0;
  FKmBis         := 0;
  FBaujahrVon    := 0;
  FBaujahrBis    := 0;
  FAusstattungIds:= [];
  FSuchtext      := '';
  FPartialMatch  := True;
end;

function TFahrzeugFilterImpl.GetMarkeId: Integer;       begin Result := FMarkeId; end;
function TFahrzeugFilterImpl.GetModellId: Integer;      begin Result := FModellId; end;
function TFahrzeugFilterImpl.GetKraftstoffId: Integer;  begin Result := FKraftstoffId; end;
function TFahrzeugFilterImpl.GetPreisVon: Double;       begin Result := FPreisVon; end;
function TFahrzeugFilterImpl.GetPreisBis: Double;       begin Result := FPreisBis; end;
function TFahrzeugFilterImpl.GetKmVon: Integer;         begin Result := FKmVon; end;
function TFahrzeugFilterImpl.GetKmBis: Integer;         begin Result := FKmBis; end;
function TFahrzeugFilterImpl.GetBaujahrVon: Integer;    begin Result := FBaujahrVon; end;
function TFahrzeugFilterImpl.GetBaujahrBis: Integer;    begin Result := FBaujahrBis; end;
function TFahrzeugFilterImpl.GetAusstattungIds: TArray<Integer>; begin Result := FAusstattungIds; end;
function TFahrzeugFilterImpl.GetSuchtext: string;       begin Result := FSuchtext; end;
function TFahrzeugFilterImpl.GetPartialMatch: Boolean;  begin Result := FPartialMatch; end;

end.
