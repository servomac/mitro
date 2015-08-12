#!/bin/bash

CLASSPATH="java/server/lib/keyczar-0.71f-040513.jar:java/server/lib/gson-2.2.4.jar:java/server/lib/log4j-1.2.17.jar"
KEYS_PATH="/mitrocore_secrets/sign_keyczar"

ant test

# TODO supervisor
su --login - postgres --command "postgres -D /srv/mitro/mitro-core/build/postgres/ &"
sleep 2s
su --login - postgres --command "psql -c 'CREATE USER root with CREATEROLE superuser'"
su --login - postgres --command "createdb mitro -U root"

# generate keys at root dir
mkdir -p $KEYS_PATH
java -cp $CLASSPATH org.keyczar.KeyczarTool create --location=$KEYS_PATH --purpose=sign
java -cp $CLASSPATH org.keyczar.KeyczarTool addkey --location=$KEYS_PATH --status=primary

# generate certs
DOMAIN="192.168.1.234"			# TODO as environment
export PASSPHRASE="password"

subj="
C=SP
ST=IllesBalears
O=Habitissimo
localityName=Palma
commonName=$DOMAIN
organizationalUnitName=devops
emailAddress=developers@habitissimo.com
"

openssl genrsa -des3 -out server.key -passout env:PASSPHRASE 2048
openssl req -new -sha256 -key server.key -out server.csr -passin env:PASSPHRASE -subj "$(echo -n "$subj" | tr '\n' '/')"
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt -passin env:PASSPHRASE
openssl pkcs12 -export -inkey server.key -in server.crt -name mitro_server -out server.p12 -passin env:PASSPHRASE -passout env:PASSPHRASE
/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.85.x86_64/jre/bin/keytool -importkeystore -srckeystore server.p12 -srcstoretype pkcs12 -srcalias mitro_server -destkeystore server.jks -deststoretype jks -deststorepass password -destalias jetty -srcstorepass password

cp server.jks /srv/mitro/mitro-core/build/java/src/co/mitro/core/server/debug_keystore.jks
cp server.jks /srv/mitro/mitro-core/java/server/src/co/mitro/core/server/debug_keystore.jks

# exec command
cd /srv/mitro/mitro-core
exec "$@"
