echo "VOUS VOICI DANS L'INSTALLATION DE MON SYSTÈME D'INFRASTRUCTURE RESAUX"
echo "vous allez installez une configuration nas un system qui peremetera de voir vos film et un system de muisque et de l automatisation"
sudo apt update -y
sudo apt upgrade -y
sudo apt install samba -y
sudo apt install nodejs npm -y
sudo apt install ufw -y
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo apt update -y
sudo apt upgrade -y

echo "vous voici dans la section sur le nas"
 
username_system="${SUDO_USER:-$(whoami)}" 
echo "utilisateur detecteé :$username_system"
sudo usermod -aG docker "$username_system"
echo "la possibilité d exectué des commande docker vous a ete donnez"

echo "quelle est le nom que vous voulez donnez a votre dossier de partage ?"
read nom_dossier

mkdir -p /home/$username_system/"$nom_dossier"
chmod 777 /home/$username_system/"$nom_dossier"

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



echo "samba va redemareé"
sudo systemctl restart smbd
sudo systemctl restart nmbd

echo"samba va commancez a chaque start up"

sudo systemctl enable smbd
sudo systemctl enable nmbd


ip_nas=$(hostname -I | awk '{print $1}')
echo "l'adresse de ton NAS pour Windows est :\\$ip_nas\\$nom_dossier"
echo"pour y accedez tape juste ton nom de user linux et le mots de passe que tu a rensiegnez "


mkdir -p "/home/$username_system/$nom_dossier/jellyfin/library"
mkdir -p "/home/$username_system/$nom_dossier/jellyfin/tvseries"
mkdir -p "/home/$username_system/$nom_dossier/jellyfin/movies"

mkdir -p /home/$username_system/docker/jellyfin
cd /home/$username_system/docker/jellyfin
touch docker-compose.yml
PUID=$(id -u "$username_system")
PGID=$(id -g "$username_system")

cat > docker-compose.yml << EOF
---
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Etc/UTC
      - JELLYFIN_PublishedServerUrl=http://$ip_nas
    volumes:
      - /home/$username_system/$nom_dossier/jellyfin/library:/config
      - /home/$username_system/$nom_dossier/jellyfin/tvseries:/data/tvshows
      - /home/$username_system/$nom_dossier/jellyfin/movies:/data/movies
    ports:
      - 8096:8096
      - 8920:8920
      - 7359:7359/udp
      - 1900:1900/udp
    restart: unless-stopped
EOF

sudo docker compose up -d
echo" tu peut accedez a jellyfin a cette adresse partout sur le wifi de chez toi http://$ip_nas:8096" 
cd /home/$username_system/docker/



mkdir -p /home/$username_system/docker/navidrome
mkdir -p "/home/$username_system/$nom_dossier/navidrome/data"
mkdir -p "/home/$username_system/$nom_dossier/navidrome/music"



cd /home/$username_system/docker/navidrome
touch docker-compose.yml

cat > docker-compose.yml << EOF
---
services:
  navidrome:
    image: deluan/navidrome:latest
    user: "$PUID:$PGID"
    ports:
      - "4533:4533"
    restart: unless-stopped

    volumes:
      - "/home/$username_system/$nom_dossier/navidrome/data:/data"
      - "/home/$username_system/$nom_dossier/navidrome/music:/music:ro"

EOF




sudo docker compose up -d
echo" tu peut accedez a navidrome a cette adresse partout sur le wifi de chez toi http://$ip_nas:4533" 

echo "installation de n8n"

sudo npm install -g n8n

sudo tee /etc/systemd/system/n8n.service > /dev/null <<EOF
[Unit]
Description=n8n Automation
After=network.target

[Service]
Type=simple
User=$username_system
Environment=HOME=/home/$username_system
ExecStart=$(which n8n)
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable n8n
sudo systemctl start n8n

echo "n8n est installe et demarrera automatiquement au prochain demarrage"
echo "n8n est accessible sur http://$ip_nas:5678"



sudo ufw allow samba
sudo ufw allow ssh
sudo ufw allow 4533/tcp
sudo ufw allow 8096/tcp
sudo ufw allow 5678/tcp
sudo ufw enable

