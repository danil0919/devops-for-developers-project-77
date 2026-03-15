data "yandex_vpc_network" "existing" {
  network_id = var.yc_network_id
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "devops-education-subnet"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.existing.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

############################################
# POSTGRES VM
############################################

resource "yandex_compute_instance" "postgres" {

  name = "postgres"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

}

############################################
# FOCALBOARD VM 1
############################################

resource "yandex_compute_instance" "focalboard1" {

  name = "focalboard-1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

}

############################################
# FOCALBOARD VM 2
############################################

resource "yandex_compute_instance" "focalboard2" {

  name = "focalboard-2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

}

############################################
# LOAD BALANCER TARGET GROUP
############################################

resource "yandex_lb_target_group" "focalboard" {

  name = "focalboard-group"

  target {
    subnet_id = yandex_vpc_subnet.subnet.id
    address   = yandex_compute_instance.focalboard1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet.id
    address   = yandex_compute_instance.focalboard2.network_interface.0.ip_address
  }

}

############################################
# NETWORK LOAD BALANCER
############################################

resource "yandex_lb_network_load_balancer" "lb" {
  name = "focalboard-lb"

  listener {
    name        = "http"
    port        = 80
    target_port = 8000

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.focalboard.id

    healthcheck {
      name = "http"

      http_options {
        port = 8000
        path = "/"
      }
    }
  }
}

############################################
# DNS
############################################

resource "yandex_dns_recordset" "focalboard" {

  zone_id = var.dns_zone_id
  name    = "${var.domain}."
  type    = "A"
  ttl     = 300

data = [
  one(flatten([
    for listener in yandex_lb_network_load_balancer.lb.listener : [
      for addr in listener.external_address_spec : addr.address
    ]
  ]))
]

}