FROM ubuntu:xenial
MAINTAINER Martinko Klingac devklingac@gmail.com

# Usage:
# docker run -d --name=apache-php-oci -p 8080:80 -p 8443:443 klingac/apache-php-oci
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get -y install \
      aptitude \
      apache2 \
      libapache2-mod-php \
      php \
      php-pdo \
      libaio-dev \
      unzip \
      php-pear \
      php-dev \
      && apt-get clean \
      && rm -r /var/lib/apt/lists/*

RUN a2dismod mpm_event && \
    a2enmod mpm_prefork \
            ssl \
            rewrite && \
    a2ensite default-ssl && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

COPY apache2-foreground /usr/local/bin/

# Oracle instantclient
COPY instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/
COPY instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/
COPY instantclient-sqlplus-linux.x64-12.1.0.2.0.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus
RUN rm /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip
RUN rm /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip
RUN rm /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip

RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8
RUN echo "extension=oci8.so" > /etc/php/7.0/mods-available/oci8.ini
RUN phpenmod oci8

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D FOREGROUND"]
