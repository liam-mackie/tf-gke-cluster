resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_compute_network" "main" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "private" {
  name                     = "${var.cluster_name}-private"
  region                   = var.region
  network                  = google_compute_network.main.name
  private_ip_google_access = true
  ip_cidr_range            = "10.0.0.0/18"

  secondary_ip_range {
    range_name    = "k8s-pods"
    ip_cidr_range = "10.48.0.0/16"
  }

  secondary_ip_range {
    range_name    = "k8s-services"
    ip_cidr_range = "10.52.0.0/16"
  }
}

resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_address" "nat" {
  name   = "nat"
  region = var.region

  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [
    google_project_service.compute
  ]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowlisted_ips
}
