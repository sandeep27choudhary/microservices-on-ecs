
# Security group for the inventory service
resource "aws_security_group" "inventory_sg" {
  name        = "inventory-sg"
  description = "Security group for the inventory service"
  vpc_id      = var.vpc_id

  # Inbound rule to allow traffic from the backend service
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description   = "Allow traffic from backend service"
    from_port     = 3000
    to_port       = 3000
    protocol      = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
