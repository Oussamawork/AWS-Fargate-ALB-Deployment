resource "null_resource" "build_and_push_backend_a" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "docker logout ${module.ecr_repo_backend_b.ecr_repo_url} || true && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${module.ecr_repo_backend_b.ecr_repo_url}"
  }

  provisioner "local-exec" {
    command = "docker build --platform linux/arm64 --no-cache -t ${module.ecr_repo_backend_a.ecr_repo_url}:latest -f ./services/backend_a/dockerfile ."
  }

  provisioner "local-exec" {
    command = "docker push ${module.ecr_repo_backend_a.ecr_repo_url}:latest"
  }

  depends_on = [module.ecr_repo_backend_a]
}

resource "null_resource" "build_and_push_backend_b" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "docker logout ${module.ecr_repo_backend_b.ecr_repo_url} || true && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${module.ecr_repo_backend_b.ecr_repo_url}"
  }

  provisioner "local-exec" {
    command = "docker build --platform linux/arm64 --no-cache -t ${module.ecr_repo_backend_b.ecr_repo_url}:latest -f ./services/backend_b/dockerfile ."
  }

  provisioner "local-exec" {
    command = "docker push ${module.ecr_repo_backend_b.ecr_repo_url}:latest"
  }

  depends_on = [module.ecr_repo_backend_b]
}
