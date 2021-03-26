# :whale2: Image Docker de Dokuwiki personnalisée
## Configuration de php.ini et SSL incluse.

<img src="./DokuwikiWebInstalateur.png" width="70%">

 Dockerfile permettant d'avoir une image prêt à l’emploi de Dokuwiki:
 * Installation d'Apache2.4.
 * Installation de PHP7.3.
 * Installation et configuration de Dokuwiki 2018-04-22c.
 * Mise en place du SSL (certificat autosigné).
 * Configuration de php.ini.
 * Configuration des VirtualHosts.
 * Image basé sur Debian 10 (Buster).

## Usage

#### Pour construire l'image
1. `git clone https://github.com/DOSSANTOSDaniel/Dokuwiki_Dockerfile.git` 
2. `cd Dokuwiki_Dockerfile` 
3. `docker image build --tag montag .`

#### Pour créer et démarrer un conteneur 
`docker run -d -p 80:80 -p 443:443 "id_image"`

#### Pour créer et démarrer un conteneur avec un volume  
`docker run -d -v /home/host/dockervolume:/var/www/html -p 80:80 -p 443:443 "id_image"`

#### Se connecter sur l'interface web de l'installeur
https://IP_machine/

## Volumes
 * "/home/host/dockervolume" Volume sur le host.
 * "/var/www/html" Volume dans le conteneur.
 
### Pour la suite
- [ ] Ajouter des variables
- [ ] Revoir sécurité .htaccess
- [ ] Erreur apache2: Could not reliably determine the server's fully qualified domain name
- [ ] Avertissement espaces vides avec sed et apt
- [ ] Utilisation de debian_frontend=noninteractive
- [ ] Message apt-utils
- [ ] rm /var/www/dokuwiki/install.php
- [ ] Message apt cli instable rm /var/www/dokuwiki/install.php

- https://www.dokuwiki.org/security

- https://www.dokuwiki.org/rewrite

- https://www.dokuwiki.org/tips:maintenance

- https://www.dokuwiki.org/tips:timezone

- https://www.dokuwiki.org/tips
