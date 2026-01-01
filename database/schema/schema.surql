-- ============================================================
-- AL-MIZAN CANONICAL SCHEMA
-- ============================================================
-- Single source of truth for the Knowledge Graph ontology.
-- Consolidates: 01_ontology.surql, 02_relations.surql, initial_schema.surql
-- Version: 1.0.0
-- ============================================================

OPTION IMPORT;

-- ============================================================
-- SECTION 1: AUTHENTICATION & ACCESS CONTROL
-- ============================================================

DEFINE TABLE user SCHEMAFULL
    PERMISSIONS
        FOR select, update, delete WHERE id = $auth.id
        FOR create FULL;

DEFINE FIELD email ON user TYPE string ASSERT string::is::email($value);
DEFINE FIELD password ON user TYPE string;
DEFINE FIELD role ON user TYPE string ASSERT $value INSIDE ['admin', 'scholar', 'student'];
DEFINE INDEX user_email ON user COLUMNS email UNIQUE;

DEFINE SCOPE allusers
    SESSION 24h
    SIGNUP ( CREATE user SET email = $email, password = crypto::argon2::generate($password), role = 'student' )
    SIGNIN ( SELECT * FROM user WHERE email = $email AND crypto::argon2::compare(password, $password) );

-- ============================================================
-- SECTION 2: TEXT ANALYZERS
-- ============================================================

DEFINE ANALYZER arabic_analyzer TOKENIZERS blank FILTERS lowercase, ascii;

-- ============================================================
-- SECTION 3: THABIT (IMMUTABLE) NODES - Tier 1
-- Sources of Truth. Cannot be modified after creation.
-- ============================================================

-- 3.1 QURAN VERSE
DEFINE TABLE quran_verse SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD text_uthmani ON quran_verse TYPE string;
DEFINE FIELD text_simple ON quran_verse TYPE option<string>;
DEFINE FIELD surah_number ON quran_verse TYPE int;
DEFINE FIELD ayah_number ON quran_verse TYPE int;
DEFINE FIELD juz_number ON quran_verse TYPE int;
DEFINE FIELD revelation_place ON quran_verse TYPE string ASSERT $value INSIDE ['Makkah', 'Madinah'];
DEFINE FIELD mutability ON quran_verse TYPE string DEFAULT 'CONSTANT' ASSERT $value = 'CONSTANT';
-- Provenance
DEFINE FIELD digitized_by ON quran_verse TYPE option<string>;
DEFINE FIELD digitization_date ON quran_verse TYPE datetime DEFAULT time::now();

DEFINE INDEX verse_coords ON quran_verse COLUMNS surah_number, ayah_number UNIQUE;

-- 3.2 HADITH
DEFINE TABLE hadith SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD collection ON hadith TYPE string;
DEFINE FIELD hadith_number ON hadith TYPE int;
DEFINE FIELD matn_ar ON hadith TYPE string;
DEFINE FIELD matn_en ON hadith TYPE option<string>;
DEFINE FIELD mutability ON hadith TYPE string DEFAULT 'CONSTANT' ASSERT $value = 'CONSTANT';
-- Provenance
DEFINE FIELD digitized_by ON hadith TYPE option<string>;
DEFINE FIELD digitization_date ON hadith TYPE datetime DEFAULT time::now();

DEFINE INDEX hadith_ref ON hadith COLUMNS collection, hadith_number UNIQUE;

-- ============================================================
-- SECTION 4: LINGUISTIC & THEMATIC NODES
-- ============================================================

-- 4.1 ROOT WORD (Morphology)
DEFINE TABLE root_word SCHEMAFULL;
DEFINE FIELD root_ar ON root_word TYPE string;
DEFINE FIELD definition_en ON root_word TYPE option<string>;
DEFINE INDEX root_ar_idx ON root_word COLUMNS root_ar UNIQUE;

-- 4.2 CONCEPT (Thematic Ontology)
DEFINE TABLE concept SCHEMAFULL;
DEFINE FIELD name_en ON concept TYPE string;
DEFINE FIELD name_ar ON concept TYPE option<string>;
DEFINE FIELD description ON concept TYPE option<string>;
DEFINE INDEX concept_name ON concept COLUMNS name_en UNIQUE;

-- 4.3 DIVINE NAME (Asma ul Husna)
DEFINE TABLE divine_name SCHEMAFULL;
DEFINE FIELD transliteration ON divine_name TYPE string;
DEFINE FIELD arabic ON divine_name TYPE string;
DEFINE FIELD meaning_en ON divine_name TYPE string;
DEFINE INDEX divine_name_ar ON divine_name COLUMNS arabic UNIQUE;

-- ============================================================
-- SECTION 5: TRANSLATION (ZANNI - Interpretive)
-- Human effort to understand the Divine.
-- ============================================================

DEFINE TABLE translation SCHEMAFULL;
DEFINE FIELD text_en ON translation TYPE string;
DEFINE FIELD translator ON translation TYPE string;
DEFINE FIELD language ON translation TYPE string DEFAULT 'en';

-- ============================================================
-- SECTION 6: SCHOLARS & SCHOOLS (CONTEXT NODES)
-- ============================================================

-- 6.1 MADHAB (School of Thought)
DEFINE TABLE school SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD name ON school TYPE string;
DEFINE FIELD founder ON school TYPE option<string>;
DEFINE INDEX school_name ON school COLUMNS name UNIQUE;

-- 6.2 SCHOLAR
DEFINE TABLE scholar SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD name_ar ON scholar TYPE string;
DEFINE FIELD name_en ON scholar TYPE option<string>;
DEFINE FIELD death_year_ah ON scholar TYPE option<int>;
DEFINE FIELD status ON scholar TYPE string DEFAULT 'active' ASSERT $value INSIDE ['active', 'probationary', 'slashed'];
DEFINE FIELD reputation ON scholar TYPE float DEFAULT 1.0;
-- Provenance
DEFINE FIELD digitized_by ON scholar TYPE option<string>;
DEFINE FIELD digitization_date ON scholar TYPE datetime DEFAULT time::now();

-- ============================================================
-- SECTION 7: FIQH RULING (ZANNI - Mutable)
-- Scholar's derivation. Must be attributed.
-- ============================================================

DEFINE TABLE fiqh_ruling SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE $auth.role IN ['admin', 'scholar'];

DEFINE FIELD text ON fiqh_ruling TYPE string;
DEFINE FIELD hukm ON fiqh_ruling TYPE string ASSERT $value INSIDE ['Wajib', 'Mandub', 'Mubah', 'Makruh', 'Haram'];
DEFINE FIELD madhab ON fiqh_ruling TYPE option<string>;
DEFINE FIELD issued_by ON fiqh_ruling TYPE record<scholar> ASSERT $value != NONE;
DEFINE FIELD mutability ON fiqh_ruling TYPE string DEFAULT 'VARIABLE' ASSERT $value = 'VARIABLE';
DEFINE FIELD status ON fiqh_ruling TYPE string DEFAULT 'draft' ASSERT $value INSIDE ['draft', 'probationary', 'canonical'];
DEFINE FIELD created_at ON fiqh_ruling TYPE datetime DEFAULT time::now();

-- ============================================================
-- SECTION 8: EDGES (RELATIONSHIPS)
-- ============================================================

-- 8.1 TRANSLATION EDGE
-- Source (Verse/Hadith) -> translated_as -> Translation
DEFINE TABLE translated_as SCHEMAFULL TYPE RELATION FROM quran_verse|hadith TO translation;

-- 8.2 MORPHOLOGY EDGE
-- Verse -> has_root -> RootWord
DEFINE TABLE has_root SCHEMAFULL TYPE RELATION FROM quran_verse TO root_word;

-- 8.3 THEMATIC EDGE
-- Verse -> discusses -> Concept
DEFINE TABLE discusses SCHEMAFULL TYPE RELATION FROM quran_verse TO concept;

-- 8.4 DIVINE ATTRIBUTE EDGE
-- Verse -> invokes -> DivineName
DEFINE TABLE invokes SCHEMAFULL TYPE RELATION FROM quran_verse TO divine_name;

-- 8.5 DERIVATION EDGE (Istinbat)
-- Ruling -> derived_from -> Source (Verse/Hadith)
DEFINE TABLE derived_from SCHEMAFULL TYPE RELATION FROM fiqh_ruling TO quran_verse|hadith;
DEFINE FIELD strength ON derived_from TYPE option<float>;
DEFINE FIELD method ON derived_from TYPE option<string>;

-- 8.6 GRADING EDGE
-- Scholar -> graded -> Hadith
DEFINE TABLE graded SCHEMAFULL TYPE RELATION FROM scholar TO hadith;
DEFINE FIELD rank ON graded TYPE string ASSERT $value INSIDE ['Sahih', 'Hasan', 'Daif', 'Mawdu'];
DEFINE FIELD justification ON graded TYPE option<string>;

-- 8.7 NARRATION EDGE (Isnad)
-- Hadith -> narrated_by -> Scholar
DEFINE TABLE narrated_by SCHEMAFULL TYPE RELATION FROM hadith TO scholar;
DEFINE FIELD narration_order ON narrated_by TYPE int;

-- 8.8 TAFSIR EDGE
-- Hadith -> explains -> Verse
DEFINE TABLE explains SCHEMAFULL TYPE RELATION FROM hadith TO quran_verse;

-- 8.9 SCHOOL AFFILIATION
-- Scholar -> follows -> School
DEFINE TABLE follows SCHEMAFULL TYPE RELATION FROM scholar TO school;
DEFINE FIELD rank ON follows TYPE int DEFAULT 1;

-- 8.10 ABROGATION (Naskh)
-- Verse -> abrogates -> Verse (with scholarly attribution)
DEFINE TABLE abrogates SCHEMAFULL TYPE RELATION FROM quran_verse TO quran_verse
    PERMISSIONS
        FOR select FULL
        FOR create, update, delete WHERE $auth.role IN ['admin', 'scholar'];

DEFINE FIELD attributed_to ON abrogates TYPE record<scholar>;
DEFINE FIELD consensus ON abrogates TYPE bool DEFAULT false;
DEFINE FIELD created_at ON abrogates TYPE datetime DEFAULT time::now();

-- ============================================================
-- SECTION 9: EVENTS (Bias Filter / Governance)
-- ============================================================

-- Block linking rulings to fabricated hadith
DEFINE EVENT prevent_mawdu_derivation ON TABLE derived_from WHEN $event = "CREATE" THEN {
    LET $hadith_grades = (SELECT VALUE rank FROM graded WHERE out = $after.out);
    IF 'Mawdu' IN $hadith_grades {
        THROW "Error: Cannot base a ruling on fabricated (Mawdu) evidence.";
    };
};
