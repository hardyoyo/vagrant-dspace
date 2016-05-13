#!/bin/sh
# angularui-bootstrap.sh
# installs Node.js, npm; checks out and installs the AngularUI code from GitHub

# install Node.js and npm

# if we have a local copy of the Node.js tarball, use it
if [ -f "/vagrant/config/node-v4.4.4-linux-x64.tar.xz"]; then
    cd /home/vagrant && cp /vagrant/config/node-v4.4.4-linux-x64.tar.xz /home/vagrant
else
    cd /home/vagrant && wget https://nodejs.org/dist/v4.4.4/node-v4.4.4-linux-x64.tar.xz && tar -xpvf node-v4.4.4-linux-x64.tar.xz
fi

sudo mv /home/vagrant/node-v4.4.4-linux-x64 /usr/local
sudo ln -s /usr/local/node-v4.4.4-lunux-x64 /usr/local/node

# clone and install AngularUI
##### NOTE: if you are customizing this script, you will want to change
##### change this git repository to YOUR fork of the prototype
##### i.e. replace "DSpace-Labs" with your own GitHub user name
cd /home/vagrant && git clone git@github.com:DSpace-Labs/angular2-ui-prototype.git
##### setting the upstream remote for the default doesn't make much sense
##### but it'll be handy when you change the checkout above to
##### check out YOUR fork of the prototype
cd /home/vagrant/angular2-ui-prototype && git remote add upstream git@github.com:DSpace-Labs/angular2-ui-prototype.git
git fetch --all
/usr/local/node/bin/npm install
sudo /usr/local/node/bin/npm run global
/usr/local/node/bin/npm build
