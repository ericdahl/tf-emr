data "template_file" "iam_policy_emr_autoscaling" {
  template = "${file("${path.module}/templates/iam/policies/emr-autoscaling.json")}"
}

resource "aws_iam_policy" "emr_autoscaling" {
  name   = "emr_autoscaling"
  policy = "${data.template_file.iam_policy_emr_autoscaling.rendered}"
}

data "template_file" "iam_assume_autoscaling" {
  template = "${file("${path.module}/templates/iam/assume_roles/autoscaling.json")}"
}

resource "aws_iam_role" "emr_autoscaling" {
  name               = "emr_autoscaling"
  assume_role_policy = "${data.template_file.iam_assume_ec2.rendered}"
}

resource "aws_iam_role_policy_attachment" "emr_autoscaling" {
  policy_arn = "${aws_iam_policy.emr_autoscaling.arn}"
  role       = "${aws_iam_role.emr_autoscaling.name}"
}
