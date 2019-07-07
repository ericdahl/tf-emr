resource "aws_security_group" "service_access" {
  vpc_id = "${module.vpc.vpc_id}"
  name   = "emr-service-access"
}

resource "aws_security_group_rule" "service_access_egress" {
  security_group_id = "${aws_security_group.service_access.id}"

  type      = "egress"
  protocol  = "all"
  from_port = -1
  to_port   = -1

  cidr_blocks = ["0.0.0.0/0"]
}
