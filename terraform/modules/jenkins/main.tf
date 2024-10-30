# EFS File System
resource "aws_efs_file_system" "jenkins_data" {
  creation_token = "jenkins-data"
  encrypted      = true

  tags = {
    Name = "jenkins-efs"
    Environment = var.environment
  }
}

# Jenkins Master Instance
resource "aws_instance" "jenkins_master" {
  ami           = var.jenkins_ami
  instance_type = var.jenkins_master_instance_type
  subnet_id     = var.private_subnet_ids[0]

  vpc_security_group_ids = [var.jenkins_master_sg_id]
  key_name              = var.key_name

  user_data = templatefile("${path.module}/templates/jenkins-master-init.sh", {
    efs_id = aws_efs_file_system.jenkins_data.id
  })

  tags = {
    Name = "jenkins-master"
    Environment = var.environment
  }
}

# Jenkins Build Slave Instance
resource "aws_instance" "jenkins_build_slave" {
  ami           = var.jenkins_ami
  instance_type = var.jenkins_slave_instance_type
  subnet_id     = var.private_subnet_ids[0]

  vpc_security_group_ids = [var.jenkins_slave_sg_id]
  key_name              = var.key_name

  user_data = templatefile("${path.module}/templates/jenkins-build-slave-init.sh", {
    jenkins_master_ip = aws_instance.jenkins_master.private_ip
  })

  tags = {
    Name = "jenkins-build-slave"
    Environment = var.environment
  }
}

# Jenkins Deploy Slave Instance
resource "aws_instance" "jenkins_deploy_slave" {
  ami           = var.jenkins_ami
  instance_type = var.jenkins_slave_instance_type
  subnet_id     = var.private_subnet_ids[0]

  vpc_security_group_ids = [var.jenkins_slave_sg_id]
  key_name              = var.key_name

  user_data = templatefile("${path.module}/templates/jenkins-deploy-slave-init.sh", {
    jenkins_master_ip = aws_instance.jenkins_master.private_ip
  })

  tags = {
    Name = "jenkins-deploy-slave"
    Environment = var.environment
  }
}
