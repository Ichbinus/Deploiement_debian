#!/bin/bash
#=======================================================================
# FILE: ~Creation_arbo_repo.sh
# USAGE: ./Creation_arbo_repo.sh ""
# DESCRIPTION: Création de l'arborescence de dossier nécessaire à la 
# création et l'utilisation d'un dépôt interne pour les postes/serveurs
# tournant sous Debian.
# Si le premier argument est fourni, il est assigné à la variable DIST, 
# qui représente le dépôt (par exemple, « buster », « bullseye »).
# Si le second argument est fourni, il est assigné à la variable SECTION, 
# qui représente la section (par exemple, « main », « contrib »).
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
ARCHS="i386 amd64" #Spécifie les architectures prises en charge (32 bits i386 et 64 bits amd64)
REPO_ROOT="/var/www/depots_deb" #Racine du dépôt interne.
MIRROR_ROOT="$REPO_ROOT/mirror/dists" #Racine du miroir des distributions dans le dépô
FILELISTS_DIR="$REPO_ROOT/filelists" #Répertoire pour les listes de fichiers.

#=======================================================================
##Définition des fonctions

#=======================================================================
##Script
			
if [ $# -lt 1 ] ; then
    echo "" >&2
    echo "Usage: $0  depot section" >&2
    echo "" >&2
    echo "Cree l'arborescence nécessaire pour créer un depot avec la section souhaitée" >&2
    echo "Genere le fichier de configuration associé pour apt-ftparchive" >&2
    echo "" >&2
    exit 1
fi
	
# le premier argument specifie le depot
if [ -n "$1" ]; then
    DIST=$1
    shift
fi
	
# le deuxieme argument specifie la section
if [ -n "$1" ]; then
    SECTION=$1
    shift
fi
		
FTP_ARCHIVE_CONF_FILE="/etc/apt/apt-perso-${DIST}.conf"
		
#creation de l'arborescence
DIR=""
    for archi in $ARCHS; do
    DIR="$DIR ${FILELISTS_DIR}/dists/${DIST} $REPO_ROOT/mirror/pool-${DIST}/$SECTION/binary-${archi} $MIRROR_ROOT/$DIST/$SECTION/binary-${archi}"
    done
		
DIR="$DIR $REPO_ROOT/mirror/pool-${DIST}/$SECTION/binary-all $MIRROR_ROOT/$DIST/$SECTION/binary-all"
		
mkdir -p $DIR
chown root:sudo $DIR
chmod u=rwx,g=rwxs,o=rx,g+s $DIR
chmod g+ws $DIR
	
# generation du fichier de configuration du depot
if [ -f $FTP_ARCHIVE_CONF_FILE ]; then
    echo "Le fichier de conf $FTP_ARCHIVE_CONF_FILE existe deja : Abandon" >&2
    echo "Veuillez le compléter a la main (si vous voulez créer une nouvelle section dans un depot existant)" >&2
    echo "ou le supprimer avant de relancer ce script" >&2
    exit 1
fi
	
echo "APT::FTPArchive::Release::Origin \"Internal Repository\";" > $FTP_ARCHIVE_CONF_FILE
echo "APT::FTPArchive::Release::Label \"Internal tools\";" >> $FTP_ARCHIVE_CONF_FILE
echo "APT::FTPArchive::Release::Suite \"$DIST\";" >> $FTP_ARCHIVE_CONF_FILE
echo "APT::FTPArchive::Release::Codename \"$DIST\";" >> $FTP_ARCHIVE_CONF_FILE
echo "APT::FTPArchive::Release::Architecture \"$ARCHS\";" >> $FTP_ARCHIVE_CONF_FILE
echo "APT::FTPArchive::Release::components \"$SECTION\";" >> $FTP_ARCHIVE_CONF_FILE
echo "APT::FTPArchive::Release::Description \"Internal Repository\";" >> $FTP_ARCHIVE_CONF_FILE
echo "" >> $FTP_ARCHIVE_CONF_FILE
echo "Tree \"dists/$DIST\" {" >> $FTP_ARCHIVE_CONF_FILE
echo "        Sections \"$SECTION\";" >> $FTP_ARCHIVE_CONF_FILE
echo "        Architectures \"$ARCHS\";" >> $FTP_ARCHIVE_CONF_FILE
echo "        Directory \"pool-$DIST/\$(SECTION)/binary-\$(ARCH)\";" >> $FTP_ARCHIVE_CONF_FILE
echo "        SrcDirectory \"pool-$DIST/\$(SECTION)/source\";" >> $FTP_ARCHIVE_CONF_FILE
echo "}" >> $FTP_ARCHIVE_CONF_FILE

