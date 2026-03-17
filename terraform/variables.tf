variable "yc_token" {}
variable "yc_cloud_id" {}
variable "yc_folder_id" {}

variable "yc_network_id" {
  default = "enpih6fh6c3m3v527s73"
}

variable "dns_zone_id" {
  default = "dns4jb8olpl2or21ube9"
}

variable "domain" {
  default = "cheap-domen-for-devops-education.asia"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "certificate_id" {
  description = "Existing certificate in Yandex Certificate Manager"
}

variable "datadog_api_key" {
  sensitive = true
}

variable "datadog_app_key" {
  sensitive = true
}

variable "datadog_api_url" {
  default = "https://api.datadoghq.eu/"
}

variable "focalboard_count" {
  default = 2
}