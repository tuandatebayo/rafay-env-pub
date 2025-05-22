provider "rafay" {
  # Configuration options
}

resource "random_id" "rnd" {
  keepers = {
    first = "${timestamp()}"
  }
  byte_length = 4
}

locals {
  uniquename = "em-gs-web-app-${random_id.rnd.hex}"
}

resource "local_file" "workload_spec" {
  content = templatefile("${path.module}/templates/application-spec.tftpl", {
    input_name = var.input_name
  })
  filename        = "app-spec.yaml"
  file_permission = "0666"
}

resource "rafay_namespace" "namespace" {
  metadata {
    name    = local.uniquename
    project = var.project
  }
  spec {
    drift {
      enabled = true
    }
    placement {
      labels {
        key   = "rafay.dev/clusterName"
        value = var.cluster_name
      }
    }
  }
}

resource "rafay_workload" "workload" {
  depends_on = [rafay_namespace.namespace, local_file.workload_spec]
  metadata {
    name    = local.uniquename
    project = var.project
  }
  spec {
    namespace = local.uniquename
    placement {
      selector = "rafay.dev/clusterName=${var.cluster_name}"
    }
    version = "v1"
    artifact {
      type = "Yaml"
      artifact {
        paths {
          name = "file://app-spec.yaml"
        }
      }
    }
  }
}