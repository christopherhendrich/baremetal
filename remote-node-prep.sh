sudo setenforce 0
sudo sed -i -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
sudo yum install -y yum-utils
sudo systemctl disable firewalld --now
sudo yum install iproute-tc
