#!/bin/bash

WORKDIR=/srv/emailer

# check environment variables
[ -z "${DB_PORT_5432_TCP_ADDR}" ] && echo "The Postgres container is not correctly linked! Add --link postgres:db to the docker run parameters!" && exit 1
[ -z "${DB_ENV_POSTGRES_PASSWORD}" ] && echo "Undefined postgres password! Add --link postgres:db to the docker run parameters!" && exit 1
[ -z "${MANDRILL_API_KEY}" ] && echo "Undefined Mandrill API KEY! Add -e MANDRILL_API_KEY=\"apikey\" to the docker run parameters!" && exit 1
[ -z "${DOMAIN}" ] && echo "Domain undefined! Add -e DOMAIN=\"ip or domain name\" to the docker run parameters!" && exit 1

cp $WORKDIR/config.ini.example $WORKDIR/config.ini
sed -i "s/provider = smtp/provider = mandrill/" $WORKDIR/config.ini
sed -i "/\[database\]/{n;s/.*/hostname = ${DB_PORT_5432_TCP_ADDR}/}" $WORKDIR/config.ini
sed -i "s/username = mitro/username = postgres/" $WORKDIR/config.ini
sed -i "s/password = mitro/password = ${DB_ENV_POSTGRES_PASSWORD}/" $WORKDIR/config.ini
sed -i "s/issues@mitro.co/developers@habitissimo.com/" $WORKDIR/config.ini
sed -i "s/no-reply@mitro.co/no-reply@habitissimo.com/" $WORKDIR/config.ini
sed -i "s/mitro.co/${DOMAIN}/" $WORKDIR/config.ini
sed -i "/\[mandrill\]/{n;s/.*/api_key = ${MANDRILL_API_KEY}/}" $WORKDIR/config.ini

sed -i "s/logging.INFO/logging.DEBUG/" $WORKDIR/emailer.py

exec "$@"
