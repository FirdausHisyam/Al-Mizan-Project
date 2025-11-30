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

-- VERSE
DEFINE TABLE verse SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD text ON verse TYPE string;
DEFINE FIELD surah ON verse TYPE int;
DEFINE FIELD ayah ON verse TYPE int;
DEFINE FIELD translation ON verse TYPE string;

-- HADITH
DEFINE TABLE hadith SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD text ON hadith TYPE string;
DEFINE FIELD source ON hadith TYPE string;
DEFINE FIELD grade ON hadith TYPE string;

-- SCHOLAR
DEFINE TABLE scholar SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin';

DEFINE FIELD name ON scholar TYPE string;
DEFINE FIELD era ON scholar TYPE string;

-- ------------------------------
-- EDGES (RELATIONS)
-- ------------------------------

-- ABROGATES
DEFINE TABLE abrogates TYPE RELATION IN verse OUT verse SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin' OR $auth.role = 'scholar';

DEFINE FIELD proof_text ON abrogates TYPE record<verse> | record<hadith>;
DEFINE FIELD scholar ON abrogates TYPE record<scholar>;
DEFINE FIELD validation_signature ON abrogates TYPE string;
DEFINE FIELD created_at ON abrogates TYPE datetime DEFAULT time::now();
