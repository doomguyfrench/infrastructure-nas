echo "VOUS VOICI DANS L'INSTALLATION DE MON SYSTÈME D'INFRASTRUCTURE RESAUX"
echo "vous allez installez une configuration nas un system qui peremetera de voir vos film et un system de muisque et de l automatisation"

sudo apt install samba -y
sudo apt install nodejs npm -y
sudo apt install ufw -y
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt update 
sudo apt upgrade 

echo "vous voici dans la section sur le nas"

username_system=$(whoami) 

echo "quelle est le nom que vous voulez donnez a votre dossier de partage ?"
read nom_dossier

mkdir -p ~/"$nom_dossier"
chmod 777 ~/"$nom_dossier"

sudo tee -a /etc/samba/smb.conf >/dev/null  << EOF 
[SharedFolder]
   path = /home/$username_system/$nom_dossier
   available = yes
   valid users = $username_system
   read only = no
   browsable = yes
   public = yes
   writable = yes
EOF
sudo testparm

echo"ok la on est sur la deusieme partie quelle sera ton mots de passe "
sudo smbpasswd -a "$username_system"

sudo systemctl status smbd

echo "samba va redemareé"
sudo systemctl restart smbd
sudo systemctl restart nmbd

echo"samba va commancez a chaque start up"

sudo systemctl enable smbd
sudo systemctl enable nmbd


ip_nas=$(hostname -I | awk '{print $1}')
echo "l'adresse de ton NAS pour Windows est :\\$ip_nas\\$nom_dossier"
echo"pour y accedez tape juste ton nom de user linux et le mots de passe que tu a rensiegnez "


mkdir~/"$nom_dossier"/jellyfin/library
mkdir~/"$nom_dossier"jellyfin/tvseries
mkdir~/"$nom_dossier"jellyfin/movies

mkdir ~/docker/jellyfin
cd ~/docker/jellyfin
touch docker-compose.yml
echo  "
---
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - JELLYFIN_PublishedServerUrl=http://192.168.0.5 #optional
    volumes:
      - ~/"$nom_dossier"/jellyfin/library:/config
      - ~/"$nom_dossier"/jellyfin/tvseries:/data/tvshows
      - ~/"$nom_dossier"jellyfin/movies:/data/movies
    ports:
      - 8096:8096
      - 8920:8920 
      - 7359:7359/udp 
      - 1900:1900/udp 
    restart: unless-stopped



">>docker-compose.yml
docker-compose up -d

cd ~/docker/


sudo ufw allow samba
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw enable














sudo systemctl status smbd
