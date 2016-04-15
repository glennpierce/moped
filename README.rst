************
Mopidy-Moped Fork to Add Allplay Support
************

Moped with allplay settings.

.. image:: https://github.com/glennpierce/moped/raw/master/allplay_moped_settings.png?raw=true

Installation
============

First you need to install AllJoyn library.  For the Debian Apt based distros (eg Raspbian on the RaspberyPI) istall dependant packages ::

    apt-get install build-essential maven scons git curl openssl libssl-dev libjson0 libjson0-dev libcap-dev
	
Setup compile environment download AllJoyn code and compile it::
	
    mkdir ~/bin
    echo "export PATH=$PATH:~/bin" >> ~/.bashrc
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    source ~/.bashrc
    mkdir -p ~/WORKING_DIRECTORY/alljoyn
    cd ~/WORKING_DIRECTORY/alljoyn
    git config --global user.name "Mark Gillespie"
    git config --global user.email "mark.gillespie@gmail.com"
    repo init -u https://git.allseenalliance.org/gerrit/devtools/manifest
    repo sync
    export AJ_ROOT=$(pwd)
    sudo ln -s /usr/bin/g++ /usr/bin/arm-angstrom-linux-gnueabi-g++
    sudo ln -s /usr/bin/gcc /usr/bin/arm-angstrom-linux-gnueabi-gcc
    cd ~/WORKING_DIRECTORY/alljoyn/core/alljoyn
    scons OS=linux CPU=arm WS=off OE_BASE=/usr BR=on BINDINGS=cpp CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-
    sudo ln -sf ~/WORKING_DIRECTORY/alljoyn/core/alljoyn/build/linux/arm/debug/dist/cpp/lib/liballjoyn.so /lib/arm-linux-gnueabihf/liballjoyn.so
    cd ~/WORKING_DIRECTORY/alljoyn/core/alljoyn/build/linux/arm/debug/dist/cpp/bin
    ldd alljoyn-daemon #daemon not available in latest versions of alljoyn, use BR=on with scons for embedded daemon
	
Now test the AllJoyn Daemon::

    cd ~/WORKING_DIRECTORY/alljoyn/core/alljoyn/build/linux/arm/debug/dist/cpp/bin
    alljoyn-daemon --version


Now you have to install my AllJoyn bindings ::

https://github.com/glennpierce/alljoyn_python

You have to have alljoyn-daemon running

Finally install Mopidy and this extension


