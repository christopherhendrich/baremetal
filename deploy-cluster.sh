#Creating the config file
cd ~/baremetal/
./bmctl create config -c $CLUSTER_NAME
rm ./bmctl-workspace/$CLUSTER_NAME/$CLUSTER_NAME.yaml

cat > /home/$ADMIN_WORKSTATION_USER/baremetal/bmctl-workspace/$CLUSTER_NAME/$CLUSTER_NAME.yaml << EOF
---
# Path to GCR service account key file.
gcrKeyPath: /home/$ADMIN_WORKSTATION_USER/keys/gcr.json
# Path to private ssh key
sshPrivateKeyPath: /home/$ADMIN_WORKSTATION_USER/keys/node-key
# Path to connect.json key file.
gkeConnectAgentServiceAccountKeyPath: /home/$ADMIN_WORKSTATION_USER/keys/connect-agent.json
# Path to register.json key file.
gkeConnectRegisterServiceAccountKeyPath: /home/$ADMIN_WORKSTATION_USER/keys/connect-register.json
# Path to cluster-ops.json key file.
cloudOperationsServiceAccountKeyPath: /home/$ADMIN_WORKSTATION_USER/keys/cloud-ops.json
---
apiVersion: v1
kind: Namespace
metadata:
  name: cluster-$CLUSTER_NAME
---
apiVersion: baremetal.cluster.gke.io/v1alpha1
kind: Cluster
metadata:
  name: $CLUSTER_NAME
  namespace: cluster-$CLUSTER_NAME
spec:
  # Cluster type. This can be:
  # 1) admin:  to create an admin cluster. This can later be used to create
  # user clusters
  # 2) user:   to create a user cluster. Requires an existing admin cluster.
  # 3) hybrid: to create a hybrid cluster (a single cluster that runs admin
  # cluster
  # components as well as user workloads).
  type: hybrid
  # Anthos cluster version
  # This is currently a placeholder for upgrading the cluster version.
  # It needs to be "v1.6.0" for now. Please do not modify it.
  anthosBareMetalVersion: v1.6.0
  # credentials refer to the default secrets created by bmctl during deployment.
  credentials:
    sshKeySecret:
      name: ssh-key
      namespace: anthos-creds
    imagePullSecret:
      name: private-registry-creds
      namespace: anthos-creds
  # GKE connect configuration
  gkeConnect:
  # GCP project used by Connect.
    projectID: $PROJECT_ID
    connectServiceAccountSecret:
      name: gke-connect
      namespace: anthos-creds
    registerServiceAccountSecret:
      name: gke-register
      namespace: anthos-creds
  # Control Plane configuration
  controlPlane:
    nodePoolSpec:
      # IP address of the control plane node accessible from the machine
      # running bmctl (can be public IP).
      nodes:
      - address: $CONTROL_PLANE_IP
  clusterNetwork:
    # Specify the network ranges from which Pod networks are allocated.
    # Use any values but ensure they do not conflict with other cidrs.
    pods:
      cidrBlocks:
      - $POD_CIDR
    # Specify the network ranges from which service VIPs are allocated.
    # Use any values but ensure they do not conflict with other cidrs.
    services:
      cidrBlocks:
      - $SERVICE_CIDR
  # Load Balancer Configuration
  loadBalancer:
    # Specify two load balancer VIPs: one for the control plane
    # and one for the L7 Ingress service.
    # The VIPs must be in the same L2 subnet as the load balancer node.
    # In this quickstart, the load balancer node is the same as the
    # control plane node.
    vips:
      # ControlPlaneVIP specifies the VIP to connect to the Kubernetes API server.
      # This address must not be in the address pools below.
      controlPlaneVIP: $CONTROL_PLANE_VIP
      # IngressVIP specifies the VIP shared by all services for ingress traffic.
      # This address must be in the address pools below.
      ingressVIP: $INGRESS_VIP
    # A list of non-overlapping IP ranges for the data plane load balancer.
    # All addresses must be in the same L2 subnet as the load balancer nodes.
    # The above ControlPlaneVIP must not be in the address pools.
    # The above IngressVIP must be in the address pools.
    addressPools:
    # Pool name can be any string (eg pool1).
    - name: $POOL_NAME
      addresses:
      # Address must be either in the CIDR form (1.2.3.0/24) (eg - 172.16.2.201/32)
      # or range form (1.2.3.1-1.2.3.5) (eg - 172.18.0.20-172.18.0.40)
      - $ADDRESS_POOL1
  # Logging and Monitoring
  # Optional Cloud Operations (logging/monitoring) configuration
  clusterOperations:
    # Cloud project for logs and metrics.
    projectID: $PROJECT_ID
    # Cloud location for logs and metrics.
    location: $CLOUD_OPS_LOCATION
    serviceAccountSecret:
      name: google-cloud-credentials
      namespace: anthos-creds
  # Local volume provisioning configuration
  storage:
    lvpNodeMounts:
      path: /mnt/localpv-disk
      storageClassName: node-disk
    lvpShare:
      numPVUnderSharedPath: 5
      path: /mnt/localpv-share
      storageClassName: standard
---
# Node pools for worker nodes
apiVersion: baremetal.cluster.gke.io/v1alpha1
kind: NodePool
metadata:
  name: worker-node-pool-name
  namespace: cluster-$CLUSTER_NAME
spec:
  clusterName: $CLUSTER_NAME
  nodes:
  - address: $WORKER_NODE_1_IP
EOF

./bmctl create cluster -c $CLUSTER_NAME --alsologtostderr -v

echo "Don't forget to save your keys to a safe location and delete the /keys folder on this machine!"