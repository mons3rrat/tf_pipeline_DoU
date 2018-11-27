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


resource "aws_security_group" "sedenom" {
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

resource "aws_instance" "nginx" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.my_private_key_path}")}"
    }

    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo apt update",
    ]
  }
}

resource "aws_instance" "postgresql-server" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  user_data              = "${file("install.sh")}"
}

output "nginx-ip" {
  value = "${aws_instance.nginx.public_ip}"
}

output "postgresql-ip" {
  value = "${aws_instance.postgresql-server.public_ip}"
}
