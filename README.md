# AWS CI/CD for Docker Application on EC2

## Project Overview

This project demonstrates a fully automated **CI/CD pipeline** using **AWS services** to build, push, and deploy a Docker application on an EC2 instance. The pipeline is triggered automatically on GitHub commits and orchestrates the workflow from source to deployment.

---

## Architecture / Workflow

GitHub → CodePipeline → CodeBuild → EC2 Deploy

- **GitHub**: Source repository containing the application code
- **CodePipeline**: Orchestrates the pipeline stages:
  - Source stage: Pulls code from GitHub
  - Build stage: Builds Docker image using CodeBuild and pushes to Docker Hub
  - Deploy stage: Deploys the Docker container on EC2
- **CodeBuild**: Builds Docker image, logs into Docker Hub using credentials stored in AWS Parameter Store.
- **EC2 Deploy**: Executes `deploy.sh` directly from the GitHub source artifact as a post-deploy action to run the Docker container.

---

## IAM Roles & Policies

### **CodeBuild Role**
- `AmazonSSMReadOnlyAccess`
- `CloudWatchFullAccess`

### **CodePipeline Role**
- `AmazonEC2FullAccess`
- `AmazonS3FullAccess`
- `AmazonSSMFullAccess`
- `CloudWatchFullAccess`
- Additional policies for integration with **CodeBuild**, **CodeStar**, and **Code Connection** if not automatically attached.

### **EC2 Role**
- `AmazonS3FullAccess`
- `AmazonSSMManagedInstanceCore`

---

## AWS Systems Manager Parameter Store

The following parameters are required in **Parameter Store** for Docker Hub credentials that are referenced by CodeBuild to authenticate and push Docker images.

- /myapp/docker-credentials/username
- /myapp/docker-credentials/password
- /myapp/docker-registry/url

---

## EC2 Instance Setup (User Data)

The EC2 instance is configured using the following **user data script**:

```bash
# Update system
sudo apt update -y
sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Start and enable SSM Agent (installed via snap)
sudo snap start amazon-ssm-agent
sudo snap enable amazon-ssm-agent
sudo snap services amazon-ssm-agent
```

---

## Notes

- The pipeline triggers automatically when code is pushed to the GitHub repo (via webhook).

- The EC2 instance used for deployment:
    -  must have port 5000 inbound open from anywhere(IPv4).
    -  must have Docker installed and SSM Agent running.

- Replace this with your own Docker username and image name in deploy.sh
    - docker_image="homkar8/aws-cicd-python-app:latest"
