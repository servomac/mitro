#!/bin/bash

# check environment variables
[ -z "${DB_PORT_5432_TCP_ADDR}" ] && echo "The Postgres container is not correctly linked! Add --link postgres_mitro:db to the docker run parameters!" && exit 1
[ -z "${DB_ENV_POSTGRES_PASSWORD}" ] && echo "Postgres password undefined! Add --link postgres_mitro:db!" && exit 1
[ -z "${DOMAIN}" ] && echo "Domain undefined! Add -e DOMAIN=\"ip or domain name\" to the docker run parameters!" && exit 1

DDBB="mitro"
MITRO_PORT=${MITRO_PORT:-8443}
CLASSPATH="java/server/lib/keyczar-0.71f-040513.jar:java/server/lib/gson-2.2.4.jar:java/server/lib/log4j-1.2.17.jar"
KEYS_PATH="/mitrocore_secrets/sign_keyczar"

# check the postgres connection and the existence of the database
if [ "`PGPASSWORD="${DB_ENV_POSTGRES_PASSWORD}" psql -h${DB_PORT_5432_TCP_ADDR} -Upostgres -lqt | cut -d \| -f 1 | grep -w ${DDBB} | wc -l`" -eq "0" ]; then
        echo "Database ${DDBB} does not exist!"
        PGPASSWORD="${DB_ENV_POSTGRES_PASSWORD}" psql -h${DB_PORT_5432_TCP_ADDR} -Upostgres -c "CREATE DATABASE ${DDBB} WITH OWNER postgres ENCODING = 'UTF8' LC_COLLATE = 'en_US.utf8' LC_CTYPE='en_US.utf8'"
fi


# change the postgresql connection string to point to db link
sed -i "s|postgresql://localhost:5432/${DDBB}|postgresql://${DB_PORT_5432_TCP_ADDR}:5432/${DDBB}?user=postgres\&amp;password=${DB_ENV_POSTGRES_PASSWORD}|" /srv/mitro/mitro-core/build.xml
# do not generate random secrets every time server starts
# https://github.com/mitro-co/mitro/issues/128#issuecomment-129950839 
sed -i "/<sysproperty key=\"generateSecretsForTest\" value=\"true\"\/>/d" /srv/mitro/mitro-core/build.xml


# generate keys at root dir
if [ ! -f $KEYS_PATH/meta ]
then
    java -cp $CLASSPATH org.keyczar.KeyczarTool create --location=$KEYS_PATH --purpose=sign
    java -cp $CLASSPATH org.keyczar.KeyczarTool addkey --location=$KEYS_PATH --status=primary

    # generate certs
    # Main.java:474 https://github.com/mitro-co/mitro/blob/master/mitro-core/java/server/src/co/mitro/core/server/Main.java
    export PASSPHRASE="password"

    subj="/CN=ES/ST=IllesBalears/O=Habitissimo/localityName=Palma/commonName=$DOMAIN/organizationalUnitName=devops/emailAddress=developers@habitissimo.com"

    openssl genrsa -des3 -out server.key -passout env:PASSPHRASE 2048
    openssl req -new -sha256 -key server.key -out server.csr -passin env:PASSPHRASE -subj "$subj"
    openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt -passin env:PASSPHRASE
    openssl pkcs12 -export -inkey server.key -in server.crt -name mitro_server -out server.p12 -passin env:PASSPHRASE -passout env:PASSPHRASE
    /usr/lib/jvm/java-1.7.0-openjdk.x86_64/jre/bin/keytool -importkeystore -srckeystore server.p12 -srcstoretype pkcs12 -srcalias mitro_server -destkeystore server.jks -deststoretype jks -deststorepass password -destalias jetty -srcstorepass $PASSPHRASE

    ant test
    cp server.jks /srv/mitro/mitro-core/build/java/src/co/mitro/core/server/debug_keystore.jks
    cp server.jks /srv/mitro/mitro-core/java/server/src/co/mitro/core/server/debug_keystore.jks
fi

# configure the browser extensions
sed -i "s/www.mitro.co\|mitroaccess.com\|secondary.mitro.ca/${DOMAIN}/" /srv/mitro/browser-ext/login/common/config/config.release.js
sed -i "s/\(\(MITRO\|MITRO_AGENT\)_PORT =\) 443/\1 ${MITRO_PORT}/" /srv/mitro/browser-ext/login/common/config/config.release.js
 
# exec command
cd /srv/mitro/mitro-core
exec "$@"
