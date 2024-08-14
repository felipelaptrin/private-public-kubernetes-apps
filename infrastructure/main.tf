resource "vultr_kubernetes" "this" {
    region  = "mia" # Miami
    label   = "terraform"
    version = "v1.30.0+1"

    node_pools {
        node_quantity = 1
        plan          = "vc2-2c-4gb"
        label         = "vke-nodepool"
        auto_scaler   = false
    }
}

output "cluster_id" {
  description = "ID of Kubernetes cluster"
  value       = vultr_kubernetes.this.id
}