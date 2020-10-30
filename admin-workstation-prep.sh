#Load variables
./variables.sh

#Set SELinux to permissive
echo "Setting SELINUX to PERMISSIVE"
sudo setenforce 0
sudo sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

#Disable firewalld
echo "Disabling firewalld"
sudo systemctl disable firewalld --now

#Install Docker 19.03
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker --now
sudo usermod -aG docker $USER

#Install Google Cloud SDK
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
sudo yum install google-cloud-sdk -y
#Install KUBECTL
sudo yum install kubectl -y

#Create SSH Key
mkdir keys
ssh-keygen -t rsa -f ~/keys/node-key -q -N ""

#Copy to node machines - will ask for user password
ssh-copy-id -i ~/keys/node-key $WORKER_1_USERNAME@$WORKER_NODE_1_IP
scp -i ~/keys/node-key ./remote-node-prep.sh $WORKER_1_USERNAME@$WORKER_NODE_1_IP:/home/$WORKER_1_USERNAME/
# Uncomment the two lines below, if you use 2 worker nodes - duplicate and change number if you use more worker nodes
#ssh-copy-id -i ~/keys/node-key $WORKER_2_USERNAME@$WORKER_NODE_2_IP
#scp -i ~/keys/node-key ./remote-node-prep.sh $WORKER_2_USERNAME@$WORKER_NODE_2_IP:/home/$WORKER_2_USERNAME/


#Prep up GCP
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud services enable servicemanagement.googleapis.com servicecontrol.googleapis.com 

#Create a service account key
gcloud iam service-accounts keys create ~/keys/gcr.json \
  --iam-account=$ACCESS_GSA_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --project=$PROJECT_ID

#Installing BMCTL
cd ~
mkdir baremetal
cd baremetal
gcloud auth activate-service-account --key-file=/home/$ADMIN_WORKSTATION_USER/keys/gcr.json
gsutil cp gs://anthos-baremetal-release/bmctl/0.5.0-gke.2/linux/bmctl .
chmod a+x bmctl
gcloud config set account $USER_EMAIL_ADDRESS

#Creating GSA for Connect
cd ~/baremetal

gcloud services enable --project=$PROJECT_ID \
  container.googleapis.com \
  gkeconnect.googleapis.com \
  gkehub.googleapis.com \
  cloudresourcemanager.googleapis.com \
  anthos.googleapis.com

gcloud iam service-accounts create connect-agent-svc-account \
  --project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:connect-agent-svc-account@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.connect"

gcloud iam service-accounts keys create ~/keys/connect-agent.json \
  --iam-account=connect-agent-svc-account@$PROJECT_ID.iam.gserviceaccount.com \
  --project=$PROJECT_ID

#Creating GSA for registering the cluster in GKE-Hub
gcloud iam service-accounts create connect-register-svc-account \
  --project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:connect-register-svc-account@$PROJECT_ID.iam.gserviceaccount.com" \
  --role=roles/gkehub.admin

gcloud iam service-accounts keys create ~/keys/connect-register.json \
  --iam-account=connect-register-svc-account@$PROJECT_ID.iam.gserviceaccount.com \
  --project=$PROJECT_ID

#Creating GSA for logging and monitoring
gcloud services enable --project $PROJECT_ID \
  anthos.googleapis.com \
  anthosgke.googleapis.com \
  cloudresourcemanager.googleapis.com \
  container.googleapis.com \
  gkeconnect.googleapis.com \
  gkehub.googleapis.com \
  serviceusage.googleapis.com \
  stackdriver.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com

gcloud iam service-accounts create logging-monitoring-svc-account \
  --project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:logging-monitoring-svc-account@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:logging-monitoring-svc-account@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter"

gcloud iam service-accounts keys create ~/keys/cloud-ops.json \
  --iam-account=logging-monitoring-svc-account@$PROJECT_ID.iam.gserviceaccount.com \
  --project=$PROJECT_ID 



