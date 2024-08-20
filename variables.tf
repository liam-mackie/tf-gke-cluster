variable "cluster_name" {
  description = "cluster name"
}

variable "allowlisted_ips" {
  description = "IPs allowlisted for SSH"
  type        = list(string)
}

variable "node_count" {
  default     = 2
  description = "number of gke nodes"
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}
