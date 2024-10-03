func_wazhu(){
#=======================================================================
# FILE: ~installation_wazhu.sh
# USAGE: ./~installation_wazhu.sh
# DESCRIPTION: Installation et paramétrage de l'agent wazhu sur la machine
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
WAZUH_MANAGER="192.168.44.8"
hostname=$(hostname)
cdm_install="WAZUH_MANAGER=$WAZUH_MANAGER WAZUH_AGENT_NAME=$hostname dpkg -i ./wazuh-agent_4.8.1-1_amd64.deb"
rdl_deamon="systemctl daemon-reload"
enbl_deamon="systemctl enable wazuh-agent"
start_deamon="systemctl start wazuh-agent"
#=======================================================================
##Définition des fonctions

func_installation_wazhu(){
    if [ "$EUID" -ne 0 ]; then
        $cdm_install
        $rdl_deamon
        $enbl_deamon
        $start_deamon
    else
        sudo $cdm_install
        sudo $rdl_deamon
        sudo $enbl_deamon
        sudo $start_deamon
    fi
}

#=======================================================================
##Script

echo "Téléchargement du paquet Wazhu"
	if wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.8.1-1_amd64.deb 2>> $log_erreurs; then
		echo "Téléchargement du paquet Wazhu réussie"
	else
		echo "Erreur lors du téléchargement du paquet Wazhu"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Installation du paquet Wazhu"
	if func_installation_wazhu 2>> $log_erreurs; then
		echo "Installation du paquet Wazhu réussie"
	else
		echo "Erreur lors de l'installation du paquet Wazhu"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2
}

 

 