#MY FIRST EC2 TERRRAFORM FILE

provider "aws" {
  profile = "YOUR_AWS_PROFILE_NAME"
  region  = "us-east-2"
}


resource "aws_security_group" "terraform-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
    
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "terraform-ec2" {
  ami = "MENTION_THE_AMI_ID"  #mention the os ami id
  instance_type= "t2.micro"
  key_name= "key_pair_name"   #use key pair name without .pem extension
  security_groups= ["${aws_security_group.terraform-sg.name}"]
  availability_zone = "us-east-2a"
  user_data =   <<-EOF
                #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo systemctl start apache2
                sudo systemctl enable apache2
                echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
                EOF
  tags = {
    Name = "Webserver"
   }


  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
    iops = "100"
    delete_on_termination = "true"
 }
  provisioner "local-exec" {
    command = "echo ${aws_instance.terraform-ec2.public_ip} > ip_add.txt"
  }
}

