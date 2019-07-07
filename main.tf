provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source        = "github.com/ericdahl/tf-vpc"
  admin_ip_cidr = "${var.admin_cidr}"
}


resource "aws_s3_bucket" "emr_logs" {
  bucket = "tf-emr-logs"

  force_destroy = true
}


resource "aws_emr_cluster" "default" {
  name          = "tf-emr"
  release_label = "emr-5.24.1"
  applications  = ["Spark", "Hive"]

  log_uri = "s3://${aws_s3_bucket.emr_logs.bucket}/"

  ec2_attributes {
    subnet_id                         = "${module.vpc.subnet_private1}"
    emr_managed_master_security_group = "${aws_security_group.master.id}"
    emr_managed_slave_security_group  = "${aws_security_group.slave.id}"
    service_access_security_group     = "${aws_security_group.service_access.id}"
    instance_profile                  = "${aws_iam_instance_profile.emr_ec2.arn}"
    key_name                          = "${var.key_name}"

  }

  master_instance_group {
    instance_type = "m4.large"
  }

  core_instance_group {
    instance_type  = "c4.large"
    instance_count = 1

    ebs_config {
      size                 = "40"
      type                 = "gp2"
      volumes_per_instance = 1
    }

    bid_price = "0.30"
  }

  ebs_root_volume_size = 100

  tags {
    Name = "tf-emr"
  }

  bootstrap_action {
    path = "s3://elasticmapreduce/bootstrap-actions/run-if"
    name = "runif"
    args = ["instance.isMaster=true", "echo running on master node"]
  }

  service_role = "${aws_iam_role.emr.arn}"
}



data "aws_ami" "freebsd_11" {
  most_recent = true

  owners = ["118940168514"]

  filter {
    name = "name"

    values = [
      "FreeBSD 11.1-STABLE-amd64*",
    ]
  }
}


resource "aws_instance" "jumphost" {
  ami                    = "${data.aws_ami.freebsd_11.image_id}"
  instance_type          = "t2.small"
  subnet_id              = "${module.vpc.subnet_public1}"
  vpc_security_group_ids = ["${module.vpc.sg_allow_22}", "${module.vpc.sg_allow_egress}"]
  key_name               = "${var.key_name}"

  user_data = <<EOF
#!/usr/bin/env sh

export ASSUME_ALWAYS_YES=YES

pkg update -y
pkg install -y bash
chsh -s /usr/local/bin/bash ec2-user
EOF

  tags {
    Name = "jumphost"
  }
}
