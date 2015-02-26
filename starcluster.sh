#!/bin/bash

# template for starting up a BCE-based EC2 cluster

# you'll need a starcluster config file (see starcluster.config as example)

# save the config file as ~/.starcluster/config

## @knitr starcluster-start

starcluster start -c bce mycluster

starcluster put mycluster modify-for-aws.sh .
starcluster sshmaster mycluster bash modify-for-aws.sh

starcluster put -u oski mycluster add-parallel-tools.sh .
starcluster put -u oski mycluster add-parallel-starcluster.sh .

starcluster sshmaster -u oski mycluster sudo bash add-parallel-tools.sh 
starcluster sshmaster -u oski mycluster sudo bash add-parallel-starcluster.sh 

