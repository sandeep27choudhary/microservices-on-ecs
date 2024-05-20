# main.tf

# Security group for the backend service
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Security group for the backend service"
  vpc_id      = var.vpc_id

  # Inbound rule to allow traffic from the frontend service
 ingress {
    description   = "Allow traffic from frontend service"
    from_port     = 80
    to_port       = 80
    protocol      = "tcp"
    security_groups = [aws_security_group.ingress_api.id]
  }

  ingress {
    description   = "Allow traffic from inventory service"
    from_port     = 5000
    to_port       = 5000
    protocol      = "tcp"
    security_groups = [aws_security_group.inventory-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
