data "rafay_download_kubeconfig" "kubeconfig_cluster" {
  cluster = var.cluster_name
}

output "kubeconfig" {
  value = yamldecode(data.rafay_download_kubeconfig.kubeconfig_cluster.kubeconfig)
}

output "kubectl_cmd" {
  value = "kubectl -n ${local.uniquename} port-forward svc/web-app-service 8080:80" 
}