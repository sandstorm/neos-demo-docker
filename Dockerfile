FROM php:7.2-cli

WORKDIR /app

RUN mkdir -p /usr/share/man/man1
RUN mkdir -p /usr/share/man/man7

RUN dpkg --configure -a
RUN apt-get update && \
    apt-get install -yf --no-install-recommends && \
    apt-get clean && \
    apt-get -y autoremove && \
    apt-get install -yq libpq-dev unzip sudo

# RUN apt-cache search postgresql
# install db
RUN apt-get update && \
    apt-get install -fyq --no-install-recommends software-properties-common postgresql-contrib-11 postgresql-11 postgresql-client-11

# install php packages
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pdo_pgsql

# Install gd PHP extension and git/zip for composer
RUN apt-get update && \
    apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \
    apt-get install -y --no-install-recommends git zlib1g-dev

# Remove apt caches
RUN rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -s https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Create latest demo
RUN composer create-project --no-dev neos/neos-base-distribution .

# Clean up
RUN rm -rf /root/.composer/

ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

# Setting up postgresql
# And add ``listen_addresses`` to ``/etc/postgresql/9.6/main/postgresql.conf``
RUN mkdir -p /etc/postgresql/9.6/main/
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf

RUN ./flow core:setfilepermissions postgres postgres postgres

USER postgres

# https://docs.docker.com/engine/examples/postgresql_service/#install-postgresql-on-docker
#
# Create a PostgreSQL role named ``neos`` with ``neos`` as the password and
# then create a database `neos` owned by the ``neos`` role.
# Note: here we use ``&& \`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start && \
    psql -U postgres --command "CREATE USER neos WITH SUPERUSER PASSWORD 'neos';" && \
    createdb -O neos neos

# Install supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY ./supervisord.conf /supervisord.conf

ADD ./run_flow.sh /app/run_flow.sh
ADD ./Settings.yaml /app/Configuration/Settings.yaml

ADD ./memory.php.ini /usr/local/etc/php/conf.d

CMD ["/usr/local/bin/supervisord", "-c", "/supervisord.conf"]
