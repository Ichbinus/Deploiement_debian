func_installations_packages()
{
#=======================================================================
# FILE: ~installations_packages.sh
# USAGE: ./~installations_packages.sh
# DESCRIPTION: Installation des packages nécessaires à l'administration 
# et l'utilisations des postes pour les devs
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
folder=$(pwd) ##dossier local
log_erreurs="$folder/err_log.log"

#=======================================================================
##Définition des fonctions
func_outils_admin_poste(){
	apt-get update
    apt install -y net-tools curl wget htop micro tree gpg gnupg2 
}

func_outils_devs(){
	apt-get update
    apt install -y git git-extras gitk meld jq yq fd-find ripgrep parcellite pandoc cloc fzf shellcheck dconf-cli gnome-tweaks gnome-shell-extensions gnome-shell-extension-manager inotify-tools shutter sshfs terminator uuid wl-clipboard flatpak apache2 nginx make build-essential libssl-dev zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev llvm libncurses5-dev php keepass2 pass
}

func_Chrome(){
	curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | tee /etc/apt/sources.list.d/google-chrome.list
    apt update
    apt install -y google-chrome-stable
}

func_vscode(){
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    apt install apt-transport-https
    apt update
    apt install -y code
}

func_dbeaver(){
	echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
    apt install software-properties-common apt-transport-https ca-certificates
    curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg
    apt update
    apt install -y dbeaver-ce
}

func_docker(){
	install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list 
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    groupadd docker
    usermod -aG docker $USER
}

func_powershell(){
	install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list 
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    groupadd docker
    usermod -aG docker $USER
}

func_virtualbox(){
	wget -O- -q https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmour -o /usr/share/keyrings/oracle_vbox_2016.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle_vbox_2016.gpg] http://download.virtualbox.org/virtualbox/debian bookworm contrib" | tee /etc/apt/sources.list.d/virtualbox.list
    apt update
    apt install -y virtualbox-7.0
    /sbin/usermod -aG vboxusers $USER
}
#=======================================================================
##Script

echo "Mise a jour des outils d'administration du poste"
	if func_outils_admin_poste 2>> $log_erreurs; then
		echo "Mise a jour des outils d'administration du poste réussie"
	else
		echo "Erreur lors de la mise a jour des outils d'administration du poste"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Mise a jour des outils de developpement"
	if func_outils_devs 2>> $log_erreurs; then
		echo "Mise a jour des outils de developpement réussie"
	else
		echo "Erreur lors de la mise a jour des outils de developpement"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Installation de VS Code"
	if func_vscode 2>> $log_erreurs; then
		echo "Installation de VS Code réussie"
	else
		echo "Erreur lors de l'installation de VS Code"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Installation de DBeaver"
	if func_dbeaver 2>> $log_erreurs; then
		echo "Installation de DBeaver réussie"
	else
		echo "Erreur lors de l'installation de DBeaver"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Installation de Docker"
	if func_docker 2>> $log_erreurs; then
		echo "Installation de Docker réussie"
	else
		echo "Erreur lors de l'installation de Docker"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Installation du Container Powershell"
	if func_powershell 2>> $log_erreurs; then
		echo "Installation de Container Powershell réussie"
	else
		echo "Erreur lors de l'installation de Container Powershell"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Installation de VirtualBox"
	if func_powershell 2>> $log_erreurs; then
		echo "Installation de VirtualBox réussie"
	else
		echo "Erreur lors de l'installation de VirtualBox"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2

echo "Installation de Google Chrome"
	if func_Chrome 2>> $log_erreurs; then
		echo "Installation de Google Chrome réussie"
	else
		echo "Erreur lors de l'installation de Google Chrome"
		echo "logs d'erreurs disponibles dans le fichier: $log_erreurs"
        exit 1
	fi
    sleep 2
}