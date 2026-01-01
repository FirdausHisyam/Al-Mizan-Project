-- ------------------------------
-- OPTION
-- ------------------------------
OPTION IMPORT;

-- ------------------------------
-- USERS (For Authentication)
-- ------------------------------
DEFINE TABLE user SCHEMAFULL
    PERMISSIONS
        FOR select, update, delete WHERE id = $auth.id
        FOR create FULL;

DEFINE FIELD email ON user TYPE string ASSERT string::is::email($value);
DEFINE FIELD password ON user TYPE string;
DEFINE FIELD role ON user TYPE string ASSERT $value INSIDE ['admin', 'scholar', 'student'];

DEFINE INDEX email ON user COLUMNS email UNIQUE;

-- ------------------------------
-- SCOPES (Authentication)
-- ------------------------------
DEFINE SCOPE allusers
    SESSION 24h
    SIGNUP ( CREATE user SET email = $email, password = crypto::argon2::generate($password), role = 'student' )
    SIGNIN ( SELECT * FROM user WHERE email = $email AND crypto::argon2::compare(password, $password) )
;

-- ------------------------------
-- NODES
-- ------------------------------

-- ANALYZERS
DEFINE ANALYZER arabic_analyzer TOKENIZERS text FILTERS lowercase, ascii, arabic_normalization;

-- VERSE
-- VERSE
DEFINE TABLE verse SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD text ON verse TYPE string; -- Legacy/Display default
DEFINE FIELD uthmani_script ON verse TYPE string;
DEFINE FIELD indopak_script ON verse TYPE string;
DEFINE FIELD simple_clean ON verse TYPE string ANALYZER arabic_analyzer;
DEFINE FIELD buckwalter ON verse TYPE string;
DEFINE FIELD translation ON verse TYPE string;
DEFINE FIELD digitized_by ON verse TYPE string;
DEFINE FIELD digitization_date ON verse TYPE datetime DEFAULT time::now();
DEFINE FIELD signature ON verse TYPE string;

-- VERSE MAPPING (Coordinate System)
DEFINE TABLE verse_mapping SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD verse_id ON verse_mapping TYPE record<verse>;
DEFINE FIELD system ON verse_mapping TYPE string; -- e.g. 'kufic', 'basran'
DEFINE FIELD surah ON verse_mapping TYPE int;
DEFINE FIELD ayah ON verse_mapping TYPE int;
DEFINE FIELD digitized_by ON verse_mapping TYPE string;
DEFINE FIELD digitization_date ON verse_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD signature ON verse_mapping TYPE string;

DEFINE INDEX verse_system ON verse_mapping COLUMNS verse_id, system UNIQUE;

-- HADITH
DEFINE TABLE hadith SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD text ON hadith TYPE string;
DEFINE FIELD source ON hadith TYPE string;
DEFINE FIELD grade ON hadith TYPE string;
DEFINE FIELD digitized_by ON hadith TYPE string;
DEFINE FIELD digitization_date ON hadith TYPE datetime DEFAULT time::now();
DEFINE FIELD signature ON hadith TYPE string;

-- SCHOOL (Madhab)
DEFINE TABLE school SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD name ON school TYPE string;
DEFINE FIELD digitized_by ON school TYPE string;
DEFINE FIELD digitization_date ON school TYPE datetime DEFAULT time::now();
DEFINE FIELD signature ON school TYPE string;

-- SCHOLAR
DEFINE TABLE scholar SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD name ON scholar TYPE string;
DEFINE FIELD death_date ON scholar TYPE string;
DEFINE FIELD school ON scholar TYPE string; -- Denormalized for easy access, or edge
DEFINE FIELD digitized_by ON scholar TYPE string;
DEFINE FIELD digitization_date ON scholar TYPE datetime DEFAULT time::now();
DEFINE FIELD signature ON scholar TYPE string;

-- ------------------------------
-- EDGES (RELATIONS)
-- ------------------------------

-- FOLLOWS (Scholar -> School)
-- FOLLOWS (Scholar -> School)
DEFINE TABLE follows TYPE RELATION IN scholar OUT school SCHEMAFULL;
DEFINE FIELD rank ON follows TYPE int; -- 1 = Primary, 2 = Secondary
DEFINE FIELD digitized_by ON follows TYPE string;
DEFINE FIELD digitization_date ON follows TYPE datetime DEFAULT time::now();
DEFINE FIELD signature ON follows TYPE string;

-- DEDUCES (Scholar -> Abrogation Verdict)
-- Note: Abrogation is now a Node or a complex Edge. 
-- For simplicity in graph, we can model Abrogation as an Edge between Verses, 
-- BUT it must be "signed" by a Scholar. 
-- OR, strictly following the critique: Scholar -> deduces -> AbrogationNode -> targets -> [Verse A, Verse B]
-- However, standard graph databases often use "Hyperedges" or properties on edges.
-- To satisfy "Scholar -> deduces -> Abrogation", let's make Abrogation a Node (Verdict).

-- OPINION (The Triple-Node)
DEFINE TABLE opinion SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD verdict ON opinion TYPE string; -- e.g. "Abrogated"
DEFINE FIELD methodology ON opinion TYPE string; -- e.g. "Naskh"
DEFINE FIELD school ON opinion TYPE string; -- Denormalized for O(1) lookup
DEFINE FIELD weight ON opinion TYPE float; -- The Mizan: 0.0 - 1.0
DEFINE FIELD digitized_by ON opinion TYPE string;
DEFINE FIELD digitization_date ON opinion TYPE datetime DEFAULT time::now();
DEFINE TABLE global_ruling SCHEMAFULL;
DEFINE FIELD authority_id ON global_ruling TYPE record(scholar);
DEFINE FIELD topic ON global_ruling TYPE string;
DEFINE FIELD verdict ON global_ruling TYPE string;
DEFINE FIELD effective_date ON global_ruling TYPE datetime DEFAULT time::now();
DEFINE FIELD signatures ON global_ruling TYPE array;
DEFINE FIELD status ON global_ruling TYPE string DEFAULT "Pending"; -- Pending, Active, Rejected
DEFINE FIELD required_signatures ON global_ruling TYPE int DEFAULT 3;

-- Event Table (Prophecy/Strategy)
DEFINE TABLE event SCHEMAFULL;
DEFINE FIELD title ON event TYPE string;
DEFINE FIELD status ON event TYPE string; -- Pending, Active, Fulfilled
DEFINE FIELD linked_hadith ON event TYPE record(hadith);
DEFINE FIELD location ON event TYPE string;
DEFINE FIELD description ON event TYPE string;

-- Legal Ontology (Fiqh al-Muamalat)
DEFINE TABLE concept SCHEMAFULL;
DEFINE FIELD name ON concept TYPE string;
DEFINE FIELD description ON concept TYPE string;

DEFINE TABLE rule SCHEMAFULL;
DEFINE FIELD name ON rule TYPE string;
DEFINE FIELD description ON rule TYPE string;
DEFINE FIELD severity ON rule TYPE string; -- Haram, Makruh, etc.

DEFINE TABLE establishes_rule SCHEMAFULL TYPE RELATION FROM verse TO rule;
-- Actually, the plan said "invalidates_parameter -> string (representing a JSON key)".
-- SurrealDB relations must point to a record. So we might need a 'parameter' node or just use the edge to point to a 'concept' that represents the parameter.
-- Let's define a 'parameter' table to be strict.
DEFINE TABLE parameter SCHEMAFULL;
DEFINE FIELD name ON parameter TYPE string;

DEFINE TABLE invalidates_parameter SCHEMAFULL TYPE RELATION FROM rule TO parameter;

DEFINE INDEX school_evidence ON opinion COLUMNS school, text_evidence_id;

-- EDGES (RELATIONS)

-- HOLDS (Scholar -> Opinion)
DEFINE TABLE holds TYPE RELATION IN scholar OUT opinion SCHEMAFULL;

-- CITES (Opinion -> Evidence [Verse/Hadith])
DEFINE TABLE cites TYPE RELATION IN opinion OUT verse SCHEMAFULL;

-- POSITS (Opinion -> Relationship [Optional, if we want to reify the relationship])
-- For now, the Opinion node itself represents the relationship between the evidence it cites.
-- e.g. Opinion X cites Verse A and Verse B, and verdict is "A abrogates B".

-- Legacy simple edge for visualization (optional, but good for simple queries)
-- We will keep the direct edge but enforce the 'authority' field as the Scholar ID.
DEFINE TABLE abrogates TYPE RELATION IN verse OUT verse SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin' OR $auth.role = 'scholar';

DEFINE FIELD proof_text ON abrogates TYPE record<verse> | record<hadith>;
DEFINE FIELD scholar ON abrogates TYPE record<scholar>;
DEFINE FIELD validation_signature ON abrogates TYPE string;
DEFINE FIELD created_at ON abrogates TYPE datetime DEFAULT time::now();
