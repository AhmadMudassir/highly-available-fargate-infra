# 🚀 Highly Available Nginx Deployment on AWS ECS Fargate with ALB and EFS using Terraform

This project demonstrates how to deploy an **Nginx container** on **AWS ECS Fargate** behind an **Application Load Balancer (ALB)** with persistent storage using **EFS**. All infrastructure is defined and provisioned using **Terraform**.

---

## 📦 Project Overview

The infrastructure includes:

- A custom **VPC** spanning two Availability Zones
- Public and private subnets for high availability
- Internet Gateway and NAT Gateways
- Route tables with public and private routing
- Security groups for ALB, ECS tasks, and EFS
- **Application Load Balancer (ALB)** with listeners and target groups
- **Amazon ECS** cluster with Fargate launch type
- **Amazon ECR** to store the custom Nginx Docker image
- ECS Task Definition mounting **Amazon EFS** for persistent storage

---

## 🖼 Architecture Diagram

![ecs_efs_private (1)](https://github.com/user-attachments/assets/d4920ed4-1dfb-43e0-bf30-21741e217572)

---

## 🛠 Technologies Used

- **Terraform** for Infrastructure as Code
- **AWS ECS (Fargate)** for container orchestration
- **AWS ALB** for load balancing
- **AWS ECR** to store the Docker image
- **AWS EFS** for persistent shared storage
- **Docker** for image building and management
- **IAM Roles & Policies** for ECS execution and EFS access

---

## 📁 Project Structure

## 📁 Project Structure

```bash
.
├── main.tf               # Core infrastructure definitions
├── variables.tf          # Input variables
├── nginx-dockerfile/     # Custom NGINX image context
│   ├── Dockerfile
│   └── index.html
└── README.md             # Project documentation
```


---

## 🚀 Getting Started

### ✅ Prerequisites

- Terraform v1.x installed
- AWS CLI configured (`aws configure`)
- Docker installed and running
- Sufficient AWS permissions (IAM, ECS, VPC, ECR, EFS)

---

### ⚙️ Deployment Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/AhmadMudassir/highly-available-fargate-infra.git
   cd highly-available-fargate-infra
   ```

2. **Update Variables**
   - Open `variables.tf` file.
   - Set your AWS region, CIDR blocks, owner tag, etc.
   - **IMPORTANT:** Replace any placeholder values in `main.tf`:
     - AWS Account ID
     - AWS Region
     - ECR Repository Name
   - For example, replace:
     ```
     <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repo-name>:v1
     ```
     with:
     ```
     123456789012.dkr.ecr.us-east-2.amazonaws.com/my-repo:v1
     ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the Execution Plan**
   ```bash
   terraform plan
   ```

5. **Apply the Configuration**
   ```bash
   terraform apply
   ```
   This will:
   - Provision the VPC, subnets, gateways, and route tables
   - Create the ALB with listeners and target groups
   - Build your custom Nginx Docker image and push it to ECR
   - Create the EFS filesystem and mount targets
   - Define the ECS Fargate Task with EFS volume mount
   - Deploy the ECS Service behind the ALB

6. **Verify the Deployment**
   - Get the ALB DNS name from the AWS console.
   - Visit:
     ```
     http://<alb-dns-name>
     ```
     in your browser.

---

## 🧹 Cleanup

To tear down all the resources:

```bash
terraform destroy
```

---

## 📝 Notes

- Make sure your AWS user/role has permissions for:
  - VPC, Subnet, IGW, NAT Gateway
  - ALB
  - ECS Cluster, Service, Task Definition
  - ECR (including authentication)
  - EFS
  - IAM Roles and Policies

- The Docker image is built and pushed automatically via the `null_resource` using local-exec. Ensure Docker is installed and running locally.

---
