func_installation_laps(){
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
keytab_file="$folder/Laps_Linux/User_Laps4Linux.keytab"
laps_script="$folder/Laps_Linux/laps.sh"
laps_folder="/etc/laps/"
cron_file="/etc/crontab"
cron_job="0 8 * * */2 /etc/laps/laps.sh"
#=======================================================================
##Définition des fonctions
func_folder(){
    if [ ! -d $laps_folder ];then
        echo "Création du dosser $laps_folder."
        mkdir $laps_folder
    else
        echo "Dosser $laps_folder déja existant."
    fi
}

func_transfert(){
    cp $keytab_file $laps_folder
    chmod u+x $laps_script
    cp $laps_script $laps_folder 
}

func_cron(){
    sudo crontab -l | grep -F "$cron_job" > /dev/null
    if [ $? -eq 0 ]; then
        echo "Le job cron existe déjà dans la crontab de root."
    else
        # Ajouter le nouveau job cron
        (sudo crontab -l; echo "$cron_job") | sudo crontab -
    fi
}

func_lancement_laps(){
    if [ "$EUID" -ne 0 ]; then
        /etc/laps/laps.sh
    else
        sudo /etc/laps/laps.sh
    fi
    
}
#=======================================================================
##Script
echo "Préparation de l'environnement laps"
	if func_folder 2>> $log_erreurs; then
		echo "Préparation de l'environnement laps réussie"
	else
		echo "Erreur lors de la préparation de l'environnement laps"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Transfert des éléments Laps"
	if func_transfert 2>> $log_erreurs; then
		echo "Transfert des éléments Laps réussie"
	else
		echo "Erreur lors du transfert des éléments Laps"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Automatisation du script Laps"
	if func_cron 2>> $log_erreurs; then
		echo "Le job cron de Laps a été ajouté à la crontab de root."
	else
		echo "Erreur lors du transfert des éléments Laps"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Premier lancement du script Laps"
	if func_cron 2>> $log_erreurs; then
		echo "Premier lancement du script Laps réussie."
        echo "Vous pouvez récupéré le mots de passe de l'admin local (operis) via le LAPS sur le contrôleur de domaine."
	else
		echo "Erreur lors du Premier lancement du script Laps"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

}