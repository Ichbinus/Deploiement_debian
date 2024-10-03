#!/bin/bash
#=======================================================================
# FILE: ~laps.sh
# USAGE: ./~laps.sh
# DESCRIPTION: pseudo LAPS fonctionnant sous linux avec un AD windows
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

USER="operis" ##user local dont on doit changer le mot de passe
PASSWORD_LENGTH=16
PASSWORD_FILE="/var/lib/laps/${USER}_password.txt"
LOG_FILE="/var/log/laps.log"
BASE_DN="DC=OPERIS,DC=CHAMPLAN"
DC="VM2016DOMORV.operis.champlan"
LDAP_URI="ldap://$DC"
LDAP_USER="User_Laps4Linux@OPERIS.CHAMPLAN" # Notez les guillemets
AD_ATTRIBUTE=""

#=======================================================================
##Définition des fonctions


### test de connexion à l'AD
if ! ping -c 4 "$DC" > /dev/null 2>&1; then
   echo "$(date '+%Y-%m-%d %H:%M:%S') - contrôleur de domaine injoignable, mise à jour mot de passe non réalisée." >> "$LOG_FILE"
   exit 1
fi


### Génération et changement du mot de passe du compte Operis
## Générer un mot de passe aléatoire
PASSWORD=$(openssl rand -base64 $PASSWORD_LENGTH)

## Changer le mot de passe de l'utilisateur local
echo "$USER:$PASSWORD" | chpasswd
chage -M 30 operis # durée de vie du mot de passe

## Créer un dossier sécurisé pour stocker le mot de passe s'il n'existe pas
if [ ! -d "$(dirname "$PASSWORD_FILE")" ]; then
  mkdir -p "$(dirname "$PASSWORD_FILE")"
  chmod 700 "$(dirname "$PASSWORD_FILE")"
fi

## Stocker le mot de passe dans un fichier sécurisé
echo "$PASSWORD" > "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"

### Récupération de la date de dernière modification du mot de passe
## Fonction pour convertir une date en FILETIME (100-nanosecondes depuis 1601-01-01)
dt_to_filetime() {
  local dt="$1"
  local epoch=$(date --date="$dt" +%s) ## Convertion en timestamp Unix (secondes depuis 1970)
  local sec_since_1601=$((epoch + 11644473600)) ## Nombre de secondes depuis 1601
  echo $((sec_since_1601 * 10000000)) ## Convertion en FILETIME (100-nanosecondes depuis 1601)
}

## Obtenir la date de dernière modification du mot de passe
PASSWORD_LAST_MODIFIED=$(chage -l "$USER" | grep "Le mot de passe expire" | cut -d: -f2 | xargs)

## Convertir la date en anglais pour qu'elle soit correctement parsée par 'date'
PASSWORD_LAST_MODIFIED_EN=$(echo "$PASSWORD_LAST_MODIFIED" \
    | sed 's/janv./Jan/g' \
    | sed 's/févr./Feb/g' \
    | sed 's/mars/Mar/g' \
    | sed 's/avr./Apr/g' \
    | sed 's/mai/May/g' \
    | sed 's/juin/Jun/g' \
    | sed 's/juil./Jul/g' \
    | sed 's/août/Aug/g' \
    | sed 's/sept./Sep/g' \
    | sed 's/oct./Oct/g' \
    | sed 's/nov./Nov/g' \
    | sed 's/déc./Dec/g')

## Vérification de la date
if [[ -z "$PASSWORD_LAST_MODIFIED_EN" ]]; then
  echo "Erreur: Impossible d'obtenir la date de modification du mot de passe pour l'utilisateur $USER."
  exit 1
fi

## Convertir la date en FILETIME
EXPIRATION_TIME=$(dt_to_filetime "$PASSWORD_LAST_MODIFIED_EN")

###Connexion et modification de l'objet ordinateur de l'AD
## Obtenir un ticket Kerberos pour l'authentification
kinit "$LDAP_USER" -k -t /etc/laps/User_Laps4Linux.keytab

## Obtenir l'objet Ordinateur de la machine
FQHN=$(ldapsearch -H $LDAP_URI -Y GSSAPI -U $LDAP_USER -b $BASE_DN "(cn=$HOSTNAME)" dn | grep -oP '^dn: \KCN=.*')

## Mettre à jour l'attributs ms-Mcs-AdmPwd de l'objet ordinateur dans AD
AD_ATTRIBUTE="ms-Mcs-AdmPwd"

ldapmodify -H $LDAP_URI -Y GSSAPI <<EOF
dn: $FQHN
changetype: modify
replace: $AD_ATTRIBUTE
$AD_ATTRIBUTE: $PASSWORD
EOF

## Mettre à jour l'attributs ms-Mcs-AdmPwdExpirationTime de l'objet ordinateur dans AD
AD_ATTRIBUTE="ms-Mcs-AdmPwdExpirationTime"

ldapmodify -H $LDAP_URI -Y GSSAPI <<EOF
dn: $FQHN
changetype: modify
replace: $AD_ATTRIBUTE
$AD_ATTRIBUTE: $EXPIRATION_TIME
EOF

## Journaliser l'action

echo "$(date '+%Y-%m-%d %H:%M:%S') - Password for $USER changed and updated in AD for $HOSTNAME" >> "$LOG_FILE"
echo "Password for $USER has been updated locally and in AD."