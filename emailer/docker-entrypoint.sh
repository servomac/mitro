#!/bin/bash

WORKDIR=/srv/emailer

# check environment variables
[ -z "${DB_PORT_5432_TCP_ADDR}" ] && echo "The Postgres container is not correctly linked! Add --link postgres:db to the docker run parameters!" && exit 1
[ -z "${POSTGRES_PASSWORD}" ] && echo "Postgres password undefined! Add -e POSTGRES_PASSWORD=\"blabla\" to the docker run parameters!" && exit 1
[ -z "${MAIL_ADDR}" ] && echo "Undefined mailing host! Add -e MAIL_ADDR=\"IP\" to the docker run parameters!" && exit 1
[ -z "${DOMAIN}" ] && echo "Domain undefined! Add -e DOMAIN=\"ip or domain name\" to the docker run parameters!" && exit 1

cp $WORKDIR/config.ini.example $WORKDIR/config.ini
sed -i "/\[database\]/{n;s/.*/hostname = ${DB_PORT_5432_TCP_ADDR}/}" $WORKDIR/config.ini
sed -i "s/username = mitro/username = postgres/" $WORKDIR/config.ini
sed -i "s/password = mitro/password = ${POSTGRES_PASSWORD}/" $WORKDIR/config.ini
sed -i "/\[smtp\]/{n;s/.*/hostname = ${MAIL_ADDR}/}" $WORKDIR/config.ini
sed -i "s/tls=true/tls=false/" $WORKDIR/config.ini
sed -i "s/issues@mitro.co/developers@habitissimo.com/" $WORKDIR/config.ini
sed -i "s/no-reply@mitro.co/no-reply@habitissimo.com/" $WORKDIR/config.ini
sed -i "s/mitro.co/${DOMAIN}/" $WORKDIR/config.ini

exec "$@"
