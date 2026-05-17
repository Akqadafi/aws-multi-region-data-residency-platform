data "aws_ssm_parameter" "al2023_ami" {
  name = var.ami_ssm_parameter_name
}

# resource "aws_iam_role" "arcanum_ec2_role01" {
#   name = "${var.name_prefix}-ec2-role01"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }

# Same policy as your main1.tf (reads the one lab secret).
# Note: it references the secret ARN dynamically, so you can optionally pass it in later
# if you want strict decoupling. For now, keep it simple—most labs accept this.
# If you want decoupling, we can add variable "secret_arn" and wire from module.database.
# resource "aws_iam_policy" "arcanum_secrets_policy" {
#   name        = "secrets_policy"
#   description = "Least-privilege Secrets Manager read access for lab secret only"

#   policy = jsonencode({
#     Version : "2012-10-17",
#     Statement : [
#       {
#         Sid : "ReadLabSecret",
#         Effect : "Allow",
#         Action : [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#         ],
#         Resource : "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "arcanum_ec2_secrets_attach" {
#   role       = aws_iam_role.arcanum_ec2_role01.name
#   policy_arn = aws_iam_policy.arcanum_secrets_policy.arn
# }

# resource "aws_iam_instance_profile" "arcanum_instance_profile01" {
#   name = "${var.name_prefix}-instance-profile01"
#   role = aws_iam_role.arcanum_ec2_role01.name
# }

# resource "aws_iam_role_policy_attachment" "arcanum_ec2_ssm_attach" {
#   role       = aws_iam_role.arcanum_ec2_role01.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_role_policy_attachment" "arcanum_ec2_cw_attach" {
#   role       = aws_iam_role.arcanum_ec2_role01.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

resource "aws_instance" "arcanum_ec201" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.ec2_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.ec2_security_group_id]

  iam_instance_profile        = var.iam_instance_profile_name
  user_data_replace_on_change = false
  associate_public_ip_address = var.associate_public_ip

  user_data = file("${path.module}/${var.user_data_file}")

  # Keep the running instance stable when the "latest AMI" SSM value changes.
  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec201"
  })
}
