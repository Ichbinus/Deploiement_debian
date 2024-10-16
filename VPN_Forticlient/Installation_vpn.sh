func_Installation_vpn()
{
#=======================================================================
# FILE: ~installation_vpn.sh
# USAGE: ./~installation_vpn.sh
# DESCRIPTION: Installation et paramétrage du vpn-ssl forticlient sur
# les postes Utilisateurs Debian 
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: Maxime Tertrais
# COMPANY: Operis
# CREATED: 15/10/2024
# REVISION: ---
#=======================================================================
##Définition des variables
folder=$(pwd) ##dossier local
log_erreurs="$folder/err_log.log"
CERT_PATH1="$folder/VPN_Forticlient/client.pfx"
CERT_PATH2="/opt/forticlient/client.pfx"


#=======================================================================
##Définition des fonctions
func_dependances(){
	apt-get update
}

func_installation(){
	wget -O - https://repo.fortinet.com/repo/7.0/ubuntu/DEB-GPG-KEY | apt-key add - #ajout de la clé du dépôt fortinet
    printf "deb [arch=amd64 signed-by=/usr/share/keyrings/repo.fortinet.com.gpg] https://repo.fortinet.com/repo/7.0/ubuntu xenial multiverse\n" | tee /etc/apt/sources.list.d/repo.fortinet.com.list
    apt-get update
    apt install -y forticlient
    mv $CERT_PATH1 $CERT_PATH2
    chown root:root $CERT_PATH2
}

#=======================================================================
##Script
echo -e "\033[1m Mise a jour dependances pour l'installation du vpn\033[0m"
	if func_dependances 2>> $log_erreurs; then
		echo "Mise a jour dependances nécessaire à l'installation du vpn réussie"
	else
		echo "Erreur lors de la mise a jour dependances nécessaire à l'installation du vpn"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "\033[1m Installation du vpn\033[0m"
	if func_installation 2>> $log_erreurs; then
		echo "Installation du vpn réussie"
	else
		echo "Erreur lors de l'installation du vpn"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "\033[1m Configuration du vpn \033[0m"
echo "Pour configurer la connexion vpn, charger dans le forticlient le fichier forti_7_linux.conf"
echo "Emplacement du fichier /tmp/Deploiement_debian/VPN_Forticlient/forti_7_linux.conf\n"
echo "Saisir le mot de passe du certificat dans les paramètres de la connexion"
echo "Le mot de passe est dans le keypass du service infra"

}