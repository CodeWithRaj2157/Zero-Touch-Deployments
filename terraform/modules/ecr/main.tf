resource "aws_ecr_repository" "app" {

  name = "infra-as-code-pipeline-${var.environment}"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "infra-as-code-pipeline-${var.environment}"
  }
}


resource "aws_ecr_lifecycle_policy" "policy" {

  repository = aws_ecr_repository.app.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1

        description = "Keep last 10 images"

        selection = {

          tagStatus = "any"

          countType = "imageCountMoreThan"

          countNumber = 10

        }

        action = {

          type = "expire"

        }

      }

    ]

  })

}



