output "postgres_ip" {
  value = yandex_compute_instance.postgres.network_interface.0.nat_ip_address
}

output "postgres_private_ip" {
  value = yandex_compute_instance.postgres.network_interface.0.ip_address
}

output "focalboard1_ip" {
  value = yandex_compute_instance.focalboard1.network_interface.0.nat_ip_address
}

output "focalboard1_private_ip" {
  value = yandex_compute_instance.focalboard1.network_interface.0.ip_address
}

output "focalboard2_ip" {
  value = yandex_compute_instance.focalboard2.network_interface.0.nat_ip_address
}

output "focalboard2_private_ip" {
  value = yandex_compute_instance.focalboard2.network_interface.0.ip_address
}

output "load_balancer_ip" {
  value = yandex_vpc_address.alb_ip.external_ipv4_address[0].address
}