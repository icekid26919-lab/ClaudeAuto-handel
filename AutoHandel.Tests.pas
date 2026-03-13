unit AutoHandel.Tests;

{
  AutoHandel - DUnit/DUnitX Unit Tests
  ======================================
  Tests für:
  - State Machine Transitionen
  - Business Case Validierungen
  - ViewModel Logik
  - Modell-Berechnungen
}

interface

uses
  DUnitX.TestFramework, System.SysUtils, System.Classes,
  System.Generics.Collections,
  AutoHandel.Interfaces,
  AutoHandel.Models,
  AutoHandel.StateMachine,
  AutoHandel.BusinessCase.Verkauf;

type
  // -------------------------------------------------------
  // State Machine Tests
  // -------------------------------------------------------
  [TestFixture]
  TStateMachineTests = class
  private
    FVerkauf : TVerkauf;
    FBC      : TVerkaufBC;
    procedure SetupMinimalVerkauf;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_InitialState_IsInteressent;

    [Test]
    procedure Test_Transition_Interessent_ToProbefahrt_OK;

    [Test]
    procedure Test_Transition_Interessent_ToVerifikation_NotAllowed;

    [Test]
    procedure Test_Transition_ToAbgebrochen_AlwaysPossible;

    [Test]
    procedure Test_StateHistory_TracksTransitions;

    [Test]
    procedure Test_FinalState_CannotTransition;

    [Test]
    [WillRaise(TStateException)]
    procedure Test_InvalidTransition_RaisesException;
  end;

  // -------------------------------------------------------
  // Verkauf Validierungs-Tests
  // -------------------------------------------------------
  [TestFixture]
  TVerkaufValidierungTests = class
  private
    FVerkauf: TVerkauf;
    FBC     : TVerkaufBC;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_Interessent_OhneKunde_IsInvalid;

    [Test]
    procedure Test_Interessent_OhneFahrzeug_IsInvalid;

    [Test]
    procedure Test_Interessent_MitAllemNoetigem_IsValid;

    [Test]
    procedure Test_Verifikation_OhneSchufa_IsInvalid;

    [Test]
    procedure Test_Verifikation_OhnePostident_IsInvalid;

    [Test]
    procedure Test_Verifikation_OhneBankbestaetigung_IsInvalid;

    [Test]
    procedure Test_Verifikation_AllesVorhanden_IsValid;

    [Test]
    procedure Test_Kaufvertrag_OhnePreis_IsInvalid;

    [Test]
    procedure Test_Zahlung_OhneEingang_IsInvalid;

    [Test]
    procedure Test_Uebergabe_OhneSchluessel_IsInvalid;

    [Test]
    procedure Test_Uebergabe_OhneKaufvertragScan_IsInvalid;
  end;

  // -------------------------------------------------------
  // Modell-Berechnungs-Tests
  // -------------------------------------------------------
  [TestFixture]
  TFahrzeugModelTests = class
  private
    FFahrzeug: TFahrzeug;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_LeistungPS_KorrektBerechnet;

    [Test]
    procedure Test_EffektiverPreis_OhneRabatt;

    [Test]
    procedure Test_EffektiverPreis_MitProzentRabatt;

    [Test]
    procedure Test_EffektiverPreis_MitBetragRabatt;

    [Test]
    procedure Test_EffektiverPreis_NieNegativ;

    [Test]
    procedure Test_TitelbildUrl_ErstesBild_WennKeinTitelbild;

    [Test]
    procedure Test_MarkeModellBaujahr_KorrektesFormat;
  end;

  // -------------------------------------------------------
  // Leasing-Berechnungs-Tests
  // -------------------------------------------------------
  [TestFixture]
  TLeasingModelTests = class
  private
    FLeasing: TLeasing;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_GesamtKosten_KorrektBerechnet;

    [Test]
    procedure Test_OffeneZahlungen_NurAusstehende;

    [Test]
    procedure Test_NaechsteFaelligkeit_FruehesteDatum;

    [Test]
    procedure Test_Zahlung_Differenz_Korrekt;

    [Test]
    procedure Test_Zahlung_Ueberfaellig_WennVergangen;
  end;

  // -------------------------------------------------------
  // Reparatur-Tests
  // -------------------------------------------------------
  [TestFixture]
  TReparaturModelTests = class
  private
    FReparatur: TReparatur;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_KvaGesamt_SummeArbeitUndMaterial;

    [Test]
    procedure Test_PositionenGesamt_SummeAllerPositionen;

    [Test]
    procedure Test_ReparaturPosition_GesamtPreisBerechnet;
  end;

  // -------------------------------------------------------
  // Filter-Tests
  // -------------------------------------------------------
  [TestFixture]
  TFahrzeugFilterTests = class
  private
    FFilter: TFahrzeugFilterImpl;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_Reset_AllesFelderLeer;

    [Test]
    procedure Test_PartialMatch_StandardmaessigTrue;

    [Test]
    procedure Test_AusstattungIds_KoennenGesetztWerden;
  end;

implementation

// -------------------------------------------------------
// TStateMachineTests
// -------------------------------------------------------

procedure TStateMachineTests.SetupMinimalVerkauf;
begin
  FVerkauf.KundeId    := 1;
  FVerkauf.FahrzeugId := 1;
  FVerkauf.StateCode  := '';
end;

procedure TStateMachineTests.Setup;
begin
  FVerkauf := TVerkauf.Create;
  SetupMinimalVerkauf;
  FBC := TVerkaufBC.Create(FVerkauf);
end;

procedure TStateMachineTests.TearDown;
begin
  FBC.Free;
  FVerkauf.Free;
end;

procedure TStateMachineTests.Test_InitialState_IsInteressent;
begin
  Assert.AreEqual(SC_V_INTERESSENT, FBC.GetCurrentStateCode,
    'Anfangszustand muss INTERESSENT sein');
end;

procedure TStateMachineTests.Test_Transition_Interessent_ToProbefahrt_OK;
begin
  Assert.IsTrue(FBC.CanAdvanceTo(SC_V_PROBEFAHRT),
    'Übergang Interessent → Probefahrt muss erlaubt sein');
end;

procedure TStateMachineTests.Test_Transition_Interessent_ToVerifikation_NotAllowed;
begin
  Assert.IsFalse(FBC.CanAdvanceTo(SC_V_VERIFIKATION),
    'Direkter Übergang Interessent → Verifikation darf nicht erlaubt sein');
end;

procedure TStateMachineTests.Test_Transition_ToAbgebrochen_AlwaysPossible;
begin
  Assert.IsTrue(FBC.CanAdvanceTo(SC_V_ABGEBROCHEN),
    'Abbruch muss von Interessent möglich sein');
  FBC.Abort('Test');
  Assert.AreEqual(SC_V_ABGEBROCHEN, FBC.GetCurrentStateCode);
end;

procedure TStateMachineTests.Test_StateHistory_TracksTransitions;
var
  History: TArray<TStateCode>;
begin
  FBC.GetStateMachine.TransitionTo(SC_V_PROBEFAHRT, FVerkauf);
  History := FBC.GetStateMachine.GetStateHistory;
  Assert.AreEqual(2, Length(History),
    'History sollte Initial + Probefahrt enthalten');
  Assert.AreEqual(SC_V_INTERESSENT, History[0]);
  Assert.AreEqual(SC_V_PROBEFAHRT, History[1]);
end;

procedure TStateMachineTests.Test_FinalState_CannotTransition;
begin
  FBC.Abort('Test');
  Assert.IsFalse(FBC.CanAdvanceTo(SC_V_INTERESSENT),
    'Finaler State kann nicht weiter transitieren');
  Assert.IsFalse(FBC.CanAdvanceTo(SC_V_PROBEFAHRT));
end;

procedure TStateMachineTests.Test_InvalidTransition_RaisesException;
begin
  // Direkter Sprung Interessent → Kaufvertrag nicht erlaubt
  FBC.GetStateMachine.TransitionTo(SC_V_KAUFVERTRAG, FVerkauf);
end;

// -------------------------------------------------------
// TVerkaufValidierungTests
// -------------------------------------------------------

procedure TVerkaufValidierungTests.Setup;
begin
  FVerkauf := TVerkauf.Create;
  FBC := TVerkaufBC.Create(FVerkauf);
end;

procedure TVerkaufValidierungTests.TearDown;
begin
  FBC.Free;
  FVerkauf.Free;
end;

procedure TVerkaufValidierungTests.Test_Interessent_OhneKunde_IsInvalid;
begin
  FVerkauf.KundeId    := 0;
  FVerkauf.FahrzeugId := 1;
  Assert.IsFalse(FBC.Validate.IsValid, 'Ohne Kunde muss Validierung fehlschlagen');
end;

procedure TVerkaufValidierungTests.Test_Interessent_OhneFahrzeug_IsInvalid;
begin
  FVerkauf.KundeId    := 1;
  FVerkauf.FahrzeugId := 0;
  Assert.IsFalse(FBC.Validate.IsValid, 'Ohne Fahrzeug muss Validierung fehlschlagen');
end;

procedure TVerkaufValidierungTests.Test_Interessent_MitAllemNoetigem_IsValid;
begin
  FVerkauf.KundeId    := 1;
  FVerkauf.FahrzeugId := 1;
  Assert.IsTrue(FBC.Validate.IsValid, 'Mit Kunde und Fahrzeug muss Validierung OK sein');
end;

procedure TVerkaufValidierungTests.Test_Verifikation_OhneSchufa_IsInvalid;
var
  VerifState: TVerkaufState_Verifikation;
begin
  VerifState := TVerkaufState_Verifikation.Create;
  try
    FVerkauf.PostidentRef    := 'REF001';
    FVerkauf.BankBestaetigt  := True;
    FVerkauf.SchufaDocPfad   := '';  // Fehlt
    Assert.IsFalse(VerifState.Validate(FVerkauf).IsValid);
  finally
    VerifState.Free;
  end;
end;

procedure TVerkaufValidierungTests.Test_Verifikation_OhnePostident_IsInvalid;
var
  VerifState: TVerkaufState_Verifikation;
begin
  VerifState := TVerkaufState_Verifikation.Create;
  try
    FVerkauf.SchufaDocPfad  := '/docs/schufa.pdf';
    FVerkauf.BankBestaetigt := True;
    FVerkauf.PostidentRef   := '';  // Fehlt
    Assert.IsFalse(VerifState.Validate(FVerkauf).IsValid);
  finally
    VerifState.Free;
  end;
end;

procedure TVerkaufValidierungTests.Test_Verifikation_OhneBankbestaetigung_IsInvalid;
var
  VerifState: TVerkaufState_Verifikation;
begin
  VerifState := TVerkaufState_Verifikation.Create;
  try
    FVerkauf.SchufaDocPfad  := '/docs/schufa.pdf';
    FVerkauf.PostidentRef   := 'REF001';
    FVerkauf.BankBestaetigt := False;  // Fehlt
    Assert.IsFalse(VerifState.Validate(FVerkauf).IsValid);
  finally
    VerifState.Free;
  end;
end;

procedure TVerkaufValidierungTests.Test_Verifikation_AllesVorhanden_IsValid;
var
  VerifState: TVerkaufState_Verifikation;
begin
  VerifState := TVerkaufState_Verifikation.Create;
  try
    FVerkauf.SchufaDocPfad  := '/docs/schufa.pdf';
    FVerkauf.PostidentRef   := 'REF001';
    FVerkauf.BankBestaetigt := True;
    Assert.IsTrue(VerifState.Validate(FVerkauf).IsValid);
  finally
    VerifState.Free;
  end;
end;

procedure TVerkaufValidierungTests.Test_Kaufvertrag_OhnePreis_IsInvalid;
var
  KvState: TVerkaufState_Kaufvertrag;
begin
  KvState := TVerkaufState_Kaufvertrag.Create;
  try
    FVerkauf.VereinbarterPreis := 0;
    Assert.IsFalse(KvState.Validate(FVerkauf).IsValid);
  finally
    KvState.Free;
  end;
end;

procedure TVerkaufValidierungTests.Test_Zahlung_OhneEingang_IsInvalid;
var
  ZState: TVerkaufState_Zahlung;
begin
  ZState := TVerkaufState_Zahlung.Create;
  try
    FVerkauf.ZahlungseingangAm := 0;
    Assert.IsFalse(ZState.Validate(FVerkauf).IsValid);
  finally
    ZState.Free;
  end;
end;

procedure TVerkaufValidierungTests.Test_Uebergabe_OhneSchluessel_IsInvalid;
var
  UState: TVerkaufState_Übergabe;
begin
  UState := TVerkaufState_Übergabe.Create;
  try
    FVerkauf.SchluessselUebergabe := False;
    FVerkauf.KaufvertragPfad      := '/docs/kv.pdf';
    FVerkauf.QuittungPfad         := '/docs/q.pdf';
    Assert.IsFalse(UState.Validate(FVerkauf).IsValid);
  finally
    UState.Free;
  end;
end;

procedure TVerkaufValidierungTests.Test_Uebergabe_OhneKaufvertragScan_IsInvalid;
var
  UState: TVerkaufState_Übergabe;
begin
  UState := TVerkaufState_Übergabe.Create;
  try
    FVerkauf.SchluessselUebergabe := True;
    FVerkauf.KaufvertragPfad      := '';  // Fehlt
    FVerkauf.QuittungPfad         := '/docs/q.pdf';
    Assert.IsFalse(UState.Validate(FVerkauf).IsValid);
  finally
    UState.Free;
  end;
end;

// -------------------------------------------------------
// TFahrzeugModelTests
// -------------------------------------------------------

procedure TFahrzeugModelTests.Setup;
begin
  FFahrzeug := TFahrzeug.Create;
  FFahrzeug.Marke  := 'BMW';
  FFahrzeug.Modell := '3er';
  FFahrzeug.Baujahr := 2020;
  FFahrzeug.Verkaufspreis := 25000;
  FFahrzeug.LeistungKW := 110;
end;

procedure TFahrzeugModelTests.TearDown;
begin
  FFahrzeug.Free;
end;

procedure TFahrzeugModelTests.Test_LeistungPS_KorrektBerechnet;
begin
  // 110 kW * 1.35962 = ca. 149 PS
  Assert.AreEqual(149, FFahrzeug.LeistungPS,
    'Leistung in PS muss korrekt berechnet sein');
end;

procedure TFahrzeugModelTests.Test_EffektiverPreis_OhneRabatt;
begin
  Assert.AreEqual(25000.0, FFahrzeug.EffektiverPreis, 0.01,
    'Ohne Rabatt muss effektiver Preis = Verkaufspreis sein');
end;

procedure TFahrzeugModelTests.Test_EffektiverPreis_MitProzentRabatt;
var
  Rabatt: TRabatt;
begin
  Rabatt := TRabatt.Create;
  Rabatt.Prozent := 10;  // 10%
  Rabatt.Betrag  := 0;
  FFahrzeug.Rabatte.Add(Rabatt);
  Assert.AreEqual(22500.0, FFahrzeug.EffektiverPreis, 0.01,
    '10% Rabatt auf 25000 = 22500');
end;

procedure TFahrzeugModelTests.Test_EffektiverPreis_MitBetragRabatt;
var
  Rabatt: TRabatt;
begin
  Rabatt := TRabatt.Create;
  Rabatt.Prozent := 0;
  Rabatt.Betrag  := 2000;
  FFahrzeug.Rabatte.Add(Rabatt);
  Assert.AreEqual(23000.0, FFahrzeug.EffektiverPreis, 0.01,
    '2000 EUR Rabatt auf 25000 = 23000');
end;

procedure TFahrzeugModelTests.Test_EffektiverPreis_NieNegativ;
var
  Rabatt: TRabatt;
begin
  Rabatt := TRabatt.Create;
  Rabatt.Betrag := 99999;  // Mehr als Preis
  FFahrzeug.Rabatte.Add(Rabatt);
  Assert.IsTrue(FFahrzeug.EffektiverPreis >= 0,
    'Effektiver Preis darf nie negativ sein');
end;

procedure TFahrzeugModelTests.Test_TitelbildUrl_ErstesBild_WennKeinTitelbild;
var
  Bild: TFahrzeugBild;
begin
  Bild := TFahrzeugBild.Create;
  Bild.Url         := 'http://example.com/auto1.jpg';
  Bild.IstTitelbild:= False;
  FFahrzeug.Bilder.Add(Bild);
  Assert.AreEqual('http://example.com/auto1.jpg', FFahrzeug.TitelbildUrl,
    'Erstes Bild muss als Titelbild verwendet werden');
end;

procedure TFahrzeugModelTests.Test_MarkeModellBaujahr_KorrektesFormat;
begin
  Assert.AreEqual('BMW 3er (2020)', FFahrzeug.MarkeModellBaujahr);
end;

// -------------------------------------------------------
// TLeasingModelTests
// -------------------------------------------------------

procedure TLeasingModelTests.Setup;
begin
  FLeasing := TLeasing.Create;
  FLeasing.LaufzeitMonate  := 36;
  FLeasing.MonatlicheRate  := 500;
  FLeasing.Anzahlung       := 3000;
end;

procedure TLeasingModelTests.TearDown;
begin
  FLeasing.Free;
end;

procedure TLeasingModelTests.Test_GesamtKosten_KorrektBerechnet;
begin
  // 3000 + (500 * 36) = 21000
  Assert.AreEqual(21000.0, FLeasing.GesamtKosten, 0.01);
end;

procedure TLeasingModelTests.Test_OffeneZahlungen_NurAusstehende;
var
  Z1, Z2: TLeasingZahlung;
begin
  Z1 := TLeasingZahlung.Create;
  Z1.Betrag  := 500;
  Z1.Status  := 'Ausstehend';
  Z2 := TLeasingZahlung.Create;
  Z2.Betrag  := 500;
  Z2.Status  := 'Eingegangen';
  FLeasing.Zahlungen.Add(Z1);
  FLeasing.Zahlungen.Add(Z2);
  Assert.AreEqual(500.0, FLeasing.OffeneZahlungen, 0.01,
    'Nur ausstehende Zahlungen zählen');
end;

procedure TLeasingModelTests.Test_NaechsteFaelligkeit_FruehesteDatum;
var
  Z1, Z2: TLeasingZahlung;
begin
  Z1 := TLeasingZahlung.Create;
  Z1.Faelligkeit := EncodeDate(2025, 3, 1);
  Z1.Status      := 'Ausstehend';
  Z2 := TLeasingZahlung.Create;
  Z2.Faelligkeit := EncodeDate(2025, 2, 1);  // Früher
  Z2.Status      := 'Ausstehend';
  FLeasing.Zahlungen.Add(Z1);
  FLeasing.Zahlungen.Add(Z2);
  Assert.AreEqual(EncodeDate(2025, 2, 1), FLeasing.NaechsteFaelligkeit,
    'Früheste offene Zahlung muss zurückgegeben werden');
end;

procedure TLeasingModelTests.Test_Zahlung_Differenz_Korrekt;
var
  Z: TLeasingZahlung;
begin
  Z := TLeasingZahlung.Create;
  try
    Z.Betrag              := 500;
    Z.EingegangenerBetrag := 450;
    Assert.AreEqual(50.0, Z.Differenz, 0.01, 'Differenz = 500 - 450 = 50');
  finally
    Z.Free;
  end;
end;

procedure TLeasingModelTests.Test_Zahlung_Ueberfaellig_WennVergangen;
var
  Z: TLeasingZahlung;
begin
  Z := TLeasingZahlung.Create;
  try
    Z.Faelligkeit := Date - 1;  // Gestern
    Z.Status      := 'Ausstehend';
    Assert.IsTrue(Z.IstUeberfaellig, 'Vergangene ausstehende Zahlung ist überfällig');
  finally
    Z.Free;
  end;
end;

// -------------------------------------------------------
// TReparaturModelTests
// -------------------------------------------------------

procedure TReparaturModelTests.Setup;
begin
  FReparatur := TReparatur.Create;
  FReparatur.KvaArbeit   := 300;
  FReparatur.KvaMaterial := 150;
end;

procedure TReparaturModelTests.TearDown;
begin
  FReparatur.Free;
end;

procedure TReparaturModelTests.Test_KvaGesamt_SummeArbeitUndMaterial;
begin
  Assert.AreEqual(450.0, FReparatur.KvaGesamt, 0.01,
    'KVA Gesamt = Arbeit + Material');
end;

procedure TReparaturModelTests.Test_PositionenGesamt_SummeAllerPositionen;
var
  P1, P2: TReparaturPosition;
begin
  P1 := TReparaturPosition.Create;
  P1.Menge        := 2;
  P1.Einzelpreis  := 50;
  P2 := TReparaturPosition.Create;
  P2.Menge        := 1;
  P2.Einzelpreis  := 200;
  FReparatur.Positionen.Add(P1);
  FReparatur.Positionen.Add(P2);
  Assert.AreEqual(300.0, FReparatur.RechnungGesamtBerechnet, 0.01,
    '2*50 + 1*200 = 300');
end;

procedure TReparaturModelTests.Test_ReparaturPosition_GesamtPreisBerechnet;
var
  P: TReparaturPosition;
begin
  P := TReparaturPosition.Create;
  try
    P.Menge       := 3;
    P.Einzelpreis := 75;
    Assert.AreEqual(225.0, P.Gesamtpreis, 0.01, '3 * 75 = 225');
  finally
    P.Free;
  end;
end;

// -------------------------------------------------------
// TFahrzeugFilterTests
// -------------------------------------------------------

procedure TFahrzeugFilterTests.Setup;
begin
  FFilter := TFahrzeugFilterImpl.Create;
end;

procedure TFahrzeugFilterTests.TearDown;
begin
  FFilter.Free;
end;

procedure TFahrzeugFilterTests.Test_Reset_AllesFelderLeer;
begin
  FFilter.MarkeId  := 5;
  FFilter.PreisVon := 1000;
  FFilter.Reset;
  Assert.AreEqual(0, FFilter.MarkeId);
  Assert.AreEqual(0.0, FFilter.PreisVon, 0.01);
  Assert.AreEqual('', FFilter.Suchtext);
end;

procedure TFahrzeugFilterTests.Test_PartialMatch_StandardmaessigTrue;
begin
  Assert.IsTrue(FFilter.PartialMatch,
    'Partial Match muss standardmäßig aktiv sein');
end;

procedure TFahrzeugFilterTests.Test_AusstattungIds_KoennenGesetztWerden;
begin
  FFilter.AusstattungIds := [1, 2, 5, 10];
  Assert.AreEqual(4, Length(FFilter.AusstattungIds));
  Assert.AreEqual(5, FFilter.AusstattungIds[2]);
end;

initialization
  TDUnitX.RegisterTestFixture(TStateMachineTests);
  TDUnitX.RegisterTestFixture(TVerkaufValidierungTests);
  TDUnitX.RegisterTestFixture(TFahrzeugModelTests);
  TDUnitX.RegisterTestFixture(TLeasingModelTests);
  TDUnitX.RegisterTestFixture(TReparaturModelTests);
  TDUnitX.RegisterTestFixture(TFahrzeugFilterTests);

end.
