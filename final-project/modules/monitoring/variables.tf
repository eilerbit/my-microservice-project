variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "release_name" {
  type    = string
  default = "monitoring"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "chart_version" {
  type    = string
  default = "0.0.0"
}