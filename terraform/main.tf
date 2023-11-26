terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}
resource "kubernetes_namespace" "devops-tools" {
  metadata {
    name = "nginx"
  }
}
resource "kubernetes_deployment" "devops-tools" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.devops-tools.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "devops-tools" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.devops-tools.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.devops-tools.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }
  }
}
