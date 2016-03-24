************
Mopidy-Moped Fork to Add Allplay Support
************

Moped with allplay settings.

.. image:: https://github.com/glennpierce/moped/raw/master/allplay_moped_settings.png?raw=true

Installation
============

First you need to install AllJoyn library

For the raspberry pi do

sudo apt-get install build-essential
sudo apt-get install maven
sudo apt-get install scons
sudo apt-get install git
sudo apt-get install curl
sudo apt-get install openssl
sudo apt-get install libssl-dev
sudo apt-get install libjson0
sudo apt-get install libjson0-dev
sudo apt-get install libcap-dev

scons OS=linux CPU=arm WS=off OE_BASE=/usr BR=on BINDINGS=c CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-


Then you have to install my AllJoyn bindings

You have to have alljoyn-daemon running

https://github.com/glennpierce/alljoyn_python

Finally install Mopidy and this extension


