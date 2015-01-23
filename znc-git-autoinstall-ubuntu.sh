#!/bin/bash

######## Automate Git Master Build Script - ZNC on Ubuntu 14.04 ########

SCRIPT_VERSION="0.2"

SCRIPT_DESIGNED_FOR_ZNC_VERSION="1.5-git (pre-1.6)"


##### VARIABLES #####
## Location of where the `znc` folder will be made on git clone
GIT_FOLDER_PARENT_LOCATION="/home/$USER/"
GIT_FOLDER_ACTUAL_LOCATION="$GIT_FOLDER_PARENT_LOCATION/znc"

## Feature enablement flags.
ENABLE_TCL=true     # True enables modtcl and the Tcl Plugin API for ZNC
ENABLE_CYRUS=true   # True enables cyrusauth module.
ENABLE_PERL=true    # True enables modperl and the Perl Plugin APi for ZNC
ENABLE_PYTHON=true  # True enables modpython and the Python Plugin API for ZNC

## Additional ./configure arguments
PREFIX_DIR="/usr"
LIB_DIR="/usr/lib"


## Ubuntu Version Determining and Checks
# (1) Make sure we're on Ubuntu
LINUX_DISTRIBUTOR_ID=$(lsb_release --short --id)

if (( "$LINUX_DISTRIBUTOR_ID" != "Ubuntu" )); then
    echo "This script is for Ubuntu only! Do not use it with other distros!"
    echo
    echo "Script exited with error, code: 1"
    exit -1
fi

# (2) If we are, then if version of Ubuntu OLDER than 12.04, then that is
#     too old to be used.
UBUNTU_VERSION=$(lsb_release --short --release)

if [[ "$UBUNTU_VERSION" < "12.04" ]]; then
    echo "Your Ubuntu version is too old to work with the git master of ZNC."
    echo "Please use this script with Ubuntu 12.04 or newer."
    echo
    echo "Script exited with error, code: 2"
    exit 1
fi


# (3) PPA arch limitations.
ARCHITECTURE=$(uname -m)

if [[ "$ARCHITECTURE" != "x86_64" ]]; then
    if [[ "$ARCHITECTURE" != "x86" ]];; then
        echo "The PPA dependencies here are x86 or x64 environments.  Alternate"
        echo "architectures (such as ARM or PowerPC) are not supported in this "
        echo "script at this time."
        echo
        echo "Script exited with error, code: 3"
        
        exit 3;
    fi
fi

##### Create full configure string #####
CONFIGURE_STRING="--prefix=$PREFIX_DIR --libdir=$LIB_DIR"

if $ENABLE_TCL; then
    CONFIGURE_STRING="$CONFIGURE_STRING --enable-tcl"
fi

if $ENABLE_CYRUS; then
    CONFIGURE_STRING="$CONFIGURE_STRING --enable-cyrus"
fi

if $ENABLE_PERL; then
    CONFIGURE_STRING="$CONFIGURE_STRING --enable-perl"
fi

if $ENABLE_PYTHON; then
    CONFIGURE_STRING="$CONFIGURE_STRING --enable-python"
fi



##### Apt Packages List Generation #####
APT_PACKAGES_LIST="gcc-4.7 g++-4.7 build-essential libssl-dev pkg-config libicu-dev hardening-wrapper automake"

## Determine if swig3.0 is needed
if $ENABLE_PERL || $ENABLE_PYTHON; then
    APT_PACKAGES_LIST="$APT_PACKAGES_LIST swig3.0"
fi

## Determine if perl development libraries are needed
if $ENABLE_PERL; then
    APT_PACKAGES_LIST="$APT_PACKAGES_LIST libperl-dev"
fi

## Determine if python development libraries are needed.
if $ENABLE_PYTHON; then
    APT_PACKAGES_LIST="$APT_PACKAGES_LIST python3-dev python-support"
fi

## Determine if Tcl libraries are needed.
if $ENABLE_TCL; then
    APT_PACKAGES_LIST="$APT_PACKAGES_LIST tcl8.5-dev"
fi

## Determine if SASL libraries are needed.
if $ENABLE_CYRUS; then
    APT_PACKAGES_LIST="$APT_PACKAGES_LIST libsasl2-dev"
fi


##### Install `add-apt-repository` #####
sudo apt-get install -y software-properties-common python-software-properties

##### Determine if extra PPAs are needed. #####

#### gcc-4.7 ####
## If the Ubuntu release is not 14.04 or newer, then we need yet another PPA
## which will provide a version of the gcc (GNU C) compiler that supports
## C++11.  As of 2015-01-20, this is gcc-4.7.  This is not available in 
## pre-14.04 Ubuntu and therefore a separate PPA is needed.

## If the Ubuntu version number is smaller than 14.04, then you need this
## other PPA in order to get gcc-4.7 from it.  Trusty (14.04) and newer
## already have gcc-4.7 in the repositories.
if [[ "$UBUNTU_VERSION" < "14.04" ]]; then
    echo "Adding PPA for gcc-4.7..."
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
fi


#### libicu-dev ####
## If the Ubuntu release is not 14.04 or newer, then we need the PPA for
## the `icu` source package, for a working libicu-dev.
if [[ "$UBUNTU_VERSION" < "14.04" ]]; then
    echo "Adding PPA for libicu-dev..."
    sudo add-apt-repository -y ppa:teward/icu-backports
fi


#### swig 3.0 ####
## swig3.0 is needed for the Perl and Python modules.  If these are set to be
## built in the boolean flags above, then we need to add a PPA for it.
if $ENABLE_PERL || $ENABLE_PYTHON; then
    echo "Adding swig3.0 PPA..."
    sudo add-apt-repository -y ppa:teward/swig3.0
fi

echo "Updating apt data..."
sudo apt-get update

#### INSTALL PACKAGES (Dependencies)
echo "Installing build dependencies via \`apt-get\`..."
sudo apt-get install -y $APT_PACKAGES_LIST

echo
echo

#### MANUAL STEPS ####
echo "Now for user actions BEFORE this can work! We have to specify that \`gcc\`"
echo "is actually at a different location and version. So, we have to run the "
echo "following commands MANUALLY in **another terminal window** before we can"
echo "continue on and build the software."
echo 
echo "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 40 \ "
echo "  --slave /usr/bin/g++ g++ /usr/bin/g++-4.7"
echo "sudo update-alternatives --config gcc"
echo 
echo "At this window, the system will prompt you to select which compiler to "
echo "use. Choose the number for the \`g++-4.7\` line, and hit 'ENTER'."
echo
echo "REMEMBER THE PREVIOUS ENTRY THOUGH! We need to set it back when done!"
echo
echo "Press the Enter key here in this terminal to continue after you've done "
echo "those steps."
echo

read

##### Check if parent dir exists.  Make if not.
if [[ -d $GIT_FOLDER_PARENT_LOCATION ]]; then
    mkdir -p $GIT_FOLDER_PARENT_LOCATION
fi

##### Get source code #####
cd $GIT_FOLDER_PARENT_LOCATION
git clone https://github.com/znc/znc.git

## Init the submodules (CSocket) #####
cd $GIT_FOLDER_ACTUAL_LOCATION
git submodule update --init --recursive


echo 

##### Since this is from git, we need to run automake.sh.
./autogen.sh

echo
echo 

##### Configure time!
## Assumed Configure String:
## If all module flags above are enabled...
# ./configure --prefix=$PREFIX_DIR --libdir=$LIB_DIR --enable-tcl --enable-cyrus --enable-python --enable-perl

echo "Running ./configure $CONFIGURE_STRING ..."
./configure $CONFIGURE_STRING

echo
echo

##### Time to compile!
echo "Building!"
make

echo
echo

## Time to install after compile.  Overwrites ZNC on the disk already.
echo "Installing to System Directories!"
sudo make install

echo

##### Reset manual steps back. #####
echo "Now for user actions for cleanup!  We have to reset things so that \`gcc\`"
echo "is actually at a different location and version. So, we have to run the "
echo "following commands MANUALLY in **another terminal window** before we can"
echo "continue on and build the software."
echo 
echo "sudo update-alternatives --config g++"
echo 
echo "At this window, the system will prompt you to select which compiler to "
echo "use. We said to take note of what it was set to before. Set it to what it"
echo "was before."
echo
echo "Press the Enter key here in this terminal to continue after you've done "
echo "those steps."
echo

read

echo
echo
echo "DONE!  There may have been errors, so make sure to check!"

exit 0;
