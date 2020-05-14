FROM debian:buster

MAINTAINER 'Daniel DOS SANTOS' < danielitto91@gmail.com >

ENV DW_VERSION 2018-04-22c
ENV DW_MD5 6272e552b9a71a764781bd4182dd2b7d

# Mise à jour et autres paquets
RUN apt update && apt full-upgrade -y && apt install -y \
    wget \
    vim \
    unzip \
    locales 

# Installation Apache2
RUN apt install -y \
    apache2 \
    libapache2-mod-php7.3

RUN a2enmod rewrite
RUN service apache2 start

# Configuration des locales
RUN rm -rf /var/lib/apt/lists/* \
 && localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8

# Installation des paquets php
RUN apt update && apt install -y \
    php7.3 \
    php7.3-xml \
    php7.3-gd \
    php7.3-curl \
    php7.3-fpm \
    php7.3-zip \
    php7.3-mbstring

# Définir PHP7 par défaut
RUN a2enmod proxy_fcgi setenvif \
 && a2enconf php7.3-fpm

# PHP limite 1G
RUN sed -ir -e "s/max_execution_time = 30/max_execution_time = 240/g" /etc/php/7.3/cli/php.ini \
 && sed -ir -e "s/max_execution_time = 30/max_execution_time = 240/g" /etc/php/7.3/apache2/php.ini \
 && sed -ir -e "s/upload_max_filesize = 2M/upload_max_filesize = 1000M/g" /etc/php/7.3/cli/php.ini \
 && sed -ir -e "s/upload_max_filesize = 2M/upload_max_filesize = 1000M/g" /etc/php/7.3/apache2/php.ini \
 && sed -ir -e "s/post_max_size = 8M/post_max_size = 1000M/g" /etc/php/7.3/cli/php.ini \
 && sed -ir -e "s/post_max_size = 8M/post_max_size = 1000M/g" /etc/php/7.3/apache2/php.ini \
 && sed -ir -e "s/;date.timezone =/date.timezone = \"Europe\/Paris\"/g" /etc/php/7.3/cli/php.ini \
 && sed -ir -e "s/;date.timezone =/date.timezone = \"Europe\/Paris\"/g" /etc/php/7.3/apache2/php.ini

# Télechargement de Dokuwiki
ADD http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz /tmp/dokuwiki.tgz

# Vérification du fichier tgz
RUN if [ "$DW_MD5" != "$(md5sum /tmp/dokuwiki.tgz | awk '{print($1)}')" ];then echo "Erreur md5sum !"; exit 1; fi

# Décompression et déplacement de Dokuwiki
RUN tar xvf /tmp/dokuwiki.tgz -C /var/www/html/ \
 && mv /var/www/html/dokuwiki-* /var/www/html/dokuwiki \
 && rm /tmp/dokuwiki.tgz \
 && rm /var/www/html/index.html

# Droits sur le dossier dokuwiki
RUN chown -R www-data:www-data /var/www/html/dokuwiki

# Génération des clés
RUN openssl genrsa -out /etc/ssl/private/dokuwikiperso.key 2048

# Demande de certificat
RUN openssl req -new -key /etc/ssl/private/dokuwikiperso.key -out /etc/ssl/certs/dokuwikiperso.csr -subj "/C=FR/ST=ESSONNE/L=MASSY/O=MAISON/OU=client/CN=wiki.tpdaniel.fr/emailAddress=toto@gmail.com"

# Construction du certificat
RUN openssl x509 -req -days 365 -in /etc/ssl/certs/dokuwikiperso.csr -signkey /etc/ssl/private/dokuwikiperso.key -out /etc/ssl/certs/dokuwikiperso.crt

# Configuration de dokuwiki.conf
RUN printf '<VirtualHost *:80>\n \
   DocumentRoot /var/www/html/dokuwiki/\n \
   ServerName wiki.tpdaniel.fr\n \
   Redirect permanent / https://192.168.0.27/\n \
</VirtualHost>\n \
\n \
<VirtualHost _default_:443>\n \
\n \
   DocumentRoot /var/www/html/dokuwiki/\n \
   ServerName wiki.tpdaniel.fr\n \
\n \
   <Directory /var/www/html/dokuwiki/>\n \
      Options +FollowSymlinks\n \
      AllowOverride All\n \
   </Directory>\n \
\n \
   SetEnv HOME /var/www/html/dokuwiki\n \
   SetEnv HTTP_HOME /var/www/html/dokuwiki\n \
\n \
   ErrorLog /var/log/apache2/dokuwiki.error.log\n \
   CustomLog /var/log/apache2/access.log combined\n \
\n \
   SSLEngine On\n \
   SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire\n \
   SSLCertificateFile /etc/ssl/certs/dokuwikiperso.crt\n \
   SSLCertificateKeyFile /etc/ssl/private/dokuwikiperso.key\n \
\n \
</VirtualHost>\n' > /etc/apache2/sites-available/dokuwiki.conf
 
# Activation du site et des modules et vérification de la syntaxe du VirtuaHost
RUN a2dissite 000-default \
 && a2enmod ssl \
 && a2ensite dokuwiki \
 && apachectl configtest

# Expose le port 80 et 443
EXPOSE 80 443

# Démarrage d'Apache
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
