# Mitro over CentOS

A first attempt to dockerize the [Mitro Password Manager](https://github.com/mitro-co/mitro). I claim no authority in the field, i'm just trying to set up a simple deployment process for a Mitro server. Contributions are welcomed!

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
   docker run --name mitro-postgres -e POSTGRES_PASSWORD="AGOODPASS" -d postgres
   ```

3. Execute the mitro server

   ```
   docker run --restart 'always' \
               --name mitro \
               --link mitro-postgres:db \
               -e DOMAIN="mitro.domain.com" \
               -p 0.0.0.0:8443:8443 \
               -d mitro:centos6
    ```

4. Execute the emailer container

    ```
    docker run --restart 'always' \
                --name emailer-mitro \
                --link mitro-postgres:db \
                -e MANDRILL_API_KEY="apikey" \
                -e DOMAIN="mitro.domain.com" \
                -d emailer
    ```

## Generate the browser extensions

Once you have the server up and running, you can generate the browser extensions (chrome, firefox, even a python-hosted webpage) and copy them to the host:

```
  $ docker exec -it mitro bash
  [root@629244ad0dbf login]# cd ../browser-ext/api/
  [root@629244ad0dbf login]# ./build.sh
  [root@629244ad0dbf login]# cd ../login
  [root@629244ad0dbf login]# make firefox chrome
  [root@629244ad0dbf login]# scp -r build/{firefox,chrome}/ username@172.17.42.1:
 
```

Install the extension in your desired browser and add the certificate. TODO.

## Backup

```
docker run -it --link mitro-postgres:db --rm postgres sh -c 'PGPASSWORD=$DB_ENV_POSTGRES_PASSWORD exec pg_dump -h "$DB_PORT_5432_TCP_ADDR" -p "$DB_PORT_5432_TCP_PORT" -U postgres mitro' | bzip2 > mitro.sql.bz2
```

## References


· [Building/running a server on Linux](https://github.com/mitro-co/mitro/issues/56)
· [Mitro Login Manager On-Premise](https://www.hashtagsecurity.com/mitro-login-manager-on-premise-2/)
· [Ansible configurations for Mitro](https://github.com/mitro-co/mitro/blob/ae43f8346de6c3e9818988a08cea448393e4af52/mitro-core/production/ansible/README.md)
