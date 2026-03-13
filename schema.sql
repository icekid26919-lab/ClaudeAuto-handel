-- ============================================================
-- AutoHandel MariaDB Schema
-- Version: 1.0
-- ============================================================

SET FOREIGN_KEY_CHECKS=0;
SET NAMES utf8mb4;

-- ============================================================
-- STAMMDATEN
-- ============================================================

CREATE DATABASE IF NOT EXISTS autohandel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE autohandel;

-- Automarken
CREATE TABLE IF NOT EXISTS tbl_marke (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    land        VARCHAR(100),
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Modelle
CREATE TABLE IF NOT EXISTS tbl_modell (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    marke_id    INT NOT NULL,
    name        VARCHAR(100) NOT NULL,
    baujahr_von SMALLINT,
    baujahr_bis SMALLINT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (marke_id) REFERENCES tbl_marke(id)
) ENGINE=InnoDB;

-- Ausstattungsmerkmale
CREATE TABLE IF NOT EXISTS tbl_ausstattung_merkmal (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    kategorie   VARCHAR(50) NOT NULL,  -- 'Sicherheit','Komfort','Technik','Exterieur'
    name        VARCHAR(100) NOT NULL,
    beschreibung TEXT
) ENGINE=InnoDB;

-- Garantiearten
CREATE TABLE IF NOT EXISTS tbl_garantieart (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    monate      INT,
    beschreibung TEXT
) ENGINE=InnoDB;

-- Kraftstoffarten
CREATE TABLE IF NOT EXISTS tbl_kraftstoff (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL  -- 'Benzin','Diesel','Elektro','Hybrid','Gas'
) ENGINE=InnoDB;

-- Getriebe
CREATE TABLE IF NOT EXISTS tbl_getriebe (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL  -- 'Automatik','Manuell','Halbautomatik'
) ENGINE=InnoDB;

-- Farben
CREATE TABLE IF NOT EXISTS tbl_farbe (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(50) NOT NULL,
    hex_code   CHAR(7)
) ENGINE=InnoDB;

-- Mitarbeiter
CREATE TABLE IF NOT EXISTS tbl_mitarbeiter (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    vorname         VARCHAR(100) NOT NULL,
    nachname        VARCHAR(100) NOT NULL,
    email           VARCHAR(200) UNIQUE,
    telefon         VARCHAR(50),
    rolle           ENUM('Verkäufer','Mechaniker','Admin','Manager') NOT NULL,
    filiale_id      INT,
    aktiv           TINYINT(1) DEFAULT 1,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Filialen / Verkaufsstellen
CREATE TABLE IF NOT EXISTS tbl_filiale (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    strasse     VARCHAR(200),
    plz         VARCHAR(10),
    ort         VARCHAR(100),
    land        VARCHAR(100) DEFAULT 'Deutschland',
    lat         DECIMAL(10,7),
    lng         DECIMAL(10,7),
    telefon     VARCHAR(50),
    email       VARCHAR(200),
    aktiv       TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

ALTER TABLE tbl_mitarbeiter ADD FOREIGN KEY (filiale_id) REFERENCES tbl_filiale(id);

-- Kunden
CREATE TABLE IF NOT EXISTS tbl_kunde (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    anrede          ENUM('Herr','Frau','Divers','Firma'),
    vorname         VARCHAR(100),
    nachname        VARCHAR(100) NOT NULL,
    firma           VARCHAR(200),
    strasse         VARCHAR(200),
    plz             VARCHAR(10),
    ort             VARCHAR(100),
    land            VARCHAR(100) DEFAULT 'Deutschland',
    email           VARCHAR(200),
    telefon         VARCHAR(50),
    mobil           VARCHAR(50),
    geburtsdatum    DATE,
    fuehrerschein_nr VARCHAR(50),
    iban            VARCHAR(34),
    bic             VARCHAR(11),
    bank_name       VARCHAR(100),
    schufa_status   ENUM('Ausstehend','Positiv','Negativ','Nicht_Geprüft') DEFAULT 'Nicht_Geprüft',
    postident_status ENUM('Ausstehend','Verifiziert','Abgelehnt','Nicht_Geprüft') DEFAULT 'Nicht_Geprüft',
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- FAHRZEUGE
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_fahrzeug (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    interne_nr          VARCHAR(50) UNIQUE NOT NULL,
    marke_id            INT NOT NULL,
    modell_id           INT NOT NULL,
    baujahr             SMALLINT NOT NULL,
    erstzulassung       DATE,
    kraftstoff_id       INT,
    getriebe_id         INT,
    farbe_id            INT,
    hubraum_ccm         INT,
    leistung_kw         INT,
    leistung_ps         INT AS (ROUND(leistung_kw * 1.35962)) STORED,
    kilometerstand      INT NOT NULL DEFAULT 0,
    tuev_datum          DATE,
    anzahl_vorbesitzer  TINYINT DEFAULT 0,
    unfallfahrzeug      TINYINT(1) DEFAULT 0,
    raucher_fahrzeug    TINYINT(1) DEFAULT 0,
    vin                 VARCHAR(17) UNIQUE,
    -- Preise
    einkaufspreis       DECIMAL(12,2),
    verkaufspreis       DECIMAL(12,2) NOT NULL,
    minimalpreis        DECIMAL(12,2),
    -- Status
    status              ENUM('Verfügbar','Reserviert','Verkauft','In_Reparatur','Angekauft','Leasing','Gelöscht')
                        DEFAULT 'Verfügbar',
    -- Beschreibung
    beschreibung        TEXT,
    -- Metadaten
    eingestellt_am      DATETIME DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (marke_id) REFERENCES tbl_marke(id),
    FOREIGN KEY (modell_id) REFERENCES tbl_modell(id),
    FOREIGN KEY (kraftstoff_id) REFERENCES tbl_kraftstoff(id),
    FOREIGN KEY (getriebe_id) REFERENCES tbl_getriebe(id),
    FOREIGN KEY (farbe_id) REFERENCES tbl_farbe(id)
) ENGINE=InnoDB;

-- Fahrzeugbilder
CREATE TABLE IF NOT EXISTS tbl_fahrzeug_bild (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    fahrzeug_id INT NOT NULL,
    dateiname   VARCHAR(300) NOT NULL,
    url         VARCHAR(500),
    ist_titelbild TINYINT(1) DEFAULT 0,
    reihenfolge INT DEFAULT 0,
    erstellt_am DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Fahrzeug-Ausstattung (N:M)
CREATE TABLE IF NOT EXISTS tbl_fahrzeug_ausstattung (
    fahrzeug_id     INT NOT NULL,
    merkmal_id      INT NOT NULL,
    PRIMARY KEY (fahrzeug_id, merkmal_id),
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id) ON DELETE CASCADE,
    FOREIGN KEY (merkmal_id) REFERENCES tbl_ausstattung_merkmal(id)
) ENGINE=InnoDB;

-- Fahrzeug-Garantien (N:M)
CREATE TABLE IF NOT EXISTS tbl_fahrzeug_garantie (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    fahrzeug_id     INT NOT NULL,
    garantieart_id  INT NOT NULL,
    gueltig_bis     DATE,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id) ON DELETE CASCADE,
    FOREIGN KEY (garantieart_id) REFERENCES tbl_garantieart(id)
) ENGINE=InnoDB;

-- Rabatte / Zuschüsse
CREATE TABLE IF NOT EXISTS tbl_rabatt (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    fahrzeug_id     INT NOT NULL,
    art             ENUM('Rabatt','Zuschuss','Sonderaktion') NOT NULL,
    bezeichnung     VARCHAR(200),
    betrag          DECIMAL(10,2),
    prozent         DECIMAL(5,2),
    gueltig_von     DATE,
    gueltig_bis     DATE,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TERMINE (gemeinsame Basis für alle BusinessCases)
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_termin (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    art             ENUM('Probefahrt','Besichtigung','Kauf','Ankauf','Werkstatt','Online_Besuch') NOT NULL,
    fahrzeug_id     INT,
    kunde_id        INT,
    mitarbeiter_id  INT,
    filiale_id      INT,
    termin_datum    DATETIME NOT NULL,
    dauer_minuten   INT DEFAULT 60,
    status          ENUM('Angefragt','Bestätigt','Abgesagt','Abgeschlossen','Kein_Erscheinen')
                    DEFAULT 'Angefragt',
    notizen         TEXT,
    video_url       VARCHAR(500),
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id),
    FOREIGN KEY (kunde_id) REFERENCES tbl_kunde(id),
    FOREIGN KEY (mitarbeiter_id) REFERENCES tbl_mitarbeiter(id),
    FOREIGN KEY (filiale_id) REFERENCES tbl_filiale(id)
) ENGINE=InnoDB;

-- ============================================================
-- BUSINESS CASE STATES (Workflow-Tabellen)
-- ============================================================

-- BC State Definitionen
CREATE TABLE IF NOT EXISTS tbl_bc_state_definition (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    bc_art      VARCHAR(50) NOT NULL,  -- 'Verkauf','Ankauf','Leasing','Reparatur'
    state_name  VARCHAR(100) NOT NULL,
    state_code  VARCHAR(50) NOT NULL,
    reihenfolge INT NOT NULL,
    ist_final   TINYINT(1) DEFAULT 0,
    beschreibung TEXT
) ENGINE=InnoDB;

-- BC State Übergänge
CREATE TABLE IF NOT EXISTS tbl_bc_state_transition (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    von_state_id    INT NOT NULL,
    zu_state_id     INT NOT NULL,
    bedingung       TEXT,
    FOREIGN KEY (von_state_id) REFERENCES tbl_bc_state_definition(id),
    FOREIGN KEY (zu_state_id) REFERENCES tbl_bc_state_definition(id)
) ENGINE=InnoDB;

-- ============================================================
-- AUTO-VERKAUF (BusinessCase)
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_verkauf (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    fahrzeug_id         INT NOT NULL,
    kunde_id            INT NOT NULL,
    mitarbeiter_id      INT,
    state_code          VARCHAR(50) NOT NULL DEFAULT 'INTERESSENT',
    -- Verifikation
    schufa_doc_pfad     VARCHAR(500),
    schufa_geprueft_am  DATETIME,
    postident_ref       VARCHAR(100),
    postident_geprueft_am DATETIME,
    bank_bestätigt      TINYINT(1) DEFAULT 0,
    -- Kaufdetails
    vereinbarter_preis  DECIMAL(12,2),
    anzahlung           DECIMAL(12,2),
    finanzierung        TINYINT(1) DEFAULT 0,
    zahlungseingang_am  DATETIME,
    -- Übergabe
    übergabe_datum      DATETIME,
    übergabe_ort        VARCHAR(300),
    schluessel_uebergabe TINYINT(1) DEFAULT 0,
    kaufvertrag_nr      VARCHAR(100),
    kaufvertrag_pfad    VARCHAR(500),
    quittung_pfad       VARCHAR(500),
    -- Metadaten
    erstellt_am         DATETIME DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id),
    FOREIGN KEY (kunde_id) REFERENCES tbl_kunde(id),
    FOREIGN KEY (mitarbeiter_id) REFERENCES tbl_mitarbeiter(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tbl_verkauf_state_history (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    verkauf_id      INT NOT NULL,
    von_state       VARCHAR(50),
    zu_state        VARCHAR(50) NOT NULL,
    mitarbeiter_id  INT,
    notiz           TEXT,
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (verkauf_id) REFERENCES tbl_verkauf(id),
    FOREIGN KEY (mitarbeiter_id) REFERENCES tbl_mitarbeiter(id)
) ENGINE=InnoDB;

-- ============================================================
-- AUTO-ANKAUF (BusinessCase)
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_ankauf (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    fahrzeug_id         INT,  -- NULL bis Fahrzeug angelegt
    kunde_id            INT NOT NULL,
    mitarbeiter_id      INT,
    state_code          VARCHAR(50) NOT NULL DEFAULT 'ANFRAGE',
    -- Digitale Schätzung
    schaetzung_marke    VARCHAR(100),
    schaetzung_modell   VARCHAR(100),
    schaetzung_baujahr  SMALLINT,
    schaetzung_km       INT,
    schaetzung_zustand  ENUM('Sehr_Gut','Gut','Befriedigend','Ausreichend','Mangelhaft'),
    schaetzung_preis_min DECIMAL(12,2),
    schaetzung_preis_max DECIMAL(12,2),
    schaetzung_ergebnis DECIMAL(12,2),
    schaetzung_bericht  TEXT,
    -- Vorführung
    vorfuehrung_datum   DATETIME,
    vorfuehrung_ok      TINYINT(1) DEFAULT 0,
    -- Ankauf
    vereinbarter_preis  DECIMAL(12,2),
    auszahlung_datum    DATETIME,
    auszahlung_betrag   DECIMAL(12,2),
    -- Metadaten
    erstellt_am         DATETIME DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id),
    FOREIGN KEY (kunde_id) REFERENCES tbl_kunde(id),
    FOREIGN KEY (mitarbeiter_id) REFERENCES tbl_mitarbeiter(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tbl_ankauf_state_history (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    ankauf_id       INT NOT NULL,
    von_state       VARCHAR(50),
    zu_state        VARCHAR(50) NOT NULL,
    mitarbeiter_id  INT,
    notiz           TEXT,
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ankauf_id) REFERENCES tbl_ankauf(id)
) ENGINE=InnoDB;

-- ============================================================
-- AUTO-LEASING (BusinessCase)
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_leasing (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    fahrzeug_id             INT NOT NULL,
    kunde_id                INT NOT NULL,
    mitarbeiter_id          INT,
    state_code              VARCHAR(50) NOT NULL DEFAULT 'ANFRAGE',
    -- Konditionen
    laufzeit_monate         INT NOT NULL,
    monatliche_rate         DECIMAL(10,2) NOT NULL,
    anzahlung               DECIMAL(12,2) DEFAULT 0,
    restwert                DECIMAL(12,2),
    km_limit_jaehrlich      INT,
    km_preis_ueber          DECIMAL(8,4),  -- Preis pro km über Limit
    -- Daten
    vertrag_nr              VARCHAR(100),
    vertrag_beginn          DATE,
    vertrag_ende            DATE,
    vertrag_pfad            VARCHAR(500),
    -- Rückgabe
    rueckgabe_km            INT,
    rueckgabe_datum         DATE,
    rueckgabe_zustand       TEXT,
    schlussrechnung_betrag  DECIMAL(12,2),
    -- Metadaten
    erstellt_am             DATETIME DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am         DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id),
    FOREIGN KEY (kunde_id) REFERENCES tbl_kunde(id),
    FOREIGN KEY (mitarbeiter_id) REFERENCES tbl_mitarbeiter(id)
) ENGINE=InnoDB;

-- Leasing-Zahlungsplan
CREATE TABLE IF NOT EXISTS tbl_leasing_zahlung (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    leasing_id      INT NOT NULL,
    faelligkeit     DATE NOT NULL,
    betrag          DECIMAL(10,2) NOT NULL,
    art             ENUM('Anzahlung','Monatlich','Abschluss','Nachzahlung') NOT NULL,
    status          ENUM('Ausstehend','Eingegangen','Überfällig','Storniert') DEFAULT 'Ausstehend',
    eingegangen_am  DATETIME,
    eingegangen_betrag DECIMAL(10,2),
    differenz       DECIMAL(10,2) AS (betrag - COALESCE(eingegangen_betrag, 0)) STORED,
    notiz           TEXT,
    FOREIGN KEY (leasing_id) REFERENCES tbl_leasing(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tbl_leasing_state_history (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    leasing_id      INT NOT NULL,
    von_state       VARCHAR(50),
    zu_state        VARCHAR(50) NOT NULL,
    mitarbeiter_id  INT,
    notiz           TEXT,
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leasing_id) REFERENCES tbl_leasing(id)
) ENGINE=InnoDB;

-- ============================================================
-- WERKSTATT / REPARATUR (BusinessCase)
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_reparatur (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    fahrzeug_id         INT NOT NULL,
    kunde_id            INT,
    mechaniker_id       INT,
    state_code          VARCHAR(50) NOT NULL DEFAULT 'ANNAHME',
    art                 ENUM('Reparatur','Wartung','Modifikation','Inspektion','Garantie') NOT NULL,
    -- Diagnose
    diagnose_datum      DATETIME,
    diagnose_text       TEXT,
    km_bei_annahme      INT,
    -- Kostenvoranschlag
    kva_erstellt_am     DATETIME,
    kva_arbeit          DECIMAL(10,2),
    kva_material        DECIMAL(10,2),
    kva_gesamt          DECIMAL(10,2) AS (COALESCE(kva_arbeit,0) + COALESCE(kva_material,0)) STORED,
    kva_genehmigt       TINYINT(1) DEFAULT 0,
    kva_genehmigt_am    DATETIME,
    -- Rechnung
    rechnung_nr         VARCHAR(100),
    rechnung_arbeit     DECIMAL(10,2),
    rechnung_material   DECIMAL(10,2),
    rechnung_gesamt     DECIMAL(10,2),
    rechnung_datum      DATETIME,
    -- Garantiefall
    ist_garantiefall    TINYINT(1) DEFAULT 0,
    garantie_ref        VARCHAR(100),
    -- Fertigstellung
    fertiggestellt_am   DATETIME,
    abgeholt_am         DATETIME,
    -- Metadaten
    erstellt_am         DATETIME DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (fahrzeug_id) REFERENCES tbl_fahrzeug(id),
    FOREIGN KEY (kunde_id) REFERENCES tbl_kunde(id),
    FOREIGN KEY (mechaniker_id) REFERENCES tbl_mitarbeiter(id)
) ENGINE=InnoDB;

-- Reparatur-Positionen
CREATE TABLE IF NOT EXISTS tbl_reparatur_position (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    reparatur_id    INT NOT NULL,
    art             ENUM('Arbeit','Material','Ersatzteil') NOT NULL,
    ersatzteil_id   INT,
    bezeichnung     VARCHAR(300) NOT NULL,
    menge           DECIMAL(10,2) DEFAULT 1,
    einheit         VARCHAR(20) DEFAULT 'Stk',
    einzelpreis     DECIMAL(10,2),
    gesamtpreis     DECIMAL(10,2) AS (menge * COALESCE(einzelpreis,0)) STORED,
    FOREIGN KEY (reparatur_id) REFERENCES tbl_reparatur(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tbl_reparatur_state_history (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    reparatur_id    INT NOT NULL,
    von_state       VARCHAR(50),
    zu_state        VARCHAR(50) NOT NULL,
    mitarbeiter_id  INT,
    notiz           TEXT,
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reparatur_id) REFERENCES tbl_reparatur(id)
) ENGINE=InnoDB;

-- ============================================================
-- ERSATZTEILE / LAGER
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_ersatzteil (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    artikelnummer   VARCHAR(100) UNIQUE NOT NULL,
    bezeichnung     VARCHAR(300) NOT NULL,
    hersteller      VARCHAR(100),
    kompatibel_mit  TEXT,  -- JSON-Array mit Marken/Modellen
    einkaufspreis   DECIMAL(10,2),
    verkaufspreis   DECIMAL(10,2),
    lagerbestand    INT DEFAULT 0,
    mindestbestand  INT DEFAULT 2,
    lagerort        VARCHAR(100),
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    aktualisiert_am DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Ersatzteil-Bestellungen
CREATE TABLE IF NOT EXISTS tbl_ersatzteil_bestellung (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    ersatzteil_id   INT NOT NULL,
    reparatur_id    INT,
    lieferant       VARCHAR(200),
    menge           INT NOT NULL,
    bestelldatum    DATETIME DEFAULT CURRENT_TIMESTAMP,
    lieferdatum_geplant DATE,
    lieferdatum_ist DATETIME,
    status          ENUM('Bestellt','Geliefert','Storniert') DEFAULT 'Bestellt',
    bestellpreis    DECIMAL(10,2),
    FOREIGN KEY (ersatzteil_id) REFERENCES tbl_ersatzteil(id),
    FOREIGN KEY (reparatur_id) REFERENCES tbl_reparatur(id)
) ENGINE=InnoDB;

-- ============================================================
-- ANGEBOTE (gemeinsam für alle BCs)
-- ============================================================

CREATE TABLE IF NOT EXISTS tbl_angebot (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    bc_art          ENUM('Verkauf','Ankauf','Leasing','Reparatur') NOT NULL,
    bc_id           INT NOT NULL,
    kunde_id        INT NOT NULL,
    mitarbeiter_id  INT,
    gueltig_bis     DATE,
    gesamt_betrag   DECIMAL(12,2),
    status          ENUM('Erstellt','Versendet','Angenommen','Abgelehnt','Abgelaufen') DEFAULT 'Erstellt',
    notizen         TEXT,
    pdf_pfad        VARCHAR(500),
    erstellt_am     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kunde_id) REFERENCES tbl_kunde(id),
    FOREIGN KEY (mitarbeiter_id) REFERENCES tbl_mitarbeiter(id)
) ENGINE=InnoDB;

-- ============================================================
-- STATE DEFINITIONS (Initial Data)
-- ============================================================

INSERT INTO tbl_bc_state_definition (bc_art, state_name, state_code, reihenfolge, ist_final, beschreibung) VALUES
-- VERKAUF
('Verkauf','Interessent',       'INTERESSENT',      1,0,'Erstkontakt / Anfrage'),
('Verkauf','Probefahrt',        'PROBEFAHRT',        2,0,'Probefahrt vereinbart/durchgeführt'),
('Verkauf','Angebot',           'ANGEBOT',           3,0,'Angebot erstellt und versendet'),
('Verkauf','Verifikation',      'VERIFIKATION',      4,0,'Schufa/Postident/Bank'),
('Verkauf','Kaufvertrag',       'KAUFVERTRAG',        5,0,'Kaufvertrag erstellt und versendet'),
('Verkauf','Zahlung',           'ZAHLUNG',           6,0,'Warten auf Zahlungseingang'),
('Verkauf','Übergabe',          'ÜBERGABE',          7,0,'Fahrzeugübergabe geplant'),
('Verkauf','Abgeschlossen',     'ABGESCHLOSSEN',      8,1,'Kauf vollständig abgeschlossen'),
('Verkauf','Abgebrochen',       'ABGEBROCHEN',        9,1,'Kauf abgebrochen'),
-- ANKAUF
('Ankauf','Anfrage',            'ANFRAGE',           1,0,'Ankaufsanfrage eingegangen'),
('Ankauf','Digitale_Schätzung', 'DIGITALE_SCHAETZUNG',2,0,'Online-Schätzung durchgeführt'),
('Ankauf','Vorführung',         'VORFUEHRUNG',        3,0,'Fahrzeug wird vorgeführt'),
('Ankauf','Begutachtung',       'BEGUTACHTUNG',      4,0,'Vor-Ort-Prüfung durch Mechaniker'),
('Ankauf','Angebot',            'ANGEBOT',           5,0,'Kaufangebot erstellt'),
('Ankauf','Verifikation',       'VERIFIKATION',      6,0,'Kundenverifizierung'),
('Ankauf','Abschluss',          'ABSCHLUSS',         7,0,'Vertrag unterschrieben'),
('Ankauf','Auszahlung',         'AUSZAHLUNG',        8,0,'Auszahlung erfolgt'),
('Ankauf','Abgeschlossen',      'ABGESCHLOSSEN',      9,1,'Ankauf abgeschlossen'),
('Ankauf','Abgebrochen',        'ABGEBROCHEN',       10,1,'Ankauf abgebrochen'),
-- LEASING
('Leasing','Anfrage',           'ANFRAGE',           1,0,'Leasinganfrage'),
('Leasing','Konfiguration',     'KONFIGURATION',     2,0,'Leasingkonditionen festlegen'),
('Leasing','Verifikation',      'VERIFIKATION',      3,0,'Bonitätsprüfung'),
('Leasing','Vertrag',           'VERTRAG',           4,0,'Leasingvertrag erstellt'),
('Leasing','Anzahlung',         'ANZAHLUNG',         5,0,'Warten auf Anzahlung'),
('Leasing','Aktiv',             'AKTIV',             6,0,'Leasing läuft'),
('Leasing','Mahnung',           'MAHNUNG',           7,0,'Zahlungsverzug'),
('Leasing','Rückgabe',          'RUECKGABE',         8,0,'Fahrzeug wird zurückgegeben'),
('Leasing','Abgeschlossen',     'ABGESCHLOSSEN',      9,1,'Leasing beendet'),
('Leasing','Abgebrochen',       'ABGEBROCHEN',       10,1,'Vorzeitig beendet'),
-- REPARATUR
('Reparatur','Annahme',         'ANNAHME',           1,0,'Fahrzeug angenommen'),
('Reparatur','Diagnose',        'DIAGNOSE',          2,0,'Diagnose läuft'),
('Reparatur','KVA_Erstellt',    'KVA_ERSTELLT',      3,0,'Kostenvoranschlag erstellt'),
('Reparatur','KVA_Genehmigt',   'KVA_GENEHMIGT',     4,0,'KVA durch Kunden genehmigt'),
('Reparatur','In_Arbeit',       'IN_ARBEIT',         5,0,'Reparatur in Durchführung'),
('Reparatur','Teile_Bestellt',  'TEILE_BESTELLT',    6,0,'Ersatzteile bestellt'),
('Reparatur','Qualitätsprüfung','QUALITAETSPRUEFUNG', 7,0,'Abschlusscheck'),
('Reparatur','Fertig',          'FERTIG',            8,0,'Reparatur fertig'),
('Reparatur','Abgeholt',        'ABGEHOLT',          9,1,'Fahrzeug abgeholt'),
('Reparatur','Garantiefall',    'GARANTIEFALL',      10,1,'Als Garantie abgewickelt');

SET FOREIGN_KEY_CHECKS=1;
