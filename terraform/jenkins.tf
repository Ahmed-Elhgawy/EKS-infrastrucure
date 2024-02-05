# *********************** CREATE NAMESPACE ***********************
resource "kubernetes_namespace" "jenkins" {
  metadata {
    annotations = {
      name = "jenkins"
    }

    labels = {
      terraform = "true"
    }

    name = "jenkins"
  }

  depends_on = [module.eks]
}

# *********************** CREATE JENKINS ADMIN SERVICEACCOUNT ***********************
resource "kubernetes_service_account" "jenkins_admin" {
  metadata {
    name      = "jenkins-admin"
    namespace = "jenkins"
  }

  depends_on = [kubernetes_namespace.jenkins]
}

resource "kubernetes_cluster_role" "jenkins_admin_cr" {
  metadata {
    name = "jenkins-admin-cr"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "secrets", "configmaps", "services", "ingresses"]
    verbs      = ["create", "delete", "get", "list", "patch", "update"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["create", "delete", "get", "list", "patch", "update"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch", "create"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_admin_crb" {
  metadata {
    name = "jenkins-admin-crb"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "jenkins-admin-cr"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "jenkins-admin"
    namespace = "jenkins"
  }
}

# *********************** INSTALL JENKINS USING HELM ***********************
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = "jenkins"

  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_cluster_role_binding.jenkins_admin_crb,
  ]
}
