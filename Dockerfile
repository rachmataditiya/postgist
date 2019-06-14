FROM postgres:11
MAINTAINER Mike Dillon <mike@appropriate.io>

ENV POSTGIS_MAJOR 2.5
ENV POSTGIS_VERSION 2.5.2+dfsg-1~exp1.pgdg90+1

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
           alien \
		   apt-utils \
		   build-essential \
		   libaio1 \
		   libaio-dev \
		   locales \
		   locales-all \
		   wget \
      && rm -rf /var/lib/apt/lists/*
ADD sources /usr/local

WORKDIR /usr/local

RUN alien -i oracle-instantclient11.2-basic-11.2.0.1.0-1.x86_64.rpm && \
    alien -i oracle-instantclient11.2-devel-11.2.0.1.0-1.x86_64.rpm && \
    alien -i oracle-instantclient11.2-sqlplus-11.2.0.1.0-1.x86_64.rpm

RUN tar xvfz oracle_fdw-ORACLE_FDW_1_5_0.tar.gz

WORKDIR /usr/local/oracle_fdw-ORACLE_FDW_1_5_0

RUN make && \
    make install

RUN cp /usr/lib/oracle/11.2/client64/lib/libclntsh.so.11.1 /usr/lib && \
    cp /usr/lib/oracle/11.2/client64/lib/libnnz11.so /usr/lib

ENV ORACLE_HOME "/usr/lib/oracle/11.2/client64"
ENV LD_LIBRARY_PATH "/usr/lib/oracle/11.2/client64/lib:/usr/lib/oracle/11.2/client64"

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin

