resource "aws_iam_group" "symph" {
  name = "symph"
}

resource "aws_iam_group_policy_attachment" "symph-ec2" {
  group      = "${aws_iam_group.symph.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "symph-route53" {
  group      = "${aws_iam_group.symph.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "symph-s3" {
  group      = "${aws_iam_group.symph.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "symph-iam" {
  group      = "${aws_iam_group.symph.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "symph-vpc" {
  group      = "${aws_iam_group.symph.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}