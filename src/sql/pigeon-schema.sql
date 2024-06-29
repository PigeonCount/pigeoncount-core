/*
 *  Pigeon Count
 *  Copyright (C) 2024 David M. Syzdek <david@syzdek.net>.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of David M. Syzdek nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 *  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DAVID M. SYZDEK BE LIABLE FOR
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
 */

SET ROLE @PG_USER@;
SET client_min_messages TO WARNING;
\c   @PG_DBNAME@
\set ON_ERROR_STOP on


-- //////////////
-- //          //
-- //  Tables  //
-- //          //
-- //////////////

/*
 *  Pigeon Count Software Version and Database Schema Version
 *
 *  id
 *  : The primary key of a specific entry
 *
 *  dbSchemaVersion
 *  : dataabase schema version, similar to libtool ABI versions
 *
 *  dbSchemaAge
 *  : number of previous versions which are compatible with this database
 *  : schema version, similar to libtool ABI versions
 *
 *  versionMajor
 *  : Pigeon Count software major version
 *
 *  versionMinor
 *  : Pigeon Count software minor version
 *
 *  versionPatch
 *  : Pigeon Count software patch version
 *
 *  versionBuild
 *  : Pigeon Count software build version (i.e. git commit id)
 *
 *  updated
 *  : timestamp of last database schema update
 */
CREATE TABLE IF NOT EXISTS upgraded
(
   id                SERIAL,
   dbSchemaVersion   INT               NOT NULL DEFAULT 0,
   dbSchemaAge       INT               NOT NULL DEFAULT 0,
   versionMajor      INT               NOT NULL,
   versionMinor      INT               NOT NULL,
   versionPatch      INT               NOT NULL,
   versionBuild      VARCHAR(128)      NOT NULL DEFAULT 'n/a',
   updated           TIMESTAMP         NOT NULL DEFAULT NOW(),
   PRIMARY KEY       ( id )
);
CREATE INDEX
   IF NOT EXISTS     upgraded_idx_id
   ON                upgraded
   USING             btree
                     ( id );


/*
 *  Token Type
 *
 *  id
 *  : The primary key of a specific entry
 *
 *  name
 *  : the name of the token type
 *
 *  description
 *  : token type description
 */
CREATE TABLE IF NOT EXISTS tokenType
(
   id                INT               NOT NULL UNIQUE,
   name              VARCHAR(32)       NOT NULL,
   description       VARCHAR(128)      NOT NULL,
   PRIMARY KEY       ( id )
);
CREATE INDEX
   IF NOT EXISTS     tokenType_idx_id
   ON                tokenType
   USING             btree
                     ( id );
CREATE INDEX
   IF NOT EXISTS     tokenType_idx_name
   ON                tokenType
   USING             hash
                     ( name );


/*
 *  Credential Type
 *
 *  id
 *  : The primary key of a specific entry
 *
 *  typeName
 *  : the name of the credential type
 *
 *  tokenDesc
 *  : credential type description
 */
CREATE TABLE IF NOT EXISTS credType
(
   id                INT               NOT NULL UNIQUE,
   name              VARCHAR(32)       NOT NULL UNIQUE,
   alias             VARCHAR(32)       NOT NULL,
   description       VARCHAR(128)      NOT NULL,
   twofactor         BOOLEAN           NOT NULL DEFAULT TRUE,
   PRIMARY KEY       ( id )
);
CREATE INDEX
   IF NOT EXISTS     credType_idx_id
   ON                credType
   USING             btree
                     ( id );
CREATE INDEX
   IF NOT EXISTS     credType_idx_name
   ON                credType
   USING             hash
                     ( name );


/*
 *  Pigeon Count User
 *
 *  id
 *  : The primary key of a specific entry
 *
 *  email
 *  : user's email address
 *
 *  givenName
 *  : user's first name or given name
 *
 *  surname
 *  : user's last name or surname
 */
CREATE TABLE IF NOT EXISTS account
(
   id                SERIAL,
   guid              UUID              NOT NULL UNIQUE DEFAULT gen_random_uuid(),
   email             VARCHAR(128)      NOT NULL UNIQUE,
   givenName         VARCHAR(32)       NOT NULL,
   surname           VARCHAR(32)       NOT NULL,
   PRIMARY KEY       ( id )
);
CREATE INDEX
   IF NOT EXISTS     account_idx_id
   ON                account
   USING             btree
                     ( id );
CREATE INDEX
   IF NOT EXISTS     account_idx_guid
   ON                account
   USING             hash
                     ( guid );
CREATE INDEX
   IF NOT EXISTS     account_idx_email
   ON                account
   USING             hash
                     ( email );


/*
 *  Pigeon Count User
 *
 *  id
 *  : The primary key of a specific entry
 *
 *  accountId
 *  : ID of the associated account
 *
 *  credTypeId
 *  : ID of the credential type
 *
 *  cred
 *  : the actual credential
 *
 *  modified
 *  : timestamp of crendential's last modification
 *
 *  notBefore
 *  : credential is not valid before timestamp
 *
 *  notAfter
 *  : credential is not valid after timestamp
 */
CREATE TABLE IF NOT EXISTS accountCred
(
   id                SERIAL,
   accountId         INTEGER           NOT NULL,
   credTypeId        INTEGER           NOT NULL,
   cred              VARCHAR(128)      NOT NULL,
   modified          TIMESTAMP         NOT NULL DEFAULT NOW(),
   notBefore         TIMESTAMP         NOT NULL DEFAULT NOW(),
   notAfter          TIMESTAMP,
   PRIMARY KEY       ( id ),
   FOREIGN KEY       ( accountId )
      REFERENCES     account
                     ( id ),
   FOREIGN KEY       ( credTypeId )
      REFERENCES     credType
                     ( id )
);
CREATE INDEX
   IF NOT EXISTS     accountCred_idx_id
   ON                accountCred
   USING             hash
                     ( id );
CREATE INDEX
   IF NOT EXISTS     accountCred_idx_accountId
   ON                accountCred
   USING             hash
                     ( accountId );
CREATE INDEX
   IF NOT EXISTS     accountCred_idx_credTypeId
   ON                accountCred
   USING             hash
                     ( credTypeId );
CREATE INDEX
   IF NOT EXISTS     accountCred_idx_notBefore
   ON                accountCred
   USING             hash
                     ( notBefore );
CREATE INDEX
   IF NOT EXISTS     accountCred_idx_notAfter
   ON                accountCred
   USING             hash
                     ( notAfter );


/*
 *  Pigeon Count User
 *
 *  id
 *  : The primary key of a specific entry
 *
 *  email
 *  : user's email address
 *
 *  givenName
 *  : user's first name or given name
 *
 *  surname
 *  : user's last name or surname
 */
CREATE TABLE IF NOT EXISTS accountToken
(
   id                SERIAL,
   tokenTypeId       INT               NOT NULL,
   accountId         INT               NOT NULL,
   description       VARCHAR(32),
   token             UUID              NOT NULL UNIQUE DEFAULT gen_random_uuid(),
   created           TIMESTAMP         NOT NULL DEFAULT NOW(),
   notBefore         TIMESTAMP         NOT NULL DEFAULT NOW(),
   notAfter          TIMESTAMP         NOT NULL DEFAULT NOW() + '1 DAY',
   PRIMARY KEY       ( id ),
   FOREIGN KEY      ( tokenTypeId )
      REFERENCES    tokenType
                    ( id ),
   FOREIGN KEY      ( accountId )
      REFERENCES    account
                    ( id )
);
CREATE INDEX
   IF NOT EXISTS     accountToken_idx_id
   ON                accountToken
   USING             hash
                     ( id );
CREATE INDEX
   IF NOT EXISTS     accountToken_idx_tokenTypeId
   ON                accountToken
   USING             hash
                     ( tokenTypeId );
CREATE INDEX
   IF NOT EXISTS     accountToken_idx_accountId
   ON                accountToken
   USING             hash
                     ( accountId );
CREATE INDEX
   IF NOT EXISTS     accountToken_idx_notBefore
   ON                accountToken
   USING             hash
                     ( notBefore );
CREATE INDEX
   IF NOT EXISTS     accountToken_idx_notAfter
   ON                accountToken
   USING             hash
                     ( notAfter );


-- /////////////////
-- //             //
-- //  Functions  //
-- //             //
-- /////////////////

/*
 *  adds or updates token type
 *
 *  % SELECT pigeon_credType(
 *       ctId        := 1,
 *       ctName      := 'pwhash',
 *       ctAlias     := 'password',
 *       ctDesc      := 'UNIX crypt password hash'
 *    );
 *
 *  newId
 *  : ID of credential type to add or update
 *
 *  newName
 *  : name of the credential type
 *
 *  newAlias
 *  : alias or user readable name for credential type
 *
 *  newDesc
 *  : description of the credential type
 */
CREATE OR REPLACE FUNCTION pigeon_credType
   (  newId          INTEGER,
      newName        VARCHAR(32),
      newAlias       VARCHAR(32)          DEFAULT NULL,
      newDesc        VARCHAR(128)         DEFAULT NULL
   )
   RETURNS           INTEGER
   LANGUAGE          plpgsql
   SECURITY          DEFINER
   VOLATILE
   AS                $$
DECLARE
   credTypeId        INTEGER;
   is2fa             BOOLEAN;
BEGIN
   -- sets defaults
   if ( newAlias IS NULL ) THEN
      newAlias       :=    newName;
   END IF;

   -- searches for tokenType ID
   SELECT            id                   INTO  credTypeId
      FROM           credType
      WHERE          id                   =     newId;

   -- updates existing token type
   IF ( credTypeId IS NOT NULL ) THEN
      UPDATE         credType
         SET         name                 =     newName,
                     alias                =     newAlias,
                     description          =     newDesc
         WHERE       id                   =     newId
         RETURNING   id                   INTO  credTypeId;
      RETURN credTypeId;
   END IF;

   -- sets is2FA
   is2fa := TRUE;
   IF ( newId = 0 ) THEN
       is2fa := FALSE;
   END IF;

   -- adds new tokenType
   INSERT INTO       credType
                     (  id,
                        name,
                        alias,
                        description,
                        twofactor
                     )
      VALUES         (  newId,
                        newName,
                        newAlias,
                        newDesc,
                        is2fa
                     )
      RETURNING      id                   INTO  credTypeId;

   RETURN            credTypeId;
END;
$$;


/*
 *  adds or updates token type
 *
 *  % SELECT pigeon_tokenType(
 *       ttId        := 1,
 *       ttName      := 'user',
 *       ttDesc      := 'user login session'
 *    );
 *
 *  newId
 *  : ID of token type to add or update
 *
 *  newName
 *  : name of the token type
 *
 *  newDesc
 *  : description of the token type
 */
CREATE OR REPLACE FUNCTION pigeon_tokenType
   (  newId          INTEGER,
      newName        VARCHAR(32),
      newDesc        VARCHAR(128)         DEFAULT NULL
   )
   RETURNS           INTEGER
   LANGUAGE          plpgsql
   SECURITY          DEFINER
   VOLATILE
   AS                $$
DECLARE
   tokenTypeId       INTEGER;
BEGIN
   -- searches for tokenType ID
   SELECT            id                   INTO  tokenTypeId
      FROM           tokenType
      WHERE          id                   =     newId;

   -- updates existing token type
   IF ( tokenTypeId IS NOT NULL ) THEN
      UPDATE         tokenType
         SET         name                 =     newName,
                     description          =     newDesc
         WHERE       id                   =     newId
         RETURNING   id                   INTO  tokenTypeId;
      RETURN tokenTypeId;
   END IF;

   -- adds new tokenType
   INSERT INTO       tokenType
                     (  id,
                        name,
                        description
                     )
      VALUES         (  newId,
                        newName,
                        newDesc
                     )
      RETURNING      id                   INTO  tokenTypeId;

   RETURN            tokenTypeId;
END;
$$;


/*
 *  query database and software versions
 *
 *  % SELECT * FROM pigeon_version();
 *
 *  Returns table with the following columns:
 *
 *  schemaVersion
 *  : current schema version
 *
 *  schemaAge
 *  : number of prior schema versions which are compatible with the current
 *  : version of the schema
 *
 *  pkgMajor
 *  : major software package version
 *
 *  pkgMinor
 *  : minor software package version
 *
 *  pkgPatch
 *  : patch level of current sofrware package
 *
 *  pkgBuild
 *  : build version of software package (i.e. software revision control system
 *  : ID used by package)
 *
 *  pkgUpdated
 *  : timestamp of package install or latest upgrade
 */
CREATE OR REPLACE FUNCTION pigeon_version()
   RETURNS           TABLE
                     (  schemaVersion     INT,
                        schemaAge         INT,
                        pkgMajor          INT,
                        pkgMinor          INT,
                        pkgPatch          INT,
                        pkgBuild          VARCHAR(128),
                        pkgUpdated        TIMESTAMP
                     )
   LANGUAGE          plpgsql
   SECURITY          DEFINER
   STABLE
   AS                $$
DECLARE
BEGIN
   RETURN QUERY
      SELECT         dbSchemaVersion      AS schemaVersion,
                     dbSchemaAge          AS schemaAge,
                     versionMajor         AS pkgMajor,
                     versionMinor         AS pkgMinor,
                     versionPatch         AS pkgPatch,
                     versionBuild         AS pkgBuild,
                     updated              AS pkgUpdated
         FROM        upgraded
         ORDER BY    updated              DESC
         LIMIT       1;
END;
$$;


-- /////////////////////////
-- //                     //
-- //  Trigger Functions  //
-- //                     //
-- /////////////////////////

/*
 *  trigger functions for accountCred table
 */
CREATE OR REPLACE FUNCTION accountCred_before_insert
   ( )
   RETURNS           trigger
   LANGUAGE          plpgsql
   AS                $$
DECLARE
BEGIN

   -- forces initial values
   NEW.modified      := NOW();

   RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION accountCred_before_update
   ( )
   RETURNS           trigger
   LANGUAGE          plpgsql
   AS                $$
DECLARE
BEGIN

   -- forces initial values
   NEW.modified      := NOW();

   RETURN NEW;
END;
$$;

-- accountCred table triggers
CREATE OR REPLACE TRIGGER accountCred_before_insert
   BEFORE            INSERT
   ON                accountCred
   FOR EACH          ROW
   EXECUTE           PROCEDURE accountCred_before_insert();
CREATE OR REPLACE TRIGGER accountCred_before_update
   BEFORE            UPDATE
   ON                accountCred
   FOR EACH          ROW
   EXECUTE           PROCEDURE accountCred_before_update();


-- /////////////////
-- //             //
-- //  Seed Data  //
-- //             //
-- /////////////////

-- add current software version to database
INSERT INTO
   upgraded          (  dbSchemaVersion,
                        dbSchemaAge,
                        versionMajor,
                        versionMinor,
                        versionPatch,
                        versionBuild
                     )
   SELECT            @DB_SCHEMA_VERSION@,    -- dbSchemaVersion
                     @DB_SCHEMA_AGE@,        -- dbSchemaAge
                     @PCSC_MAJOR@,           -- versionMajor
                     @PCSC_MINOR@,           -- versionMinor
                     @PCSC_PATCH@,           -- versionPatch
                     '@PCSC_BUILD@'          -- versionBuild
   WHERE NOT EXISTS  (  SELECT         1
                           FROM        upgraded
                           WHERE       dbSchemaVersion   = 0
                              AND      dbSchemaAge       = 0
                              AND      versionMajor      = @PCSC_MAJOR@
                              AND      versionMinor      = @PCSC_MINOR@
                              AND      versionPatch      = @PCSC_PATCH@
                              AND      versionBuild      = '@PCSC_BUILD@'
                     );


-- add token types
SELECT pigeon_tokenType(   0,  'unknown',          'Unknown user token' );
SELECT pigeon_tokenType(   1,  'login',            'login session' );
SELECT pigeon_tokenType(   2,  'application',      'application token' );


-- add token types
SELECT pigeon_credType(    0, 'pwhash',   'Password',    'UNIX crypt password hash' );
SELECT pigeon_credType(    1, 'totp',     'TOTP',        'timed-base one-time password' );



/* end of sql */
