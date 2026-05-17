output "arcanum_db_endpoint" { value = aws_db_instance.arcanum_rds01.address }
output "arcanum_db_port" { value = aws_db_instance.arcanum_rds01.port }
output "arcanumdb_identifier" { value = aws_db_instance.arcanum_rds01.identifier }

output "arcanum_secret_arn" { value = aws_secretsmanager_secret.arcanum_db_secret01.arn }
output "arcanum_secret_name" { value = aws_secretsmanager_secret.arcanum_db_secret01.name }