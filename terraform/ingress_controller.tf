# *********************** CREATE NAMESPACE ***********************
resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    annotations = {
      name = "ingress-nginx"
    }

    labels = {
      terraform = "true"
    }

    name = "ingress-nginx"
  }

  depends_on = [module.eks]
}

# *********************** INSTALL INGRESS NGINX CONTROLLER USING HELM ***********************
resource "helm_release" "ingress-nginx-controller" {
  name       = "ingress-nginx-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  depends_on = [kubernetes_namespace.ingress-nginx]
}
