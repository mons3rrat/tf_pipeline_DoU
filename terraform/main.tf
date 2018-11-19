data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners      = ["099720109477"]
  most_recent = true
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "${file(var.my_public_key_path)}"
}


resource "aws_security_group" "sg" {
  name = "gmlp-ssh"

  // SSH
  ingress {
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
}

resource "aws_instance" "docker" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

}

resource "null_resource" "install_docker" {
  triggers {
    instance_id = "${aws_instance.docker.id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.my_private_key_path}")}"
    host = "${aws_instance.docker.public_ip}"
  }
  provisioner "remote-exec" {

    inline = [
      "sudo apt-get clean",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce=17.06.2~ce-0~ubuntu",
      "sudo usermod -a ubuntu -G docker"
    ]
  }

}



output "docker-ip" {
  value = "${aws_instance.docker.public_ip}"
}
