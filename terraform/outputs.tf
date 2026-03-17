output "postgres_ip" {
  value = yandex_compute_instance.postgres.network_interface.0.nat_ip_address
}

output "postgres_private_ip" {
  value = yandex_compute_instance.postgres.network_interface.0.ip_address
}

output "focalboard_ips" {
  value = [
    for vm in yandex_compute_instance.focalboard :
    vm.network_interface[0].nat_ip_address
  ]
}

output "focalboard_private_ips" {
  value = [
    for vm in yandex_compute_instance.focalboard :
    vm.network_interface[0].ip_address
  ]
}
output "load_balancer_ip" {
  value = yandex_vpc_address.alb_ip.external_ipv4_address[0].address
}