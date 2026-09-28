echo "VOUS VOICI DANS L'INSTALLATION DE MON SYSTÈME D'INFRASTRUCTURE RESAUX"
echo "vous allez installez une configuration nas un system qui peremetera de voir vos film et un system de muisque et de l automatisation"
sudo apt update 
sudo apt upgrade 
sudo apt install samba -y
sudo apt install nodejs npm -y
sudo apt install ufw -y

echo "vous voici dans la section sur le nas"

username_system=$(whoami) 

echo "quelle est le nom que vous voulez donnez a votre dossier de partage ?"
read nom_dossier
echo"voici la partie la plus importante quelle va etre ton nom de utulisateur"
read nom_utulisateur
mkdir -p ~/"$nom_dossier"
chmod 777 ~/"$nom_dossier"

sudo tee -a /etc/samba/smb.conf >/dev/null  << EOF 
[SharedFolder]
   path = /home/$username_system/$nom_dossier
   available = yes
   valid users = $nom_utulisateur
   read only = no
   browsable = yes
   public = yes
   writable = yes
EOF
sudo testparm

echo"ok la on est sur la deusieme partie quelle sera ton mots de passe "
sudo smbpasswd -a "$nom_utulisateur"

sudo systemctl status smbd

echo "samba va redemareé"
sudo systemctl restart smbd
sudo systemctl restart nmbd

echo"samba va commancez a chaque start up"

sudo systemctl enable smbd
sudo systemctl enable nmbd


echo "l adresse de ton nas est pour windose  $(ip -4 addr)/"$nom_dossier"


sudo ufw allow samba
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw enable















sudo systemctl status smbd
