#!/usr/bin/expect
#=======================================================================
# FILE: ~configuration_vpn.sh
# USAGE: ./~configuration_vpn.sh
# DESCRIPTION: Installation et paramétrage du vpn-ssl forticlient sur
# les postes Utilisateurs Debian 
#
# OPTIONS: ---
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: Maxime Tertrais
# COMPANY: Operis
# CREATED: 15/10/2024
# REVISION: ---
#=======================================================================
##Définition des variables
NOM_CONNEXION="VPN-Operis"
SERVER_VPN="champlan.operis.fr" #serveur à joindre
PORT_VPN="10443" #port du vpn à joindre
AUTH_TYPE="1" #demande de saisir les Id de l'AD
CERT_PATH="/opt/forticlient/client.pfx"
CERT_PSWD="Operis123"
#=======================================================================
##Définition des fonctions

#=======================================================================
##Script

set timeout -1

# Lancer le script fortivpn
spawn fortivpn edit $NOM_CONNEXION

# Fournir l'adresse du serveur
expect "Remote Gateway"  # Le texte exact affiché par le script
sleep 1
send "$SERVER_VPN\r"

# Fournir le n° de port
expect "Port"
sleep 1
send "$PORT_VPN\r"

# Fournir la méthode d'identification
expect "Authentication"
sleep 1
send "$AUTH_TYPE\r"

# Fournir le certificat client
expect "Client Certificate"
sleep 1
send "$CERT_PATH\r"

# Fournir le certificat client
expect "Client Certificate password"
sleep 1
send "$CERT_PSWD\r"

# Attendre la fin
expect eof

}