#!/bin/sh

#definition des variables
    liste_imprimantes={IMP-0001,IMP-0002,IMP-0003,IMP-0005}
    driver="Ricoh-IM_C2000-PDF-Ricoh.ppd"
    
# Fonctions
Ajout_Imprimante () {
    if [$imprimante -eq "IMP-0001"];then
        description="Imprimante Richo site Orvault 1er etage"
        peripherique="socket://192.168.44.51"
        lpadmin -p $imprimante -E -v "peripherique" -m $driver -L $description
        lpadmin -d $imprimante

    elif [$imprimante -eq "IMP-0002"];then
        description="Imprimante Richo site Orvault 2eme etage"
        peripherique="socket://192.168.44.52"
        lpadmin -p $imprimante -E -v "peripherique" -m $driver -L $description

    elif [$imprimante -eq "IMP-0003"];then
        description="Imprimante Richo site Champlan"
        peripherique="socket://192.168.100.53"
        lpadmin -p $imprimante -E -v "peripherique" -m $driver -L $description

    elif [$imprimante -eq "IMP-0004"];then
        description="Imprimante Richo site Merignac"
        peripherique="socket://192.168.100.54"
        lpadmin -p $imprimante -E -v "peripherique" -m $driver -L $description

    elif [$imprimante -eq "IMP-0005"];then
        description="Imprimante Service RH"
        peripherique="lpd://192.168.100.55"
        lpadmin -p $imprimante -E -v "peripherique" -m $driver -L $description

    fi
	lpadmin -p "imprimante" -E -v "peripherique" -m $driver -L "description"
}


# debut du script
apt update
apt upgrade -y
apt instal cups -y
mv ./$driver /usr/share/cups/model/
Ajout_Imprimante

