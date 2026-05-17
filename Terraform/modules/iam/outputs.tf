output "instance_profile_name" {
  value = aws_iam_instance_profile.arc_bonus_ec2.name
}

output "role_name" {
  value = aws_iam_role.arcanum_ec2_role01.name
}