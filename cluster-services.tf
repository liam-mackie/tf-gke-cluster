resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn"
  }
}

resource "helm_release" "longhorn" {
  name          = "longhorn"
  repository    = "https://charts.longhorn.io"
  chart         = "longhorn"
  namespace     = kubernetes_namespace.longhorn.metadata[0].name
  force_update  = true
  recreate_pods = true
  reuse_values  = true

  values = [
    "${file("values/longhorn.yaml")}"
  ]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name          = "ingress-nginx"
  repository    = "https://kubernetes.github.io/ingress-nginx"
  chart         = "ingress-nginx"
  namespace     = kubernetes_namespace.ingress_nginx.metadata[0].name
  force_update  = true
  recreate_pods = true
  reuse_values  = true

  values = [
    "${file("values/nginx.yaml")}"
  ]
}

data "kubernetes_service" "nginx_ingress_controller" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    name      = "${helm_release.ingress_nginx.metadata[0].name}-controller"
    namespace = helm_release.ingress_nginx.metadata[0].namespace
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name          = "cert-manager"
  repository    = "https://charts.jetstack.io"
  chart         = "cert-manager"
  namespace     = kubernetes_namespace.cert_manager.metadata[0].name
  force_update  = true
  recreate_pods = true
  reuse_values  = true

  values = [
    "${file("values/cert-manager.yaml")}"
  ]
}
