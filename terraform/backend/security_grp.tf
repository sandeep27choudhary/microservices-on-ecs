# main.tf

# Security group for the backend service
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Security group for the backend service"
  vpc_id      = var.vpc_id

  # Inbound rule to allow traffic from the frontend service
  ingress {
    from_port   = 3000  # Assuming backend service runs on port 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule to allow egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the inventory service
resource "aws_security_group" "inventory_sg" {
  name        = "inventory-sg"
  description = "Security group for the inventory service"
  vpc_id      = var.vpc_id

  # Inbound rule to allow traffic from the backend service
  ingress {
    from_port       = 5000  # Assuming inventory service runs on port 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  # Outbound rule to allow egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
