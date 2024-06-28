#
#   Pigeon Count
#   Copyright (C) 2024 David M. Syzdek <david@syzdek.net>.
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are
#   met:
#
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#      * Neither the name of David M. Syzdek nor the names of its contributors
#        may be used to endorse or promote products derived from this software
#        without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
#   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
#   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DAVID M. SYZDEK BE LIABLE FOR
#   ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.
#

-include GNUmakefile.local

DB_SCHEMA_VERSION	:= 0
DB_SCHEMA_AGE		:= 0

PCSC_GITVERSION		= $(shell git describe --long)
PCSC_MAJOR		= $(shell echo $(PCSC_GITVERSION) |cut -d. -f1 |cut -dv -f2)
PCSC_MINOR		= $(shell echo $(PCSC_GITVERSION) |cut -d. -f2 |cut -d- -f1)
PCSC_PATCH		= $(shell echo $(PCSC_GITVERSION) |cut -d- -f2)
PCSC_BUILD		= $(shell echo $(PCSC_GITVERSION) |cut -d- -f3)

PG_DBNAME		?= pigeon
PG_USER			?= pigeon
PG_PASS			?=

PSQL			?= psql
PSQL_OPTS		?= -q -h localhost -U $(USER)
PSQL_COMMAND		:= $(PSQL) $(PSQL_OPTS)


do_subst		= sed \
			  -e 's/[@]DB_SCHEMA_VERSION[@]/$(DB_SCHEMA_VERSION)/g' \
			  -e 's/[@]DB_SCHEMA_AGE[@]/$(DB_SCHEMA_AGE)/g' \
			  -e 's/[@]PG_DBNAME[@]/$(PG_DBNAME)/g' \
			  -e 's/[@]PG_USER[@]/$(PG_USER)/g' \
			  -e 's,[@]PG_PASS[@],$(PG_PASS),g' \
			  -e 's/[@]PCSC_MAJOR[@]/$(PCSC_MAJOR)/g' \
			  -e 's/[@]PCSC_MINOR[@]/$(PCSC_MINOR)/g' \
			  -e 's/[@]PCSC_PATCH[@]/$(PCSC_PATCH)/g' \
			  -e 's/[@]PCSC_BUILD[@]/$(PCSC_BUILD)/g' \


.PHONY: all clean distclean database database-drop database-reset datbase-sql demo demo-sql schema schema-sql


all:
	@echo "Targets:"
	@echo ""
	@echo "   make database       - creates initial role and database"
	@echo "   make schema         - creates database schema"
	@echo "   make demo           - adds demo/test records to datbase"
	@echo ""
	@echo "   make database-sql   - show SQL to create initial role and database"
	@echo "   make schema-sql     - show SQL to create database schema"
	@echo "   make demo-sql       - show SQL to add demo/test records to datbase"
	@echo ""
	@echo "   make dataabse-reset - drops database tables"
	@echo "   make dataabse-drop  - drops database and role"
	@echo ""
	@echo "Variables:"
	@echo ""
	@echo "   PSQL='$(PSQL)'"
	@echo "   PSQL_OPTS='$(PSQL_OPTS)'"
	@echo "   PG_DBNAME='$(PG_DBNAME)'"
	@echo "   PG_USER='$(PG_USER)'"
	@echo "   PG_PASS='$(PG_PASS)'"
	@echo ""
	@echo "   Variables can be defined on the CLI or in GNUmakefile.local"
	@echo ""


clean:


distclean: clean


database:
	@echo 'do_subst pigeon-db.sql     | $(PSQL_COMMAND)'
	@$(do_subst)    pigeon-db.sql     | $(PSQL_COMMAND)
	@echo 'do_subst pigeon-schema.sql | $(PSQL_COMMAND)'
	@$(do_subst)    pigeon-schema.sql | $(PSQL_COMMAND)


database-drop:
	@echo 'do_subst pigeon-db-reset.sql | $(PSQL_COMMAND)'
	@$(do_subst)    pigeon-db-reset.sql | $(PSQL_COMMAND)
	@echo 'do_subst pigeon-db-drop.sql  | $(PSQL_COMMAND)'
	@$(do_subst)    pigeon-db-drop.sql  | $(PSQL_COMMAND)


database-reset:
	@echo 'do_subst pigeon-db-reset.sql | $(PSQL_COMMAND)'
	@$(do_subst)    pigeon-db-reset.sql | $(PSQL_COMMAND)


database-sql:
	@$(do_subst)    pigeon-db.sql
	@$(do_subst)    pigeon-schema.sql


demo:
	@echo 'do_subst pigeon-demo.sql | $(PSQL_COMMAND)'
	@$(do_subst)    pigeon-demo.sql | $(PSQL_COMMAND)


demo-sql:
	@$(do_subst)    pigeon-demo.sql


schema:
	@echo 'do_subst pigeon-schema.sql | $(PSQL_COMMAND)'
	@$(do_subst)    pigeon-schema.sql | $(PSQL_COMMAND)


schema-sql:
	@$(do_subst)    pigeon-schema.sql


GNUmakefile.local:
	@echo '#PG_DBNAME		:= $(PG_DBNAME)' >> $(@)
	@echo '#PG_USER		?= $(PG_USER)' >> $(@)
	@echo 'PG_PASS		?= $(PG_PASS)' >> $(@)
	@echo '#PSQL			:= $(PSQL)' >> $(@)
	@echo '#PSQL_OPTS		:= $(PSQL_OPTS)' >> $(@)


#  end of makefile
