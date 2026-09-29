# 🖥️ Système d'infrastructure réseau

Ce projet permet de transformer une machine Debian en **petit serveur d'infrastructure domestique** avec plusieurs services installés et configurés automatiquement.

Le script installe et configure :

* 📁 **Samba** — partage de fichiers sur le réseau
* 🐳 **Docker** — gestion des conteneurs
* 🎬 **Jellyfin** — serveur de films et séries
* 🎵 **Navidrome** — serveur de musique
* 🔥 **UFW** — pare-feu
* 🟢 **systemd** — démarrage automatique des services

---

## ⚙️ Prérequis

Le système doit utiliser une distribution basée sur Debian et disposer de :

* Une connexion Internet
* Un utilisateur Linux avec des droits `sudo`
* Un stockage suffisant pour les films, séries et musiques
* Un réseau local fonctionnel

Le script doit être lancé avec `sudo` afin que `SUDO_USER` permette d'identifier l'utilisateur Linux réel.

Exemple :

```bash
sudo ./install.sh
```

---

# 🚀 Installation

Lancer simplement :

```bash
sudo ./install.sh
```

Le script va ensuite :

1. Mettre à jour le système
2. Installer Samba
3. Installer Node.js et npm
4. Installer UFW
5. Installer Docker et Docker Compose
6. Identifier l'utilisateur Linux
7. Créer le partage réseau
8. Configurer Samba
9. Configurer Jellyfin
10. Configurer Navidrome
11. Configurer le pare-feu

---

# 📁 Structure du serveur

Après l'installation, la structure ressemble à ceci :

```text
/home/<utilisateur>/
│
├── <nom_du_partage>/
│   │
│   ├── jellyfin/
│   │   ├── library/
│   │   ├── tvseries/
│   │   └── movies/
│   │
│   └── navidrome/
│       ├── data/
│       └── music/
│
└── docker/
    │
    ├── jellyfin/
    │   └── docker-compose.yml
    │
    ├── navidrome/
    │   └── docker-compose.yml

```

---

# 📁 Samba

Samba permet d'accéder au dossier partagé depuis Windows ou un autre ordinateur du réseau.

Le chemin ressemble à :

```text
\\IP_DU_SERVEUR\nom_du_partage
```

Par exemple :

```text
\\192.168.1.67\Films
```

L'utilisateur Samba est le même utilisateur Linux utilisé par le script.

Le mot de passe Samba est demandé pendant l'installation :

```bash
sudo smbpasswd -a <utilisateur>
```

---

# 🎬 Jellyfin

Jellyfin est installé dans un conteneur Docker.

### Port

```text
8096/TCP
```

Accès depuis le réseau local :

```text
http://IP_DU_SERVEUR:8096
```

### Dossiers

```text
jellyfin/library  → /config
jellyfin/tvseries → /data/tvshows
jellyfin/movies   → /data/movies
```

Les films et séries peuvent donc être stockés directement dans le partage réseau.

---

# 🎵 Navidrome

Navidrome permet de transformer le serveur en serveur de musique.

### Port

```text
4533/TCP
```

Accès :

```text
http://IP_DU_SERVEUR:4533
```

### Dossiers

```text
navidrome/data  → /data
navidrome/music → /music
```

Le dossier `music` est monté en lecture seule dans le conteneur :

```yaml
- "/home/<utilisateur>/<partage>/navidrome/music:/music:ro"
```


---

# 🐳 Docker

Jellyfin et Navidrome fonctionnent avec Docker Compose.

### Jellyfin

```bash
cd ~/docker/jellyfin
sudo docker compose up -d
```

### Navidrome

```bash
cd ~/docker/navidrome
sudo docker compose up -d
```

### Voir les conteneurs

```bash
sudo docker ps
```

### Arrêter les conteneurs

```bash
sudo docker compose down
```

---

# 🔥 Pare-feu

UFW autorise les services nécessaires :

| Service   |      Port | Protocole |
| --------- | --------: | --------- |
| SSH       |        22 | TCP       |
| Samba     | 445 / 139 | TCP       |
| Navidrome |      4533 | TCP       |
| Jellyfin  |      8096 | TCP       |


Le pare-feu est activé avec :

```bash
sudo ufw enable
```

Pour vérifier :

```bash
sudo ufw status
```

---

# 🔄 Démarrage automatique

Les services suivants sont configurés pour démarrer automatiquement :

### Samba

```bash
sudo systemctl enable smbd
sudo systemctl enable nmbd
```


### Docker

Docker est installé comme service système et gère le redémarrage des conteneurs grâce à :

```yaml
restart: unless-stopped
```

---

# 🛠️ Dépannage

## Vérifier Samba

```bash
sudo systemctl status smbd
```

Tester la configuration :

```bash
sudo testparm
```

---

## Vérifier Docker

```bash
sudo systemctl status docker
```

Puis :

```bash
sudo docker ps
```

---

## Vérifier Jellyfin

```bash
cd ~/docker/jellyfin
sudo docker compose ps
sudo docker compose logs
```

---

## Vérifier Navidrome

```bash
cd ~/docker/navidrome
sudo docker compose ps
sudo docker compose logs
```

---


---

# 🧱 Architecture

```text
                       ┌─────────────────────┐
                       │    SERVEUR DEBIAN   │
                       │                     │
                       │   Docker / systemd  │
                       └──────────┬──────────┘
                                  │
             ┌────────────────────┼
             │                    │                    
             ▼                    ▼                    
          Samba                Docker              
       partage NAS          ┌─────┴─────┐           
                            │           │
                            ▼           ▼
                         Jellyfin   Navidrome
                          :8096       :4533
                            │           │
                            ▼           ▼
                          Films       Musique
                         Séries
```

---

# 📌 Résumé

Ce projet fournit une base d'infrastructure permettant d'avoir sur une seule machine :

```text
📁 NAS
🎬 Serveur multimédia
🎵 Serveur musical
⚙️ Automatisation
🐳 Conteneurs Docker
🔥 Pare-feu
🔄 Démarrage automatique
```

L'objectif est d'avoir une installation reproductible permettant de transformer rapidement une machine Debian en serveur domestique polyvalent.

---

## ⚠️ Notes

Le script est destiné principalement à un **réseau local**.

Avant une exposition sur Internet, il est recommandé de mettre en place des mesures supplémentaires : HTTPS, authentification correctement configurée, contrôle des accès, sauvegardes et éventuellement un reverse proxy.