#!/bin/bash
#=======================================================================
# FILE: ~apt-update.sh
# USAGE: ./~apt-update.sh
# DESCRIPTION: script permettant la mise a jour masquée des paquets du poste
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: Maxime Tertrais
# COMPANY: Operis
# CREATED: 18/10/2024
# REVISION: ---
#=======================================================================
##Définition des variables
log_file="/var/log/apt-logs.log"
#=======================================================================
##Définition des fonctions

#=======================================================================
##Script
main() (
  {
    echo "Mise à jour système: $(date)"
    apt update -y
    apt upgrade -y
    apt autoremove -y
    echo '---------------------------------------'
  } >> $log_file 2>&1
)

main "$@"