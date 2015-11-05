#!/bin/bash
# Check for git and devtools

set -e

echo ''

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

git_setup () {
    # Check for git and devtools
    if [ `git --version` = "-bash: git: command not found" ] ; then
        info "Installing developer tools...\n"
        xcode-select --install
    fi
    success "Git installed"
}

homebrew_setup () {
    # Check if homebrew is installed
    if [ `brew --version` = "-bash: brew: command not found" ] ; then
        info "Installing homebrew tools...\n"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        info "Homebrew installed: updating\n"
        brew update
        success "Homebrew updated"
    fi
    success "Homebrew up and running"
}

homebrew_verification () {
    # Check for brew doctor messages
    if [ `brew doctor` = "Your system is ready to brew." ] ; then
        success "Homebrew is up and ready... "
    else
        fail "Homebrew seems to be sick run brew doctor and fix your problems, then come back."
        exit 2
    fi
}

python_install () {
    # Install python, python QT libraries and compiler
    info "Installing python and libraries... \n"
    brew install python wget
    brew install pyside sdcc
}

pip_install () {
    # Install python packages
    pip install gitpython hgapi beautifulsoup4 pyusb
    success "Python and libraries installed correctly"
}

directories_setup () {
    info "Setting up directories.\n"
    # Create pinguino directory in home folder
    [ ! -d ~/.pinguino ] && mkdir -pv ~/.pinguino
    [ ! -d /usr/local/share/pinguino-11 ] && mkdir -pv /usr/local/share/pinguino-11
    # Go to Pinguino folder
    cd ~/.pinguino
    PINGUINO_ROOT=$(pwd)

    # Get the basic pinguino IDE
    info "Downloading PinguinoIDE; this might take a while.\n"
    git clone https://github.com/PinguinoIDE/pinguino-ide.git $PINGUINO_ROOT

    # Get the libraries
    info "Downloading libraries.\n"
    wget --no-check-certificate https://github.com/PinguinoIDE/pinguino-libraries/archive/master.zip
    unzip master.zip -d $PINGUINO_ROOT
    rm "$PINGUINO_ROOT/master.zip"

    # Copy the libraries to pinguino main folder
    cp -a ~/.pinguino/pinguino-libraries-master/* ~/.pinguino

    # Set paths in pinguinoIDE to the project
    # TODO:
    # in paths.cfg change /usr/share/pinguino-11 to /usr/local/share/pinguino-11
    # there is another file, but it doesn't seem to be in the IDE repo
    # info 'Setting up paths.\n'
    # USR_PATH="/usr/local/share/pinguino-11"
    # sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHORUSERNAME/$git_authorusername/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" git/gitconfig.symlink.example > git/gitconfig.symlink

}

global_setup () {
    # Check if alias exits in ~/.bash_profile
    info "Setting up global alias (bash)"
    if grep -q "alias pinguino" ~/.bash_profile|wc -l
    then
        success "Global settup succesfull, you can run pinguino-IDE with command 'pinguino'."
    else
        echo "alias pinguino='python ~/.pinguino/pinguino.py'" >> ~/.bash_profile
        source ~/.bash_profile
        success "Global settup succesfull, you can run pinguino-IDE with command 'pinguino'."
    fi
}

git_setup
homebrew_setup
homebrew_verification
python_install
pip_install
directories_setup
global_setup
