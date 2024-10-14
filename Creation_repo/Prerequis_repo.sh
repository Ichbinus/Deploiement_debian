#!/bin/bash
#=======================================================================
# FILE: ~maj_repo.sh
# USAGE: ./maj_repo.sh ""
# DESCRIPTION: met a jour le depot debian cible passé en argument
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# sources: http://wiki.drouet.eu/sysadmin/debian_repository
# NOTES: ---
# AUTHOR: Maxime Tertrais
# COMPANY: Operis
# CREATED: 09/10/2024
# REVISION: ---
#=======================================================================
##Définition des variables

#=======================================================================
##Définition des fonctions

#=======================================================================
##Script

# Installation GPG
apt-get install gnupg
gpg --gen-key
