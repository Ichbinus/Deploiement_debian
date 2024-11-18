func_ocs()
{
#=======================================================================
# FILE: ~ocs.sh
# USAGE: ./~ocs.sh
# DESCRIPTION: Installation du package ocs et du certificat nécessaire au fonctionnement en https
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: Maxime Tertrais
# COMPANY: Operis
# CREATED: 30/09/2024
# REVISION: ---
#=======================================================================
##Définition des variables

server="https://srv-vrm-ocs-001.operis.champlan/ocsinventory"
basevardir="/var/lib/ocsinventory-agent"
configdir="/etc/ocsinventory-agent"
logfile="/var/log/ocsagent.log"
ca="$configdir/cacert.pem"
folder=$(pwd) ##dossier local
log_erreurs="$folder/err_log.log"

#=======================================================================
##Définition des fonctions
func_dependances(){
	apt-get update
	apt install -y make gcc libmodule-install-perl dmidecode libxml-simple-perl libcompress-zlib-perl openssl libnet-ip-perl libwww-perl libdigest-md5-perl libdata-uuid-perl libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl net-tools libsys-syslog-perl pciutils smartmontools read-edid nmap libnet-netmask-perl
}

func_nettoyage(){
	rm -r $basevardir || true
	rm -r $configdir || true
	rm -r $logfile || true
}

func_decompression(){
	tar xvzf "$folder/OCS_Linux/Ocsinventory-Unix-Agent-2.10.2.tar.gz"
	cd "$folder/Ocsinventory-Unix-Agent-2.10.2"
}

func_installation(){
	env PERL_AUTOINSTALL=1 perl Makefile.PL && make && make install && perl postinst.pl --server=$server --basevardir=$basevardir --configdir=$configdir --logfile=$logfile --crontab  --tag=$service --ssl=1 --nosoftware=0 --ca=$ca --debug --snmp --nowizard
	mv "$folder/OCS_Linux/cacert.pem" $configdir
}
#======================================================================= 
##Script

echo "Mise a jour dependances OCS"
	if func_dependances >> /dev/null 2>> $log_erreurs; then
		echo "Mise a jour dependances OCS réussies"
	else
		echo "Erreur lors de la mise a jour dependances OCS"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

echo "nettoyage version precedente de l'agent ocs"
	if func_nettoyage >> /dev/null 2>> $log_erreurs; then
		echo "Nettoyage des versions précédentes OCS réussies"
	else
		echo "Erreur lors du nettoyage des versions précédentes OCS"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

echo "decompression archive de l'Agent"
	if func_decompression >> /dev/null 2>> $log_erreurs; then
		echo "Décompression du package OCS réussies"
	else
		echo "Erreur lors de la décompression du package OCS"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

echo "Installation sans interaction de l'agent"
    read -p "Le poste est déployé dans quel service?" service
	if func_installation 2>> $log_erreurs; then
		echo "Installation du package OCS réussies"
	else
		echo "Erreur lors de l'installation du package OCS"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

echo "test de la connexion au serveur"
	if ocsinventory-agent --server $server >> /dev/null 2>> $log_erreurs;then
		echo "Connexion au serveur OCS réussie"
	else
		echo "Tentative de connexion au serveur OCS échouée"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
	cd ../
    sleep 2
}