#!/bin/bash

# copy this file to (or paste the contents into) a
# text file called modify-for-aws.sh on the VM
# run this script as: 
#    sudo bash modify-for-aws.sh
# it will take a minute or two to complete

export DEBIAN_PRIORITY=high
export DEBIAN_FRONTEND=noninteractive

# setup oski user with admin privileges and for passwordless SSH
adduser oski sudo
if [ ! -e /home/oski/.ssh ]; then 
    cp -pr /home/ubuntu/.ssh /home/oski
    chown -R oski:oski /home/oski/.ssh
fi

# add a few useful software packages
git config --global user.email "bce@lists.berkeley.edu"
git config --global user.name "BCE Release Team"
apt-get update
apt-get install -y mosh git-annex 
