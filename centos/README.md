# Mitro over CentOS

A first attempt to dockerize the [Mitro Password Manager](https://github.com/mitro-co/mitro).

## Quick Start

 0. Clone the project and build the image

```
 git clone https://github.com/servomac/mitro.git
 cd mitro/centos
 docker build -t mitro:centos6 .
```

 1. Execute the postgres container

```
  docker run --name=postgres -e POSTGRES_PASSWORD="AGOODPASS" -d postgres
```

 2. Execute the mitro server

```
  docker run \
            --restart='always' \
            --name mitro \
            --link=postgres:db \
            -e POSTGRES_PASSWORD="AGOODPASS" \
            -e DOMAIN="mitro.domain.com" \
            -p 8443:8443 \
            -d mitro:centos6
```

## References

 · [Building/running a server on Linux](https://github.com/mitro-co/mitro/issues/56)
