FROM php:7.2-cli

WORKDIR /app

RUN mkdir -p /usr/share/man/man1
RUN mkdir -p /usr/share/man/man7

RUN apt-get update && apt-get -f install
RUN apt-get clean && apt-get autoremove
RUN dpkg --configure -a

RUN apt-get install -y libpq-dev unzip

# RUN apt-cache search postgresql
# install db
RUN apt-get -y -q install software-properties-common
RUN apt-get -f install -y -q postgresql-contrib-9.6 postgresql-9.6 postgresql-client-9.6

# install php packages
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pdo_pgsql

# Install gd PHP extension
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN apt-get install -y \
       --no-install-recommends git zlib1g-dev

#install composer
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# craete latest demo
RUN composer create-project --no-dev neos/neos-base-distribution .

# clean up
RUN rm -rf /root/.composer/

ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

# Setting up postgresql
# And add ``listen_addresses`` to ``/etc/postgresql/9.6/main/postgresql.conf``
RUN mkdir -p /etc/postgresql/9.6/main/
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf

USER postgres

# https://docs.docker.com/engine/examples/postgresql_service/#install-postgresql-on-docker
#
# Create a PostgreSQL role named ``neos`` with ``neos`` as the password and
# then create a database `neos` owned by the ``neos`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql -U postgres --command "CREATE USER neos WITH SUPERUSER PASSWORD 'neos';" &&\
    createdb -O neos neos

# Supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY ./supervisord.conf /supervisord.conf

ADD ./run_flow.sh /app/run_flow.sh
ADD ./Settings.yaml /app/Configuration/Settings.yaml

ADD ./memory.php.ini /usr/local/etc/php/conf.d

CMD ["/usr/local/bin/supervisord", "-c", "/supervisord.conf"]
