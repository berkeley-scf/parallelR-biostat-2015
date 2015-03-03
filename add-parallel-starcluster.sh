#!/bin/bash

# installing software on the worker nodes

# copy this file to (or paste the contents into) a
# text file called add-parallel-starcluster.sh on the VM
# run this script as: 
#    sudo bash add-parallel-starcluster.sh
# it will take a minute or two to complete

nodes=`grep -Eo node[[:digit:]]{3} /etc/hosts`
for node in $nodes; do
    ssh $node adduser oski sudo
    scp add-parallel-tools.sh $node:/tmp/.
    ssh $node bash /tmp/add-parallel-tools.sh >& /home/oski/add-parallel-$node.log
done

sudo -u oski echo -e "master\n$nodes" > .hosts
