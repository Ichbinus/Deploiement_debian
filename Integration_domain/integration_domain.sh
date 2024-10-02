func_integration_domain(){
#=======================================================================
# FILE: ~integration_domain.sh
# USAGE: ./~integration_domain.sh
# DESCRIPTION: Intégration au domain operis, gestion des droits de connexion,
# paramétrage de connexion kerberos, gestion des droits sudo
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
folder=$(pwd) ##dossier local
log_erreurs="$folder/err_log.log"
#=======================================================================
##Définition des fonctions
func_dependances(){
	apt-get update
	apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit policykit-1 ntpdate ntp krb5-user libsss-sudo libsasl2-modules-ldap libpam-mount samba samba-common
}

func_nommage(){
    read -p "comment voulez-vous nommer ce poste?" nom_poste
    echo $nom_poste > /etc/hostname
    sed -i "/^127.0.1.1/c\127.0.1.1 $nom_poste.operis.champlan $nom_poste" /etc/hosts
}

#=======================================================================
###Script

echo "Mise a jour dependances pour l'intégration AD"
	if func_dependances >> /dev/null 2>> $log_erreurs; then
		echo "Mise a jour dependances nécessaire à l'intégration AD réussie"
	else
		echo "Erreur lors de la mise a jour dependances nécessaire à l'intégration AD"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2


##nommage du poste
echo "Mise a jour dependances pour l'intégration AD"
	if func_nommage >> /dev/null 2>> $log_erreurs; then
		echo "Renommage du poste réussie"
	else
		echo "Erreur lors du renommage du poste"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##configuration kerberos

##Synchronisation du temps de la machine avec le serveur

##paramétrage création dossier perso user

##paramétrage samba

##paramétrage sssd

##jonction au domain

##paramétrage des autorisations d'accès

##gestion des droits sudos

##désactivation du compte root

}