resource "aws_db_subnet_group" "arcanum_rds_subnet_group01" {
  name       = "${var.project_name}-rds-subnet-group01"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-subnet-group01"
  })
}

resource "aws_db_instance" "arcanum_rds01" {
  identifier               = "${var.project_name}-rds01"
  engine                   = var.db_engine
  instance_class           = var.db_instance_class
  storage_type             = var.storage_type
  allocated_storage        = 20
  backup_retention_period  = 0
  db_name                  = var.db_name
  username                 = var.db_username
  password                 = var.db_password
  multi_az                 = false
  delete_automated_backups = false

  db_subnet_group_name   = aws_db_subnet_group.arcanum_rds_subnet_group01.name
  vpc_security_group_ids = [var.rds_security_group_id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds01"
  })

  depends_on = [aws_db_subnet_group.arcanum_rds_subnet_group01]
}

# Your ACTIVE secret block from main1.tf:
resource "aws_secretsmanager_secret" "arcanum_db_secret01" {
  name                    = "lab1a/rds/mysql"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "arcanum_db_secret_version01" {
  secret_id = aws_secretsmanager_secret.arcanum_db_secret01.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.arcanum_rds01.address
    port     = aws_db_instance.arcanum_rds01.port
    dbname   = var.db_name
  })

  depends_on = [aws_db_instance.arcanum_rds01]
}

resource "aws_ssm_parameter" "arcanum_db_endpoint_param" {
  name  = "/lab/db/endpoint"
  type  = "String"
  value = aws_db_instance.arcanum_rds01.address

  tags = merge(var.tags, {
    Name = "${var.project_name}-param-db-endpoint"
  })
}

resource "aws_ssm_parameter" "arcanum_db_port_param" {
  name  = "/lab/db/port"
  type  = "String"
  value = tostring(aws_db_instance.arcanum_rds01.port)

  tags = merge(var.tags, {
    Name = "${var.project_name}-param-db-port"
  })
}

resource "aws_ssm_parameter" "arcanum_db_name_param" {
  name  = "/lab/db/name"
  type  = "String"
  value = var.db_name

  tags = merge(var.tags, {
    Name = "${var.project_name}-param-db-name"
  })
}
