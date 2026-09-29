variable "key_name" {
  default = "your-key-pair-name" # Replace with your actual AWS key pair name
}

# Node 1: Web Server (t2.micro, 60 GB Storage, Pre-installed with Docker)
resource "aws_instance" "web_server" {
  ami                         = "ami-01a00762f46d584a1" # Ubuntu 22.04 LTS
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 60
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Node1-WebServer"
  }
}

# Node 2: Configuration / CI-CD Hub (c7i-flex.large[cite: 3], 60 GB Storage, Jenkins, SonarQube, Trivy, Docker)
resource "aws_instance" "config_node" {
  ami                         = "ami-01a00762f46d584a1" 
  instance_type               = "c7i-flex.large"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 60
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              usermod -aG docker ubuntu
              apt install openjdk-17-jre -y
              curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              apt-get update
              apt-get install jenkins -y
              systemctl enable jenkins
              systemctl start jenkins
              apt-get install wget apt-transport-https gnupg lsb-release -y
              wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
              echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
              apt-get update
              apt-get install trivy -y
              EOF

  tags = {
    Name = "Node2-Config-CI-CD"
  }
}

# Node 3: Monitoring Node (t2.micro, 60 GB Storage, CloudWatch IAM Profile)
resource "aws_instance" "monitor_node" {
  ami                         = "ami-01a00762f46d584a1"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.monitor_sg.id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_agent_profile.name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 60
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Node3-Monitor"
  }
}

# Permanent Elastic IPs
resource "aws_eip" "web_eip" {
  instance = aws_instance.web_server.id
  domain   = "vpc"
  tags     = { Name = "Node1-EIP" }
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.config_node.id
  domain   = "vpc"
  tags     = { Name = "Node2-EIP" }
}

resource "aws_eip" "monitor_eip" {
  instance = aws_instance.monitor_node.id
  domain   = "vpc"
  tags     = { Name = "Node3-EIP" }
}