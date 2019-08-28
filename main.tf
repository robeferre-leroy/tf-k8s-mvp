# -----------------------------------------------------------------------------
# Terraform K8s provisioning
# Author: Roberto Ferreira Junior
# Email: roberto.ferreira@leroymerlin.com.br
# -----------------------------------------------------------------------------

terraform {
  backend "gcs" {
      credentials = "~/.config/gcloud/devops-terraform-admin-001.json"
      bucket = "terraform-leroy"
      prefix = "state"
  }
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "devops-terraform-admin-001"
  name                       = "gke-leroy-beta"
  region                     = "us-central1"
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = "k8s"
  subnetwork                 = "cluster"
  ip_range_pods              = "pods"
  ip_range_services          = "services"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  kubernetes_dashboard       = true
  network_policy             = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-2"
      min_count          = 1
      max_count          = 5
      disk_size_gb       = 50
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "terraform@devops-terraform-admin-001.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
