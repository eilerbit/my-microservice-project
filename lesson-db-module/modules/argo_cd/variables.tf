variable "namespace" {
  type    = string
  default = "argocd"
}

variable "release_name" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = null
}

variable "repo_url" {
  type = string
}

variable "target_revision" {
  type = string
}

variable "chart_path" {
  type = string
}

variable "app_namespace" {
  type = string
}
