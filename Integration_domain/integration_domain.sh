#!/bin/bash
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

#=======================================================================
###Script

##installation des paquets requis
apt-get update
apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit policykit-1 ntpdate ntp krb5-user libsss-sudo libsasl2-modules-ldap libpam-mount samba samba-common

##nommage du poste
read -p "comment voulez-vous nommer ce poste?" nom_poste
echo $nom_poste > /etc/hostname
echo "/etc/hostname mis à jour avec NBK-500"

##configuration kerberos

##Synchronisation du temps de la machine avec le serveur

##paramétrage création dossier perso user

##paramétrage samba

##paramétrage sssd

##jonction au domain

##paramétrage des autorisations d'accès

##gestion des droits sudos

##désactivation du compte root
