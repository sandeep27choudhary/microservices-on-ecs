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
