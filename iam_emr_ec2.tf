data "template_file" "iam_policy_emr_ec2" {
  template = "${file("${path.module}/templates/iam/policies/emr-ec2.json")}"
}

resource "aws_iam_policy" "emr_ec2" {
  name   = "emr_ec2"
  policy = "${data.template_file.iam_policy_emr_ec2.rendered}"
}

data "template_file" "iam_assume_ec2" {
  template = "${file("${path.module}/templates/iam/assume_roles/ec2.json")}"
}

resource "aws_iam_role" "emr_ec2" {
  name               = "emr_ec2"
  assume_role_policy = "${data.template_file.iam_assume_ec2.rendered}"
}

resource "aws_iam_role_policy_attachment" "emr_ec2" {
  policy_arn = "${aws_iam_policy.emr_ec2.arn}"
  role       = "${aws_iam_role.emr_ec2.name}"
}

resource "aws_iam_instance_profile" "emr_ec2" {
  name = "emr-ec2-instance-profile"
  role = "${aws_iam_role.emr_ec2.name}"
}
