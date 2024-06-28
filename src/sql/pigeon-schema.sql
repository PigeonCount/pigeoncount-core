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
 *  typeName
 *  : the name of the token type
 *
 *  tokenDesc
 *  : token type description
 */
CREATE TABLE IF NOT EXISTS tokenType
(
   id                INT               NOT NULL UNIQUE,
   typeName          VARCHAR(32)       NOT NULL,
   tokenDesc         VARCHAR(128)      NOT NULL,
   PRIMARY KEY       ( id )
);
CREATE INDEX
   IF NOT EXISTS     tokenType_idx_id
   ON                tokenType
   USING             btree
                     ( id );
CREATE INDEX
   IF NOT EXISTS     tokenType_idx_typeName
   ON                tokenType
   USING             hash
                     ( typeName );


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


-- /////////////////
-- //             //
-- //  Functions  //
-- //             //
-- /////////////////

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


/* end of sql */
