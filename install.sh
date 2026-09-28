echo "VOUS VOICI DANS L'INSTALLATION DE MON SYSTÈME D'INFRASTRUCTURE RESAUX"
echo "vous allez installez une configuration nas un system qui peremetera de voir vos film et un system de muisque et de l automatisation"
sudo apt update 
sudo apt upgrade 
sudo apt install samba -y
sudo apt install nodejs npm -y

echo "vous voici dans la section sur le nas"

username_system=$(whoami) 

echo "quelle est le nom que vous voulez donnez a votre dossier de partage"
read nom_dossier
mkdir ~/$nom_dossier
chmod 777 ~/$nom_dossier

cat >> /etc/samba/smb.conf << EOF 
[SharedFolder]
   path = /home/$username_system/$nom_dossier
   available = yes
   valid users = $username_system
   read only = no
   browsable = yes
   public = yes
   writable = yes
   EOF












sudo systemctl status smbd
