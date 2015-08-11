#!/bin/bash

CLASSPATH="java/server/lib/keyczar-0.71f-040513.jar:java/server/lib/gson-2.2.4.jar:java/server/lib/log4j-1.2.17.jar"
KEYS_PATH="mitrocore_secrets/sign_keyczar"

# TODO supervisor
su --login - postgres --command "postgres -D /srv/mitro/mitro-core/build/postgres/ &"
sleep 2s
su --login - postgres --command "psql -c 'CREATE USER root with CREATEROLE superuser'"
su --login - postgres --command "createdb mitro -U root"

cd /srv/mitro/mitro-core

# generate keys
mkdir -p $KEYS_PATH
java -cp $CLASSPATH org.keyczar.KeyczarTool create --location=$KEYS_PATH --purpose=sign
java -cp $CLASSPATH org.keyczar.KeyczarTool addkey --location=$KEYS_PATH --status=primary

# exec command
exec "$@"
