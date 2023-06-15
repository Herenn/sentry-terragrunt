terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical Account ID
}

resource "aws_instance" "sentry_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id  = var.subnet_id  # Replace with your subnet ID

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("your-secret.pem")  # Update with the path to your private key
      host        = self.public_ip
    }

    inline = [
      "sudo apt-get update",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "sudo apt-get install -y git",
      "sudo apt-cache policy docker-ce",
      "sudo apt update",
      "sudo apt install -y docker-ce",
      "sudo systemctl start docker",
      "git clone https://github.com/getsentry/self-hosted",
      "cd self-hosted",
      "sudo ./install.sh --skip-user-creation --report-self-hosted-issues",
      "yes | sudo docker compose run -T --rm web createuser --email ${var.email} --password ${var.password}",
      "sudo docker compose up -d"
    ]
  }
}

output "sentry_url" {
  value = aws_instance.sentry_instance.public_ip
}
