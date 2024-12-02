func_integration_domain()
{
#=======================================================================
# FILE: ~integration_domain.sh
# USAGE: ./~integration_domain.sh
# DESCRIPTION: Intégration au domain operis, gestion des droits de connexion,
# paramétrage de connexion kerberos, gestion des droits sudo, ajout d'une 
# tâche cron de mise à jour automatique
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
folder_file="/etc/pam.d/common-session"
samba_file="/etc/samba/smb.conf"
sssd_file="/etc/sssd/sssd.conf"
domain="operis.champlan"
local_admin="operis"
GG_admin="grp_adm_poste"
cron_file="/etc/crontab"
cron_job="0 9 * * * bash /root/apt-update.sh"
script_auto_update_src="$folder/Integration_domain/apt-update.sh"
script_auto_update_dst="/root/apt-update.sh"
#=======================================================================
##Définition des fonctions
func_dependances(){
	apt-get update
	apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit policykit-1 ntpdate ntp krb5-user libsss-sudo libsasl2-modules-ldap libpam-mount samba samba-common
    }

func_nommage(){
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
    realm permit -g utilisateurs\ du\ domaine@operis.champlan  >> /dev/null 2>> $log_erreurs
    realm permit -g GRP_ADM_POSTE  >> /dev/null 2>> $log_erreurs
    realm permit -g GRP_ADM_DOM  >> /dev/null 2>> $log_erreurs
    }

func_sudo() {
    local sudoers_file="/etc/sudoers"
    # Créer une sauvegarde de sécurité du fichier sudoers
    cp $sudoers_file ${sudoers_file}.bak
    # Ajouter l'utilisateur local aux sudoers
    if ! grep -q "^$local_admin ALL=(ALL) NOPASSWD:ALL" $sudoers_file; then
        echo "$local_admin ALL=(ALL) NOPASSWD:ALL" >> $sudoers_file
        echo "Droits sudo ajoutés pour l'utilisateur local : $local_admin"
    else
        echo "L'utilisateur local $local_admin a déjà les droits sudo."
    fi
    # Ajouter le groupe AD aux sudoers
    if ! grep -q "^%$GG_admin@$domain ALL=(ALL) NOPASSWD:ALL" $sudoers_file; then
        echo "%$GG_admin@$domain ALL=(ALL) NOPASSWD:ALL" >> $sudoers_file
        echo "Droits sudo ajoutés pour le groupe AD : $GG_admin@$domain"
    else
        echo "Le groupe AD $GG_admin@$domain a déjà les droits sudo."
    fi
    # Vérifier la syntaxe de sudoers avant d'appliquer les modifications
    visudo -c
    if [ $? -eq 0 ]; then
        echo "Les modifications ont été appliquées avec succès."
    else
        echo "Erreur de syntaxe dans le fichier sudoers. Restauration de la sauvegarde."
        cp ${sudoers_file}.bak $sudoers_file
    fi
    }


func_root(){
    # Définir le fichier à modifier, qui est /etc/passwd, pas un fichier Samba
    local passwd_file="/etc/passwd"
        # Créer une sauvegarde de sécurité avant toute modification
    cp $passwd_file ${passwd_file}.bak
    # Désactiver la connexion root en modifiant le shell de login
    sed -i '/^root:x:0:0:root:/s#/bin/bash#/usr/sbin/nologin#' $passwd_file
    # Vérifier si la modification a été appliquée
    if grep -q "^root:x:0:0:root:/root:/usr/sbin/nologin" $passwd_file; then
        echo "Connexion root désactivée avec succès."
    else
        echo "Erreur lors de la désactivation de la connexion root."
    fi
}

func_cron(){
    sudo crontab -l | grep -F "$cron_job" > /dev/null
    if [ $? -eq 0 ]; then
        echo "Le job cron existe déjà dans la crontab de root."
    else
        # tranfert du script d'update dans le dossier /root/
        mv $script_auto_update_src $script_auto_update_dst
        chown root:root $script_auto_update_dst
        chmod +x $script_auto_update_dst
        # Ajouter le nouveau job cron
        (sudo crontab -l; echo "$cron_job") | sudo crontab -
    fi
}

#=======================================================================
###Script

echo "Mise a jour dependances pour l'intégration AD"
	if func_dependances 2>> $log_erreurs; then
		echo "Mise a jour dependances nécessaire à l'intégration AD réussie"
	else
		echo "Erreur lors de la mise a jour dependances nécessaire à l'intégration AD"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2


##nommage du poste
echo "nommage du poste en conformité avec le domaine"
    read -p "comment voulez-vous nommer ce poste?" nom_poste
    while [-z $nom_poste]; do
        echo "Erreur lors de la saisie du nom du poste."
        read -p "comment voulez-vous nommer ce poste?" nom_poste
    done

	if func_nommage >> /dev/null 2>> $log_erreurs; then
		echo "Renommage du poste réussie : $nom_poste@$domain"
	else
		echo "Erreur lors du renommage du poste"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##configuration kerberos
echo "paramétrage du fichier krb5.conf"
	if func_krb5 >> /dev/null 2>> $log_erreurs; then
		echo "paramétrage du fichier krb5.conf réussie"
	else
		echo "Erreur lors du paramétrage du fichier krb5.conf"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##Synchronisation du temps de la machine avec le serveur
echo "Synchronisation du temps de la machine avec le serveur"
	if func_heure >> /dev/null 2>> $log_erreurs; then
		echo "Synchronisation du temps de la machine avec le serveur réussie"
	else
		echo "Erreur lors de la synchronisation du temps de la machine avec le serveur"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##paramétrage création dossier perso user
echo "Paramétrage création dossier perso user"
	if func_user_folder >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage création dossier perso user réussie"
	else
		echo "Erreur lors du paramétrage création dossier perso user"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##paramétrage samba
echo "Paramétrage samba"
	if func_samba >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage samba réussie"
	else
		echo "Erreur lors du paramétrage samba"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##paramétrage sssd
echo "Paramétrage sssd"
	if func_sssd >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage sssd réussie"
	else
		echo "Erreur lors du Paramétrage sssd"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##jonction au domain
echo "Validation configuration pour la jonction au domain"
	if realm discover $domain >> /dev/null 2>> $log_erreurs; then
		echo "Configuration pour jonction au domain correct"
	else
		echo "Erreur dans la configuration pour jonction au domain"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Jonction au domain"
    read -p "Veuillez saisir un compte administrateur domaine pour procéder à l'intégration au domains du poste:" user
    while ! realm join -U "$user" "$domain" >> /dev/null 2>> "$log_erreurs"; do
        echo "Erreur lors de la jonction au domaine."
        echo "Nom d'utilisateur ou mot de passe incorrect. Veuillez réessayer."
        read -p "Veuillez saisir un compte administrateur domaine valide : " user
    done
    echo "Jonction au domaine réalisée avec succès."
    sleep 2
 
##paramétrage des autorisations d'accès
echo "Paramétrage des autorisations d'accès"
	if func_allowedgg >> /dev/null 2>> $log_erreurs; then
		echo "Paramétrage des autorisations d'accès réussie"
	else
		echo "Erreur dans la configuration pour jonction au domain"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##gestion des droits sudos
echo "Gestion des droits sudos"
	if func_sudo >> /dev/null 2>> $log_erreurs; then
		echo "Gestion des droits sudos réussie"
	else
		echo "Erreur dans la gestion des droits sudos"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

##désactivation du compte root
echo "Désactivation du compte root"
	if func_root >> /dev/null 2>> $log_erreurs; then
		echo "Désactivation du compte root réussie"
	else
		echo "Erreur dans la désactivation du compte root"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

}