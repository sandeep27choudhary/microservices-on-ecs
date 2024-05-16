resource "aws_ecr_repository" "ecr" {
  count = var.counts
  name = var.names[count.index]
}
