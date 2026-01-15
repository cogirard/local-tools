Local tools
===========

Ce repository contient des outils permettant d'utiliser et d'exploiter localement et facilement des applications web hébergées sous docker.

### Traefik
Traefik est un proxypass utilisé ici pour permettre d'accéder aux différents containers docker grâce à des noms de domaine locaux.

### Mailpit
Mailpit est un outil permettant de tester l'envoi de mails en les interceptant grâce à un serveur SMTP de test. Ces mails sont alors visualisables sur une interface WEB.

## Installation

1. Cloner le projet `git@github.com:cogirard/local-tools.git`
2. Créer le fichier `traefik/traefik.yml` à partir du fichier `traefik/traefik.yml.dist`
   1. L'entrée `providers.docker.defaultRule` définit le pattern du nom de domaine utilisé par tous les containers configurés pour utiliser `traefik`. Par défaut, ce pattern utilise le TLD `.localhost`.
      1. Utiliser le TLD `.localhost` permet d'accéder à tous les containers sans modifier le fichier `/etc/hosts`. Par défaut, les navigateurs résolvent les domaines ayant le TLD `.localhost` vers `127.0.0.1`
   2. L'entrée `providers.docker.network` indique le réseau docker utilisé par `traefik`. Il est nécessaire de le créer avant de up le container `traefik` : `docker network create traefik-network`
3. Créer le fichier `.env` à partir du fichier `.env.dist`.
   1. La variable `COMPOSE_PROJECT_NAME` définit le nom du projet pour docker.
   2. La variable `TRAEFIK_UI_PORT` définit quel port local sera utilisé pour accéder à l'interface de traefik. À NOTER : Cette variable ne sert que pour faire la redirection de port dans les labels traefik.
   3. La variable `MAILPIT_HTTP_PORT` définit quel port local sera utilisé pour accéder à l'interface de mailpit. À NOTER : Cette variable ne sert que pour faire la redirection de port dans les labels traefik.
4. Exécuter la commande `make up` pour build les images du projet et monter les containers.

## Exemple d'utilisation

Avec la configuration suivante, le container `ma-super-application` sera connecté au réseau `traefik-network` et aura pour nom de domaine `ma-super-application.localhost`.
<br>À noter : Grâce à l'entrée `providers.docker.defaultRule` de la configuration traefik, il n'est pas nécessaire de définir une règle par container.

```
networks:
    traefik:
        external: true
        name: traefik-network

services:
    nginx:
        container_name: ma-super-application
        image: nginx:latest
        volumes:
            - ./docker/default.conf:/etc/nginx/conf.d/default.conf
            - ./:/app
        networks:
            - traefik
        labels:
            - traefik.enable=true
            - traefik.http.routers.ma-super-application.entrypoints=http
```
