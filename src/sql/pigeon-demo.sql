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


-- add demo user admin@localhost
INSERT INTO
   account           (  email,
                        givenName,
                        surname
                     )
   VALUES            (  'admin@localhost',
                        'Administrator',
                        'User'
                     );
INSERT INTO
   accountCred       (  accountId,
                        credTypeId,
                        cred
                     )
   VALUES            (  ( SELECT id FROM account    WHERE account.email    LIKE 'admin@localhost' ),
                        ( SELECT id FROM credType    WHERE credType.name    LIKE 'pwhash' ),
                        '$6$V845Vg5Hf9gpQVqc$UjS3V8G1OhvbvuKdL4J0cmJWr4PgMUT8ARd15vdxEKoOP6Rgsdj7wdxZZcmfsvXDrcHSmffHiA5l1xLFu5cXwk'
                     );
INSERT INTO
   accountToken      (  accountId,
                        tokenTypeId,
                        notAfter
                     )
   VALUES            (  ( SELECT id FROM account    WHERE account.email    LIKE 'admin@localhost' ),
                        ( SELECT id FROM tokenType  WHERE tokenType.name   LIKE 'login' ),
                        NOW() + INTERVAL '1 DAYS'
                     );


-- add demo user jdoe@example.com
INSERT INTO
   account           (  email,
                        givenName,
                        surname
                     )
   VALUES            (  'jdoe@example.com',
                        'Joe',
                        'Doe'
                     );
INSERT INTO
   accountCred       (  accountId,
                        credTypeId,
                        cred
                     )
   VALUES            (  ( SELECT id FROM account    WHERE account.email    LIKE 'jdoe@example.com' ),
                        ( SELECT id FROM credType    WHERE credType.name   LIKE 'pwhash' ),
                        '$6$V845Vg5Hf9cpQVqc$UjS3V8G1OhvbvuKdL4J0cmJWr4PgMUT8ARd15vdxEKoOP6Rgsdj7wdxZZcmfsvXDrcHSmffHiA5l1xLFu5cXwk'
                     );
INSERT INTO
   accountToken      (  description,
                        accountId,
                        tokenTypeId,
                        notAfter
                     )
   VALUES            (  NULL,
                        ( SELECT id FROM account    WHERE account.email    LIKE 'jdoe@example.com' ),
                        ( SELECT id FROM tokenType  WHERE tokenType.name   LIKE 'login' ),
                        NOW() + INTERVAL '1 DAYS'
                     );
INSERT INTO
   accountToken      (  description,
                        accountId,
                        tokenTypeId,
                        notAfter
                     )
   VALUES            (  'Blue Tablet',
                        ( SELECT id FROM account    WHERE account.email    LIKE 'jdoe@example.com' ),
                        ( SELECT id FROM tokenType  WHERE tokenType.name   LIKE 'application' ),
                        NOW() + INTERVAL '1 YEARS'
                     );
INSERT INTO
   accountToken      (  description,
                        accountId,
                        tokenTypeId,
                        notAfter
                     )
   VALUES            (  'Phone',
                        ( SELECT id FROM account    WHERE account.email    LIKE 'jdoe@example.com' ),
                        ( SELECT id FROM tokenType  WHERE tokenType.name   LIKE 'application' ),
                        NOW() + INTERVAL '1 YEARS'
                     );


/* end of sql */
