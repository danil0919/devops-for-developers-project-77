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
  value = one(flatten([
    for listener in yandex_lb_network_load_balancer.lb.listener : [
      for addr in listener.external_address_spec : addr.address
    ]
  ]))
}