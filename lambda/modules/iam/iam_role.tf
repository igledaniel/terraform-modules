resource "aws_iam_role" "iam_role" {
  assume_role_policy = "${data.aws_iam_policy_document.assume_lambda_role.json}"
}
