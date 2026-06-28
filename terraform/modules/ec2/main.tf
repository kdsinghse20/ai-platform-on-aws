resource "aws_instance" "this" {

  ami                         = var.ami_id
  instance_type               = var.instance_type

  subnet_id                   = var.subnet_id

  vpc_security_group_ids       = var.security_group_ids

  iam_instance_profile         = var.iam_instance_profile

  key_name                     = var.key_name

  user_data                    = var.user_data

  associate_public_ip_address  = false

  monitoring = true

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

  }

  root_block_device {

    volume_size = var.root_volume_size

    volume_type = "gp3"

    encrypted = true

    delete_on_termination = true

  }

  tags = merge(

    local.common_tags,

    {

      Name = var.instance_name

    }

  )

}
