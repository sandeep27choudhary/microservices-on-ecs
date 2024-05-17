# Microservices on ECS

This repository contains an example of deploying microservices on AWS ECS (Elastic Container Service). The project includes a frontend service, a backend service, and an inventory service, demonstrating a complete microservices architecture.

## Table of Contents

- [Microservices on ECS](#microservices-on-ecs)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Services](#services)
    - [Frontend Service](#frontend-service)
    - [Backend Service](#backend-service)
    - [Inventory Service](#inventory-service)
  - [Setup](#setup)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Running Locally](#running-locally)
    - [Deploying to AWS ECS](#deploying-to-aws-ecs)
  - [Usage](#usage)
  - [Contributing](#contributing)
  - [License](#license)

## Overview

This project demonstrates a simple microservices architecture deployed on AWS ECS. It consists of three main services:

1. **Frontend**: A static HTML frontend served by an NGINX server.
2. **Backend**: A Node.js Express server that handles requests from the frontend and communicates with the inventory service.
3. **Inventory**: A Python Flask application that manages product data.

## Services

### Frontend Service

- **Language**: HTML, JavaScript
- **Description**: Provides a simple web interface to interact with the backend service.
- **Dockerfile**: Uses NGINX to serve static content.

### Backend Service

- **Language**: Node.js
- **Framework**: Express
- **Description**: Handles API requests from the frontend and fetches product data from the inventory service.
- **Dockerfile**: Uses Node.js to run the server.

### Inventory Service

- **Language**: Python
- **Framework**: Flask
- **Description**: Manages the product inventory and serves data to the backend service.
- **Dockerfile**: Uses Python to run the Flask application.

## Setup

### Prerequisites

- Docker
- Docker Compose
- AWS CLI configured with necessary permissions
- Terraform and Terragrunt (optional, if infrastructure as code is used)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/sandeep27choudhary/microservices-on-ecs.git
cd microservices-on-ecs
