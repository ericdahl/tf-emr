data "template_file" "iam_policy_emr" {
  template = "${file("${path.module}/templates/iam/policies/emr.json")}"
}

resource "aws_iam_policy" "emr" {
  name   = "emr"
  policy = "${data.template_file.iam_policy_emr.rendered}"
}

data "template_file" "iam_assume_emr" {
  template = "${file("${path.module}/templates/iam/assume_roles/emr.json")}"
}

resource "aws_iam_role" "emr" {
  name               = "emr"
  assume_role_policy = "${data.template_file.iam_assume_emr.rendered}"
}

resource "aws_iam_role_policy_attachment" "emr" {
  policy_arn = "${aws_iam_policy.emr.arn}"
  role       = "${aws_iam_role.emr.name}"
}
