sudo setenforce 0
sudo sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
sudo yum install -y yum-utils
sudo systemctl disable firewalld --now
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker --now
sudo usermod -aG docker $USER
