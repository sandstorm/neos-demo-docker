############
#
# 2. build base prod image
#
############
FROM php:7.3.9-fpm-buster

# Install intl, bcmath, pdo, pdo_mysql, mysqli, libvips
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y libpq-dev unzip sudo libvips-dev libvips42 libicu-dev libxslt1-dev nginx-light software-properties-common postgresql-contrib-11 postgresql-11 postgresql-client-11 git unzip && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
    docker-php-ext-install intl bcmath pdo pdo_mysql pdo_pgsql mysqli xsl && \
    pecl install vips && \
    echo "extension=vips.so" > /usr/local/etc/php/conf.d/vips.ini && \
    pecl install redis && docker-php-ext-enable redis && \
    # composer
    curl --silent --show-error https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer config --global cache-dir /composer_cache

RUN mkdir -p /var/lib/nginx /usr/local/var/log/ & \
    chown -R www-data /var/lib/nginx /usr/local/var/log/

ADD nginx.conf /etc/nginx/nginx.conf

RUN rm -Rf /usr/local/etc/php-fpm.*
ADD php-fpm.conf /usr/local/etc/php-fpm.conf

ADD memory-limit-php.ini /usr/local/etc/php/conf.d/memory-limit-php.ini

ENV FLOW_CONTEXT Production/Docker

RUN mkdir /app && chown -R postgres /app
RUN chown -R postgres /var/log /usr/local/var/log /var/lib/nginx
USER postgres
# Create latest demo
RUN composer create-project --no-dev neos/neos-base-distribution /app && \
    cd /app && composer require "jcupitt/vips"
#    && composer require "neos/flow:5.3.2"
RUN cd /app && composer require "rokka/imagine-vips"

RUN mkdir -p /app/Data/Persistent

WORKDIR /app

ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

# Setting up postgresql
# And add ``listen_addresses`` to ``/etc/postgresql/11/main/postgresql.conf``
RUN mkdir -p /etc/postgresql/11/main/
RUN echo "listen_addresses='*'" >> /etc/postgresql/11/main/postgresql.conf


# https://docs.docker.com/engine/examples/postgresql_service/#install-postgresql-on-docker
#
# Create a PostgreSQL role named ``neos`` with ``neos`` as the password and
# then create a database `neos` owned by the ``neos`` role.
# Note: here we use ``&& \`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start && \
    psql -U postgres --command "CREATE USER neos WITH SUPERUSER PASSWORD 'neos';" && \
    createdb -O neos neos && \
    /etc/init.d/postgresql stop

ADD entrypoint.sh /

ADD ./Settings.yaml /Settings.yaml

ENTRYPOINT ["/entrypoint.sh"]
