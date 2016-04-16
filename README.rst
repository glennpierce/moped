************
Mopidy-Moped Fork to Add Allplay Support
************

Moped with allplay settings.

.. image:: https://github.com/glennpierce/moped/raw/master/allplay_moped_settings.png?raw=true

Installation
============

First you need to install AllJoyn library.  For the Debian Apt based distros (eg Raspbian on the RaspberyPI) install dependant packages using Debian package manager ::

    apt-get install build-essential maven scons git curl openssl libssl-dev libjson0 libjson0-dev libcap-dev
	
Setup compile environment download AllJoyn code and compile it  (this may take quite some time on an embedded processor like the RaspberryPi)::
	
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
    scons OS=linux CPU=arm WS=off OE_BASE=/usr BR=on BINDINGS=c,cpp CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-
    sudo ln -sf ~/WORKING_DIRECTORY/alljoyn/core/alljoyn/build/linux/arm/debug/dist/cpp/lib/liballjoyn.so /lib/arm-linux-gnueabihf/liballjoyn.so
    cd ~/WORKING_DIRECTORY/alljoyn/core/alljoyn/build/linux/arm/debug/dist/cpp/bin
    ldd alljoyn-daemon #daemon not available in latest versions of alljoyn, use BR=on with scons for embedded daemon
	
Now test the AllJoyn Daemon::

    cd ~/WORKING_DIRECTORY/alljoyn/core/alljoyn/build/linux/arm/debug/dist/cpp/bin
    alljoyn-daemon --version

AllJoyn Message Bus Daemon version: v0.00.01
Copyright AllSeen Alliance.

Build: AllJoyn Library v0.00.01 (Built Fri Apr 15 18:12:18 UTC 2016 by root - Git: alljoyn branch: '(no branch)' tag: 'v15.09a' (+350 changes) commit ref: e289adde2cd7289afbbc09a64a4620d5679d2bdc)

If you can see the AllJoyn-daemon version info, then it means AllJoyn libraries have compiled.  You can proceed to copying them to somewhere suitable on your system::

    cd ~/WORKING_DIRECTORY/alljoyn/core/alljoyn/build/linux/arm/debug/dist/
	killall alljoyn-daemon
	cp cpp/bin/* /usr/bin/
	cp cpp/lib/* /usr/lib/
	cp c/lib/* /usr/lib/
		
Now you have to download and install my AllJoyn bindings ::

    cd ~/WORKING_DIRECTORY
    git clone https://github.com/glennpierce/alljoyn_python
    cd alljoyn_python/
    python ./setup.py install

Now test the AllJoyn Python Bindings ::
    
	killall alljoyn-daemon
    alljoyn-daemon &  ./samples/AllPlay/AllPlayAboutClient.py

This should return information for the Allplay speakers we can see on the network.

______

**Notes:**

Before running any of the Python AllJoyn code the alljoyn-daemon must be running as the internal AllJoyn router is not exported in the c api so I could not wrap it.

Within the samples is a beets plugin ./samples/beetsplug/
http://beets.io/ is a Python music indexer / metadata system. 
My plugin sets up an angular web page to play music through the allplay system.
It may be easier to run than mopidy and moped as Modpidy is not needed and nither is icecast.
I found Mopidy and icecast to have some issues together so wrote this.
Currently it needs a little design work and a few features but you can list songs add them to a queue for playing. Should be easier to add features to this.

To run this plugin, Add the plugin directory to the Python path ie::

    export PYTHONPATH="/opt/alljoyn_python/samples/"

Edit the beets config file::

    nano ~/.config/beets/config.yaml

Add the following::

        directory: ~/Music
        library: ~/musiclibrary.blb

        plugins: allplay

        allplay:
            host: 0.0.0.0


Once the config is save you have to index your music.  For importing read https://beets.readthedocs.org/en/v1.3.17/guides/main.html

I used::

    beet import -A /media/External/Music

Once index simply run my plugin::
	
    beet allplay --debug

This will start a webserver you can access on port 8337


You have to have alljoyn-daemon running
Before running any of the Python AllJoyn code the alljoyn-daemon must be running::

     alljoyn-daemon &

Finally install Mopidy and this extension
  
For detailed instructions goto https://mopidy.readthedocs.org/en/latest/installation/
Quick setup I used::

    git clone https://github.com/mopidy/mopidy
    python ./setup.py install
    mopidy local scan

Edit the Mopidy config ::

    ~/.config/mopidy/mopidy.conf

The audio section should be like ::

    [audio]
    output = lamemp3enc ! shout2send mount=mopidy ip=192.168.1.5 port=8000 password=******

    This send Mopidy output to an icecast server running of the specifed ip with the password you set up

    See https://mopidy.readthedocs.org/en/latest/audio/?highlight=icecast

 
Icecast install

Due to bug in Mopidy with icecast I added a silence file for icecast.
See Known issues at https://mopidy.readthedocs.org/en/latest/audio/?highlight=icecast
My config for icecast added these two sections::

    <authentication>
        <!-- Sources log in with username 'source' -->
        <source-password>*******</source-password>
        <!-- Relays log in username 'relay' -->
        <relay-password>*******</relay-password>

        <!-- Admin logs in with the username given below -->
        <admin-user>glenn</admin-user>
        <admin-password>*******</admin-password>
    </authentication>

    <mount>
     <mount-name>/mopidy</mount-name>
     <fallback-mount>/silence.mp3</fallback-mount>
     <fallback-override>1</fallback-override>
    </mount>


