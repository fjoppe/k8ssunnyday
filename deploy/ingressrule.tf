# Retrieve the ingress class for the ALB ingress controller
data "kubernetes_service" "ingress" {
  metadata {
    name = "aws-load-balancer-webhook-service"
    namespace = "eks"
  }
}


# This deploys an ingress rule:
# - A public ALB will be deployed;
# - The ALB will route traffic to our restapi service
resource "kubernetes_ingress_v1" "restapi-ingress-rule" {
  wait_for_load_balancer = true
  metadata {
    name = "restapi"
    annotations = {
       "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "restapi"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
  
  timeouts {
    create = "3m"
    delete = "3m"
  }
}