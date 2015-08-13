# Mitro over CentOS

A first attempt to dockerize the [Mitro Password Manager](https://github.com/mitro-co/mitro).

## Quick Start

 1. Clone the project and build the mitro and emailer images

```
 git clone https://github.com/servomac/mitro.git
 cd mitro/centos
 docker build -t mitro:centos6 .

 cd ../emailer
 docker build -t emailer .
```

 2. Run postgres

```
  docker run --name=postgres -e POSTGRES_PASSWORD="AGOODPASS" -d postgres
```

 3. Execute the mitro server

```
  docker run --restart='always' \
             --name mitro \
             --link=postgres:db \
             -e POSTGRES_PASSWORD="AGOODPASS" \
             -e DOMAIN="mitro.domain.com" \
             -p 8443:8443 \
             -d mitro:centos6
```

 4. Execute the emailer container

```
  docker run --restart='always' \
             --name emailer \
             --link=postgres:db \
             -e POSTGRES_PASSWORD="AGOODPASS" \
             -e MAIL_ADDR="172.17.42.1" \
             -d emailer
```

## References

 · [Building/running a server on Linux](https://github.com/mitro-co/mitro/issues/56)
 · [Mitro Login Manager On-Premise](https://www.hashtagsecurity.com/mitro-login-manager-on-premise-2/)
