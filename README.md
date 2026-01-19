# Jenkins Cloud CI/CD Pipeline (AWS ECS Deployment)

An end-to-end **production-style CI/CD pipeline** built using **Jenkins**, **Docker**, and **AWS**, demonstrating how a Java Spring Boot application can be automatically built, containerized, stored, and deployed to the cloud with approval gates and rollback-ready deployment strategy.

---

## Project Overview

This project implements a **main-branch CI/CD pipeline** that:

- Builds a Java Spring Boot application using Maven  
- Stores build artifacts securely in Amazon S3  
- Containerizes the application using Docker  
- Pushes Docker images to Amazon ECR with versioning  
- Deploys the application to Amazon ECS (Fargate)  
- Uses an Application Load Balancer for public access  
- Includes a manual approval step before production deployment  

The pipeline closely resembles **real-world DevOps workflows** used in production environments.

---

## Screenshots

The following screenshot demonstrates a **successful end-to-end pipeline execution**:

/screenshots/output.png

## Tech Stack

### CI/CD
- Jenkins (Declarative Pipeline)
- GitHub

### Build & Packaging
- Java 17
- Maven
- Spring Boot

### Containerization
- Docker
- Amazon Elastic Container Registry (ECR)

### Cloud & Deployment
- AWS ECS (Fargate)
- Application Load Balancer (ALB)
- Amazon S3 (Artifact Storage)
- AWS IAM

### Operating System
- Windows (Jenkins Local Agent)

---

## Jenkins Pipeline Stages

| Stage | Description |
|------|------------|
| Checkout | Pull source code from GitHub |
| Build & Package | Build Spring Boot application using Maven |
| Backup Artifact to S3 | Store generated JAR file in Amazon S3 |
| Docker Build | Build Docker image using custom Dockerfile |
| Push Image to ECR | Push versioned and `latest` images to Amazon ECR |
| Manual Approval | Approval gate before production deployment |
| ECS Deploy | Trigger rolling deployment on Amazon ECS |
| Wait for ECS | Ensure service reaches stable state |

---

## Artifact & Image Strategy

### Build Artifacts
- Stored in **Amazon S3**
- Versioned using **Jenkins build number**

### Docker Image Tagging
- `latest` → Used by ECS task definition
- `<git-commit-sha>` → Traceability and rollback support

This strategy ensures **reproducibility, auditability, and safe deployments**.

---

## AWS Architecture (High Level)

- **ECS Cluster (Fargate)** – Runs containerized application  
- **ECR Repository** – Stores Docker images  
- **Application Load Balancer** – Public entry point  
- **Target Group** – Health checks and traffic routing  
- **S3 Bucket** – Artifact storage  
- **IAM Roles & Users** – Secure service access  

---

## Deployment Verification

After a successful pipeline run:

- ECS service shows **RUNNING task**
- Target group reports **healthy target**
- Application is accessible via **ALB DNS URL**
