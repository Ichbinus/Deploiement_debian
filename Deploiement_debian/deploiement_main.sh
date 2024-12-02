#!/bin/bash
#=======================================================================
# FILE: ~deploiement_main.sh
# USAGE: ./~deploiement_main.sh
# DESCRIPTION: menu de gestion du script globale de déploiement des postes utilisateurs debian
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
folder=$(pwd)

#=======================================================================
##Définition des fonctions
source "$folder/Malwarebytes_linux/malwarebytes.sh"
source "$folder/Integration_domain/integration_domain.sh"
source "$folder/OCS_Linux/ocs.sh"
source "$folder/Laps_Linux/installation_laps.sh"
source "$folder/VPN_Forticlient/Installation_vpn.sh"
source "$folder/Agent_Wazhu/installation_wazhu.sh"
#source "paramétrage des depots"
source "$folder/Packages_metiers/installations_packages.sh"

func_menu()
{
## affichage du menu
echo "GESTION DE DEPLOIEMENT DE POSTES DEBIAN"
echo "----------------------------------------"
echo "U - Déploiement/intégration complète au domaine type poste utilisateur"
echo "S - Déploiement/intégration complète au domaine type Serveur"
echo "M - Installation Malwarebytes"
echo "D - Intégration au domaine"
echo "O - Installation OCS"
echo "L - Installation LAPS"
echo "V - Installation vpn"
echo "W - Installation Wazhu"
echo "S - Montage des Partages Réseaux"
echo "R - Paramétrage des depots"
echo "P - Installation des paquets métier"
echo ""
echo "Q - quitter"
read -n 1 -p "votre choix: " choix
}


#=======================================================================
## Nettoyage de l'écran
clear

#=======================================================================
##Script
while true ;do
        ## Affichage menu
        func_menu

        ## gestion des saisies de choix
        case $choix in

        u|U)
                #func_Déploiement/intégration complète au domaine type poste utilisateur
                echo "Déploiement/intégration complète au domaine type poste utilisateur"
                ;;
        s|S)
                #func_Déploiement/intégration complète au domaine type Serveur
                echo "Déploiement/intégration complète au domaine type Serveur"
                ;;        
        m|M)
                echo ""
                func_malwarebytes
                #echo "Installation Malwarebytes"
                ;;
        d|D)
                echo ""
                func_integration_domain
                #echo "Intégration au domaine"
                ;;
        o|O)
                echo ""
                func_ocs
                #echo "Installation OCS"
                ;;
        l|L)
                echo ""
                func_installation_laps
                #echo "Installation LAPS"
                ;;
        v|V)
                echo ""
                func_Installation_vpn
                #echo "Installation vpn"
                ;;
        w|W)
                echo ""
                func_wazhu
                #echo "Installation Wazhu"
                ;;             
        r|R)
                echo ""
                #func_Paramétrage des depots
                echo "Paramétrage des depots"
                ;;
        p|P)
                echo ""
                func_installations_packages
                #echo "Installation des paquets métier"
                ;;
        q|Q)
                echo ""
                exit 1
                ;;
        esac

done