resource "aws_security_group" "slave" {
  vpc_id = "${module.vpc.vpc_id}"
  name   = "emr-slave"
}

resource "aws_security_group_rule" "slave_egress" {
  security_group_id = "${aws_security_group.slave.id}"

  type      = "egress"
  protocol  = "all"
  from_port = -1
  to_port   = -1

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "slave_icmp_self" {
  security_group_id = "${aws_security_group.slave.id}"

  type                     = "ingress"
  protocol                 = "icmp"
  from_port                = -1
  to_port                  = -1
  source_security_group_id = "${aws_security_group.slave.id}"
}

resource "aws_security_group_rule" "slave_tcp_self" {
  security_group_id = "${aws_security_group.slave.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.slave.id}"
}

resource "aws_security_group_rule" "slave_udp_self" {
  security_group_id = "${aws_security_group.slave.id}"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.slave.id}"
}

resource "aws_security_group_rule" "slave_icmp_master" {
  security_group_id = "${aws_security_group.slave.id}"

  type                     = "ingress"
  protocol                 = "icmp"
  from_port                = -1
  to_port                  = -1
  source_security_group_id = "${aws_security_group.master.id}"
}

resource "aws_security_group_rule" "slave_tcp_master" {
  security_group_id = "${aws_security_group.slave.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.master.id}"
}

resource "aws_security_group_rule" "slave_udp_master" {
  security_group_id = "${aws_security_group.slave.id}"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = "${aws_security_group.master.id}"
}

resource "aws_security_group_rule" "slave_tcp_service_access" {
  security_group_id = "${aws_security_group.slave.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8443
  to_port                  = 8443
  source_security_group_id = "${aws_security_group.service_access.id}"
}
