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
krb5_file="/etc/krb5.conf"
ntp_file="/etc/ntpsec/ntp.conf"
folder_file="/etc/pam.d/common-session:"
samba_file="/etc/samba/smb.conf"
sssd_file="/etc/sssd/sssd.conf"
domain="operis.champlan"
Allowed_GG=(GRP_ADM_POSTE GRP_ADM_DOM "Tous les sites")
root_file="/etc/sudoers"
sudo_file="etc/passwd"
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

func_krb5(){
cat <<EOF > $krb5_file
[libdefaults]
udp_preference_limit = 0
default_realm = OPERIS.CHAMPLAN

[realms]
  OPERIS.CHAMPLAN = {
    admin_server = VM2016DOMORV.OPERIS.CHAMPLAN
    kdc = VM2016DOMORV.OPERIS.CHAMPLAN
  }

[domain_realm]

EOF
}

func_heure(){
    sed -i '/# Specify one or more NTP servers./a server 192.168.3.72' $ntp_file
}

func_user_folder(){
    sed -i '/# end of pam-auth-update config/i session optional pam_mkhomedir.so skel=/etc/skel umask=077' $folder_file
}

func_samba(){
    sed -i "/workgroup = WORKGROUP/c\workgroup = OPERIS" $samba_file
    sed -i '/workgroup = OPERIS/a realm = OPERIS.CHAMPLAN' $samba_file
    sed -i '/realm = OPERIS.CHAMPLAN/a encrypt passwords = yes' $samba_file
    sed -i '/encrypt passwords = yes/a client protection = encrypt' $samba_file
}

func_sssd(){
    touch $sssd_file
    cat <<EOF > $sssd_file
[sssd]
domains = OPERIS.CHAMPLAN
config_file_version = 2
# services = nss, pam => ces services sont censés démarrer tout seuls, voir logs ci-dessous lus lors de bugs avec la synchro AD
# The pam responder has been configured to be socket-activated but it's still mentioned in the services' line in /etc/sssd/sssd.conf.
# Please, consider either adjusting your services' line in /etc/sssd/sssd.conf or disabling the pam's socket by calling:
# "systemctl disable sssd-pam.socket"
 
[domain/OPERIS.CHAMPLAN]
default_shell = /bin/bash
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = OPERIS.CHAMPLAN
realmd_tags = manages-system joined-with-adcli 
id_provider = ad
fallback_homedir = /home/%u
ad_domain = OPERIS.CHAMPLAN
use_fully_qualified_names = false
ldap_id_mapping = True
access_provider = ad
ad_gpo_ignore_unreadable = true
EOF

cp /usr/lib/x86_64-linux-gnu/sssd/conf/sssd.conf /etc/sssd/.
chmod 600 /etc/sssd/sssd.conf

}

func_allowedgg(){
    for GG in $Allowed_GG; do
        realm permit -g $GG  >> /dev/null 2>> $log_erreurs
    done
}

func_sudo(){
    sed -i '/root    ALL=(ALL:ALL) ALL/a operis    ALL=(ALL)  NOPASSWD:ALL' $samba_file
    sed -i '/operis    ALL=(ALL)  NOPASSWD:ALL/a %grp_adm_poste@OPERIS.CHAMPLAN    ALL=(ALL)  NOPASSWD:ALL' $samba_file
}

func_root(){
    sed -i "/root:x:0:0:root:/root:/bin/bash/c\# root:x:0:0:root:/root:/usr/sbin/nologin" $samba_file
}
#=======================================================================
###Script

echo "Mise a jour dependances pour l'intégration AD"
	if func_dependances 2>> $log_erreurs; then
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
echo "paramétrage du fichier krb5.conf"
	if func_krb5 >> /dev/null 2>> $log_erreurs; then
		echo "paramétrage du fichier krb5.conf réussie"
	else
		echo "Erreur lors du paramétrage du fichier krb5.conf"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##Synchronisation du temps de la machine avec le serveur
echo "Synchronisation du temps de la machine avec le serveur"
	if func_heure >> /dev/null 2>> $log_erreurs; then
		echo "Synchronisation du temps de la machine avec le serveur réussie"
	else
		echo "Erreur lors de la synchronisation du temps de la machine avec le serveur"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##paramétrage création dossier perso user
echo "Paramétrage création dossier perso user"
	if func_user_folder >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage création dossier perso user réussie"
	else
		echo "Erreur lors du paramétrage création dossier perso user"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##paramétrage samba
echo "Paramétrage samba"
	if func_samba >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage samba réussie"
	else
		echo "Erreur lors du paramétrage samba"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##paramétrage sssd
echo "Paramétrage sssd"
	if func_sssd >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage sssd réussie"
	else
		echo "Erreur lors du Paramétrage sssd"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##jonction au domain
echo "Validation configuration pour la jonction au domain"
	if realm discover $domain >> /dev/null 2>> $log_erreurs; then
		echo "Configuration pour jonction au domain correct"
	else
		echo "Erreur dans la configuration pour jonction au domain"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

echo "Jonction au domain"
    read -p "Veuillez saisir un compte administrateur domaine pour procéder à l'intégration au domains du poste:" user
    while ! id "$user@$domain" &> /dev/null ;do
        echo "nom d'utilisateur introuvable"
        read -p "Veuillez saisir un compte administrateur domaine pour procéder à l'intégration au domains du poste:" user
    done

	if realm join -U $user $domain >> /dev/null 2>> $log_erreurs; then
		echo "Jonction au domain réalisé avec succès"
	else
		echo "Erreur lors de la jonction au domain."
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2
 
##paramétrage des autorisations d'accès
echo "Paramétrage des autorisations d'accès"
	if func_allowedgg >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage des autorisations d'accès réussie"
	else
		echo "Erreur dans la configuration pour jonction au domain"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##gestion des droits sudos
echo "Gestion des droits sudos"
	if func_sudo >> /dev/null 2>> $log_erreurs; then
		echo "Gestion des droits sudos réussie"
	else
		echo "Erreur dans la gestion des droits sudos"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

##désactivation du compte root
echo "Désactivation du compte root"
	if func_root >> /dev/null 2>> $log_erreurs; then
		echo "Désactivation du compte root réussie"
	else
		echo "Erreur dans la désactivation du compte root"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
	fi
    sleep 2

}