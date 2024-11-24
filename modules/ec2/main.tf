data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

data "aws_vpc" "instance" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

data "aws_security_group" "default" {
  vpc_id = local.vpc_id
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

locals {
  vpc_id    = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default.id
  ami       = var.ami != null ? var.ami : data.aws_ami.amazon.id
  subnet_id = var.subnet_id != null ? var.subnet_id : data.aws_subnets.default.ids[0]
}

resource "aws_security_group" "instance" {
  name        = var.instance_name
  description = "Security group for the ${var.instance_name} instance"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.instance.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags)
}

# Create a profile to allow instance connect
resource "aws_iam_instance_profile" "default" {
  name_prefix = var.instance_name
  role        = aws_iam_role.instance.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "instance" {
  name_prefix        = var.instance_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "instance" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the instance
resource "aws_instance" "instance" {
  ami                         = local.ami
  subnet_id                   = local.subnet_id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.default.name
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public
  user_data                   = var.user_data

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  vpc_security_group_ids = [aws_security_group.instance.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  volume_tags = merge(var.tags, {
    Name = var.instance_name
  })

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}
