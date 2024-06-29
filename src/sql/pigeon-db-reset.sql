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

SET client_min_messages TO WARNING;
\c   @PG_DBNAME@
\set ON_ERROR_STOP on


DROP TABLE iF EXISTS upgraded;
DROP TABLE IF EXISTS accountCred;
DROP TABLE IF EXISTS accountToken;
DROP TABLE IF EXISTS account;
DROP TABLE iF EXISTS credType;
DROP TABLE iF EXISTS tokenType;

DROP TRIGGER IF EXISTS accountCred_before_insert      ON    accountCred;
DROP TRIGGER IF EXISTS accountCred_before_update      ON    accountCred;


DROP FUNCTION IF EXISTS accountCred_before_insert;
DROP FUNCTION IF EXISTS accountCred_before_update;

DROP FUNCTION IF EXISTS pigeon_credType;
DROP FUNCTION IF EXISTS pigeon_version;
DROP FUNCTION IF EXISTS pigeon_tokenType;


/* end of sql */
