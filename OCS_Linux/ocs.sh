func_ocs()
{
#!/bin/bash
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
$folder=$(pwd) ##dossier local

#=======================================================================
##Script

echo "Mise a jour dependances OCS"
	apt-get update
	apt install -y make gcc libmodule-install-perl dmidecode libxml-simple-perl libcompress-zlib-perl openssl libnet-ip-perl libwww-perl libdigest-md5-perl libdata-uuid-perl libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl net-tools libsys-syslog-perl pciutils smartmontools read-edid nmap libnet-netmask-perl
    sleep 2

echo "nettoyage version precedente de l'agent ocs"
	rm -r $basevardir
	rm -r $configdir
	rm -r $logfile
    sleep 2

echo "decompression archive de l'Agent"
	tar xvzf "$folder/Ocsinventory-Unix-Agent-2.10.2.tar.gz"
	cd "$folder/Ocsinventory-Unix-Agent-2.10.2"
    sleep 2

echo "Installation sans interaction de l'agent"
    read -p "Les poste est déployé dans quel service?" service
	env PERL_AUTOINSTALL=1 perl Makefile.PL && make && make install && perl postinst.pl --server=$server --basevardir=$basevardir --configdir=$configdir --logfile=$logfile --crontab  --tag=$service --ssl=1 --nosoftware=0 --ca=$ca --debug --snmp --nowizard
	mv "$folder/cacert.pem" $configdir
	sleep 2

echo "test de la connexion au serveur"
	ocsinventory-agent --server $server

echo "nettoyage du dossier d'installation"
	cd /
	rm -r /Installateur_OCS_agent

}