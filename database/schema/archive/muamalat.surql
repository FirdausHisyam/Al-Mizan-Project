-- ------------------------------
-- FIQH AL-MUAMALAT (Commercial Law)
-- ------------------------------

-- CONTRACT (Aqd)
-- Represents a financial instrument or commercial agreement.
DEFINE TABLE contract SCHEMAFULL;
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin' OR $auth.role = 'scholar';

DEFINE FIELD title ON contract TYPE string;
DEFINE FIELD type ON contract TYPE string; -- e.g., "Murabaha", "Ijarah", "Musharakah"
DEFINE FIELD parties ON contract TYPE array;
DEFINE FIELD terms ON contract TYPE object; -- JSON structure for flexible terms
DEFINE FIELD created_at ON contract TYPE datetime DEFAULT time::now();
DEFINE FIELD status ON contract TYPE string DEFAULT 'Draft'; -- Draft, Probationary, Active, Terminated

-- RELATION: BASED_ON (Contract -> Verse/Hadith)
-- Establishes the Shariah basis for the contract.
DEFINE TABLE based_on TYPE RELATION IN contract OUT verse SCHEMAFULL;
    PERMISSIONS
        FOR select WHERE $scope = 'allusers'
        FOR create, update, delete WHERE $auth.role = 'admin' OR $auth.role = 'scholar';

DEFINE FIELD justification ON based_on TYPE string; -- Scholar's note on why this verse supports this contract
DEFINE FIELD verified_by ON based_on TYPE record<scholar>;
