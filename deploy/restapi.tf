# Retrieve the restapi docker image from ECR
data "aws_ecr_image" "restapi_image" {
  repository_name = "k8simages"
  image_tag       = "restapi-latest"
}


# Deploy the restapi docker image to k8s
resource "kubernetes_deployment" "restapi" {
  metadata {
    name = "restapi-ns"
    labels = {
      app = "restapi"
      group = "frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "restapi"
      }      
    }

    template {
      metadata {
        labels = {
          app = "restapi"
          group = "frontend"          
        }
      }

      spec {
        container {
          name = "restapi"
          image = data.aws_ecr_image.restapi_image.image_uri
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          env {
            name = "DBENDPOINT"
            value = "http://database:3000"
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


# Expose the restapi-deployment as a service
resource "kubernetes_service" "restapi" {
  metadata {
    name = "restapi"
    labels = {
      app = "restapi"
      group = "frontend"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.restapi.metadata.0.labels.app
    }
    port {
      port        = 8080
      target_port = 8080
    }

    # This must be NodePort for the ALB ingress to connect
    type = "NodePort"
  }
}