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
3. Créer le fichier `.env` à partir du fichier `.env.dist`.
   1. La variable `COMPOSE_PROJECT_NAME` définit le nom du projet pour docker.
   2. La variable `TRAEFIK_UI_PORT` définit quel port local sera utilisé pour accéder à l'interface de traefik. À NOTER : Cette variable ne sert que pour faire la redirection de port dans les labels traefik.
   3. La variable `MAILPIT_HTTP_PORT` définit quel port local sera utilisé pour accéder à l'interface de mailpit. À NOTER : Cette variable ne sert que pour faire la redirection de port dans les labels traefik.
4. Exécuter la commande `make up` pour build les images du projet et monter les containers.

## Utilisation

### Traefik
Pour connecter des containers au container `traefik`, il est nécessaire d'ajouter le réseau externe `traefik-network` dans la configuration docker compose de votre projet et d'y connecter les containers pour lesquels un accès web est requis.

```yaml
networks:
    traefik:
        external: true
        name: traefik-network

services:
    exemple-nginx-ou-apache:
        networks:
            - reseau-existant-dans-le-projet
            - traefik
```

Ensuite, il faut configurer les labels pour ces containers. Avec une configuration basique (càd accès via le port 80 avec le domaine en TLD `.localhost`), seulement 2 labels sont requis : 

```yaml
networks:
    ...

services:
    exemple-nginx-ou-apache:
        networks:
            ...
        labels:
            - traefik.enable=true
            - traefik.http.routers.<nom-unique>.entrypoints=http
```

Dans la label permettant de configurer le point d'entrée `http`, il est nécessaire d'utiliser un nom arbitraire qui doit être unique du point de vue de traefik (2 containers ne peuvent pas posséder un router du même nom, peu importe le projet). Par habitude, on utilise la variable `${COMPOSE_PROJECT_NAME}` en tant que nom de router pour le container web principal d'un projet.

### Mailpit

Pour permettre à des containers d'envoyer des mails au container `mailpit`, il est nécessaire d'ajouter le réseau externe `mailpit-network` dans la configuration docker compose de votre projet et d'y connecter les container depuis lesquels des mails seront envoyés. Les containers connectés pourront alors communiquer avec le container mailpit via son nom : `mailpit`.

```yaml
networks:
    mailpit:
        external: true
        name: mailpit-network

services:
    exemple-php:
        networks:
            - reseau-existant-dans-le-projet
            - mailpit
```

Exemple avec la variable `MAILER_DSN` d'un projet php utilisant le composant symfony/mailer : `MAILER_DN=smtp://mailpit:1025`

## Exemple d'utilisation

Avec la configuration suivante, le container `ma-super-application` sera connecté aux réseaux `traefik-network` et `mailpit-network`. Il sera accessible depuis l'adresse `ma-super-application.localhost` et pourra envoyer des mails de test au container `mailpit`.
<br>À noter : Grâce à l'entrée `providers.docker.defaultRule` de la configuration traefik, il n'est pas nécessaire de définir une règle par container.

```yaml
networks:
    traefik:
        external: true
        name: traefik-network
    mailpit:
        external: true
        name: mailpit-network

services:
    nginx:
        container_name: ma-super-application
        image: nginx:latest
        volumes:
            - ./docker/default.conf:/etc/nginx/conf.d/default.conf
            - ./:/app
        networks:
            - traefik
            - mailpit
        labels:
            - traefik.enable=true
            - traefik.http.routers.ma-super-application.entrypoints=http
```
