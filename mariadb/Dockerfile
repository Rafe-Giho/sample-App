FROM mariadb:10.11.10-jammy

COPY conf/charset.cnf /etc/mysql/conf.d/charset.cnf

COPY init/*.sql /docker-entrypoint-initdb.d/

RUN chmod 644 /etc/mysql/conf.d/charset.cnf \
    && chmod 644 /docker-entrypoint-initdb.d/*.sql

