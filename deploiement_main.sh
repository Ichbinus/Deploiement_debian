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
source "$folder/Laps_Linux/laps.sh"
#source "installation vpn"
#source "paramétrage des depots"
#source "installation des paquets métier"
#source "installation applications (teams,...)"

func_menu()
{
## affichage du menu
echo "GESTION DE DEPLOIEMENT DE POSTES DEBIAN"
echo "----------------------------------------"
echo "G - Déploiement/intégration complète du poste au domaine"
echo "M - Installation Malwarebytes"
echo "D - Intégration au domaine"
echo "O - Installation OCS"
echo "L - Installation LAPS"
echo "V - Installation vpn"
echo "R - Paramétrage des depots"
echo "P - Installation des paquets métier"
echo "A - Installation applications (teams,...)"
echo ""
echo "Q - quitter"
read -n 1 -p "votre choix: " choix
}
#=======================================================================
## Nettoyage de l'écran
#clear

#=======================================================================
##Script
while true ;do
        ## Affichage menu
        func_menu

        ## gestion des saisies de choix
        case $choix in

        g|G)
                #func_Déploiement/intégration complète du poste au domaine
                echo "Déploiement/intégration complète du poste au domaine"
                ;;
        m|M)
                func_malwarebytes
                #echo "Installation Malwarebytes"
                ;;
        d|D)
                func_integration_domain
                #echo "Intégration au domaine"
                ;;
        o|O)
                func_ocs
                echo "Installation OCS"
                ;;
        l|L)
                #func_laps
                echo "Installation LAPS"
                ;;
        v|V)
                #func_Installation vpn
                echo "Installation vpn"
                ;;
        r|R)
                #func_Paramétrage des depots
                echo "Paramétrage des depots"
                ;;
        p|P)
                #func_Installation des paquets métier
                echo "Installation des paquets métier"
                ;;
        a|A)
                #func_Installation applications (teams,...)
                echo "Installation applications (teams,...)"
                ;;
        q|Q)
                exit 1
                ;;
        esac

done