
# Your ProjectID
export PROJECT_ID=

#IP for the Admin Workstation 
export ADMIN_WORKSTATION_IP=

#Name of admin workstation linux user 
export ADMIN_WORKSTATION_USER=

#IP of Cluster node 1 - in HYBRID mode this will be the Master
export WORKER_NODE_1_IP=1

#IP of Cluster node 2 - in Hybrid, this will be the first workder node
export WORKER_NODE_2_IP=1
#Name of linux user for node 1
export WORKER_1_USERNAME=
#Name of linux user for node 2 - if you ahve two worker nodes
export WORKER_2_USERNAME=
#Whitelisted Google Service Account used to pull baremetal images from Google bucket
export ACCESS_GSA_NAME=
#Email address of your Google Identity
export USER_EMAIL_ADDRESS=

# Name of Cluster
export CLUSTER_NAME=

# IP of your master node 
export CONTROL_PLANE_IP=
#Pod CIDR range. Needs to be /16 and not overlap with any other CIDR
export POD_CIDR="10.100.0.0/16"

# Service CIDR range. Cannot not overlap with any other CIDR
export SERVICE_CIDR="10.99.0.0/24"

#VIP for K8s API Server
export CONTROL_PLANE_VIP=

#VIP for Istio Inngress Gateway
export INGRESS_VIP=

# Load Balancer node pool name
export POOL_NAME=pool1

#Address pool for laodbalancer services
# Address must be either in the CIDR form (1.2.3.0/24) (eg - 172.16.2.201/32)
# or range form (1.2.3.1-1.2.3.5) (eg - 172.18.0.20-172.18.0.40)
# THE INGRESS_VIP NEEDS TO PART OF THE ADDRESS POOL!!
export ADDRESS_POOL1=""

# Storage location for Cloud Operations
export CLOUD_OPS_LOCATION=

