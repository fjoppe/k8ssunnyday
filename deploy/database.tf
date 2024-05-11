# Retrieve the database docker image from ECR
data "aws_ecr_image" "database_image" {
  repository_name = "k8simages"
  image_tag       = "database-latest"
}


# Deploy the database docker image to k8s
resource "kubernetes_deployment" "database" {
  metadata {
    name = "database-ns"
    labels = {
      app = "database"
      group = "backend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "database"
      }      
    }

    template {
      metadata {
        labels = {
          app = "database"
          group = "backend"        
        }
      }

      spec {
        container {
          name = "database"
          image = data.aws_ecr_image.database_image.image_uri
          image_pull_policy = "Always"
          port {
            container_port = 3000
          }
          resources {
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
}


# Expose the database-deployment as a service
resource "kubernetes_service" "database" {
  metadata {
    name = "database"
    labels = {
      app = "database"
      group = "frontend"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.database.metadata.0.labels.app
    }
    port {
      port        = 3000
      target_port = 3000
    }
    type = "ClusterIP"
  }
}
