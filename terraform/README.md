terraform/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── providers.tf 
├── scripts/
│   ├── elevates-key
│   ├── elevates-key.pub


===========================================
VPC + Network Configuration
1. VPC
CIDR: 10.0.0.0/16

DNS Support: Enabled

2. Subnets
Name	Type	CIDR Block	AZ
public-subnet-1	Public	10.0.1.0/24	us-east-1a
private-subnet-1	Private	10.0.2.0/24	us-east-1a
private-subnet-2	Private	10.0.3.0/24	us-east-1a

3. Internet Gateway
Attach to VPC

Add to public route table as 0.0.0.0/0 route target

4. Route Tables
public-rt: Associate with public-subnet-1, route 0.0.0.0/0 → IGW

private-rt: Associate with private-subnet-{1,2}, route 0.0.0.0/0 → bastion-private-IP

🖥 EC2 Instances Configuration
Name	Subnet	Type	Key Pair	AMI	Additional
Bastion	Public Subnet	t3.small	your-key	Ubuntu 22.04	NAT, Jenkins, Ansible
Frontend	Public Subnet	t3.small	your-key	Ubuntu 22.04	Node.js frontend
Backend	Private Subnet 1	t3.small	your-key	Ubuntu 22.04	Node.js backend
PostgreSQL	Private Subnet 2	t3.small	your-key	Ubuntu 22.04	PostgreSQL server

🔐 Security Groups Configuration
✅ Bastion SG
Allow:

SSH from your public IP only (port 22)

✅ Frontend SG
Allow:

HTTP (80) from 0.0.0.0/0

SSH (22) from Bastion SG

✅ Backend SG
Allow:

3000 from Frontend SG

SSH (22) from Bastion SG

✅ DB SG
Allow:

5432 from Backend SG

SSH (22) from Bastion SG

🌐 Bastion NAT Configuration (Post-Instance)
You'll need to configure NAT manually on Bastion using user_data or Ansible:

1. Enable IP Forwarding
bash
Copy
Edit
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
2. Setup iptables NAT
bash
Copy
Edit
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
3. Persist NAT Rules
bash
Copy
Edit
sudo apt install iptables-persistent -y
sudo netfilter-persistent save
4. In Private Route Table
Add default route: 0.0.0.0/0 → Bastion private IP

🔑 SSH Key Pair
Generate locally:

bash
Copy
Edit
ssh-keygen -t rsa -f terraform-devops-key
Upload .pub to AWS using aws_key_pair resource

Use private key to SSH into Bastion, then hop to backend/db

🧪 Terraform Outputs (Recommended)
Bastion public IP

Frontend public IP

Backend private IP

DB private IP

These outputs will help Jenkins and Ansible targets later.

✅ Summary of Terraform Resources to Define
Terraform Resource	Purpose
aws_vpc	Virtual network
aws_subnet	Public and private subnets
aws_internet_gateway	Internet access
aws_route_table	Public and private route tables
aws_security_group	Controlled access to EC2s
aws_instance	EC2 servers
aws_key_pair	SSH key management
aws_eip (optional)	Static IPs for frontend/bastion
aws_route	Routing NAT traffic to bastion
terraform output	Exporting IPs for CI/CD