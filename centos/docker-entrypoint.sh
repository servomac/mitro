#!/bin/bash

# TODO supervisor
su --login - postgres --command "postgres -D /srv/mitro/mitro-core/build/postgres/ &"
sleep 2s
su --login - postgres --command "psql -c \"CREATE USER root with CREATEROLE superuser\""
su --login - postgres --command "createdb mitro -U root"

# exec command
cd /srv/mitro/mitro-core
exec "$@"
