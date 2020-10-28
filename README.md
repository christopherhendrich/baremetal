# baremetal



1. Copy the files to the server, that will be used as admin workstation 

2. Log into the admin workstation

3. Fill out the variables.sh file 

4. Run the variables.sh file

5. Review the admin-workstation-prep.sh file to understand what the script will be doing.

6. Run the admin-workstation-prep.sh file

7. For each nodes used for control plane and cluster workers 

    a. SSH into the node
    b. Set up USER variable:    export USER=linux-user-used-for-ssh-access
    c. Execute the remote-node-prep.sh that the admin-workstation-prep.sh copied to the node
    d. Run the following steps to allow sudo access for user without password
       1. sudo su
       2. sudo echo '%wheel        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers
       3. exit
8. Back on the admin workstation, run deploy-cluster.sh. This will create the bmctl workspace, create the config file, populate it with the variables declared in variables.sh and deploy the "hybrid" cluster. If you want to use separate admin and worker clusters, further changes have to be made, which are not in scope of this effort. 
