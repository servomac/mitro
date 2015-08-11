FROM centos:centos6
MAINTAINER Toni Pizà <tpiza@habitissimo.com>

ENV NODE_PATH /srv/mitro/browser-ext/api/build/node/lib/node_modules

RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum install -y postgresql
RUN yum install -y postgresql-server
RUN yum install -y postgresql-contrib
RUN yum install -y npm.noarch
RUN yum install -y git
RUN yum install -y ant
RUN yum install -y ant-nodeps
RUN yum install -y java-1.7.0-openjdk-devel.x86_64

RUN yum install -y xz
RUN yum install -y wget
RUN yum install -y tar
RUN yum install -y unzip
RUN yum install -y bzip2

RUN git clone https://github.com/mitro-co/mitro.git /srv/mitro

# apply browser-ext patch
WORKDIR /srv/mitro
COPY ./lru_patch.diff /srv/mitro/
RUN git apply lru_patch.diff

# compile chrome extension
WORKDIR /srv/mitro/browser-ext/api
RUN ./build.sh
WORKDIR /srv/mitro/browser-ext/login
RUN make chrome

# install python 2.7 (this breaks yum and the build of browser-ext)
WORKDIR /usr/local
RUN wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz
RUN xz -d Python-2.7.6.tar.xz
RUN tar -xvf Python-2.7.6.tar
RUN cd Python-2.7.6 && ./configure --prefix=/usr/local
RUN cd Python-2.7.6 && make && make altinstall
RUN rm /usr/bin/python && ln -s /usr/local/bin/python2.7 /usr/bin/python

WORKDIR /srv/mitro/mitro-core
RUN mkdir -p build/postgres
RUN chown -R postgres:postgres build/postgres

COPY ./docker-entrypoint.sh /

USER postgres
RUN ./build.sh

USER root
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ant", "server"]
