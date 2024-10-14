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
DISTS=" bookworm " # adapter  ala liste des depots que vous possédez
REPO_ROOT="/var/www/depots_deb"
MIRROR_ROOT="$REPO_ROOT/mirror/dists"
GPG_HOME="/root/.gnupg"
FILELISTS_DIR="$REPO_ROOT/filelists"
ARCH_LIST="i386 amd64 all"

#=======================================================================
##Définition des fonctions

#=======================================================================
##Script
# vérification si le nombre d'arguments passés est suffisant
if [ $# -lt 1 ] ; then
    echo "" >&2
    echo "Usage: $0 [ all|etch|unstable|... ] [ test ]" >&2
    echo "" >&2
    echo "Mise à jour du ou des dépots (all)  spécifié en premier argument." >&2
    echo "Un seul dépot peut-être spécifié à la fois." >&2
    echo "" >&2
    echo "Si le deuxième argument est 'test', " >&2
    echo "la mise à jour se fait sur les dépots de test" >&2
    echo "" >&2
    exit 1
fi
				
# Traitement du premier argument - depot à mettre à jour
if [ -n "$1" ]; then
    ONLY_DIST=""
    tmp_sec=$1
    shift
		
    for i in ${DISTS}
    do
        if [ "X$i" = "X$tmp_sec" ]; then
            ONLY_DIST=$i
            break
        fi
    done
		
    if [ "X$tmp_sec" = "Xall" ]; then
        ONLY_DIST=${DISTS}
    fi
			
    if [ -z "${ONLY_DIST}" ]; then
        echo "ERREUR: depot invalide $tmp_sec" >&2
        exit 1
    fi
			
    DISTS=${ONLY_DIST}
fi
# Traitement du deuxième argument - depots de prod ou de test
DIST_SUFFIX=""
if [ "X$1" == "Xtest" ]; then
    DIST_SUFFIX="-test"
    shift
fi

# Boucle principale pour chaque distribution			
for DIST in $DISTS
do
    DIST="${DIST}${DIST_SUFFIX}"
    FTP_ARCHIVE_CONF_FILE="/etc/apt/apt-perso-${DIST}.conf"
		
    rm -f $REPO_ROOT/cache/*db
		
    # generation des filelist des depots
    cd $REPO_ROOT/mirror
    for section in `ls pool-${DIST}`
    do
        for archi in $ARCH_LIST;
        do
                if [ "x${archi}" = "xall" ]; then
                    continue
                fi
                mkdir -p ${FILELISTS_DIR}/dists/${DIST}
                echo "Section : ${section}"
                echo "Arch : ${archi}"
                FILELIST="${FILELISTS_DIR}/dists/${DIST}/${section}-${archi}.filelist"
                echo "filelist : $FILELIST"
                find pool-${DIST}/$section/binary-${archi} pool-${DIST}/$section/binary-all -name "*.deb" > \
                    ${FILELISTS_DIR}/dists/${DIST}/${section}-${archi}.filelist
        done
		
    done
    echo "generation apt ftp archive :"
        apt-ftparchive generate ${FTP_ARCHIVE_CONF_FILE}
    echo "creation du fichier Release :"
        # creation des fichiers Release
        RELEASE_FILE="${MIRROR_ROOT}/${DIST}/Release"
        apt-ftparchive -c $FTP_ARCHIVE_CONF_FILE release \
            ${MIRROR_ROOT}/${DIST}/ > $RELEASE_FILE
		
        # signature gpg des fichiers Release
    rm -f $RELEASE_FILE.gpg
    ${DEBUG} gpg --verbose --homedir ${GPG_HOME} -ba \
        --output $RELEASE_FILE.gpg $RELEASE_FILE
done