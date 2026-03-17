resource "yandex_vpc_subnet" "subnet" {
  name           = "devops-education-subnet"
  zone           = "ru-central1-a"
  network_id     = var.yc_network_id
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
# FOCALBOARD VM
############################################

resource "yandex_compute_instance" "focalboard" {
  count = var.focalboard_count

  name = "focalboard-${count.index + 1}"

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

resource "yandex_vpc_address" "alb_ip" {
  name = "focalboard-alb-ip"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_alb_target_group" "focalboard" {
  name = "focalboard-alb-tg"

  dynamic "target" {
    for_each = yandex_compute_instance.focalboard

    content {
      subnet_id  = yandex_vpc_subnet.subnet.id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "focalboard" {
  name = "focalboard-backend-group"

  http_backend {
    name             = "focalboard-http-backend"
    port             = 8000
    target_group_ids = [yandex_alb_target_group.focalboard.id]
    weight           = 1

    load_balancing_config {
      panic_threshold = 50
    }

    healthcheck {
      timeout          = "5s"
      interval         = "10s"
      healthcheck_port = 8000

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "focalboard" {
  name = "focalboard-router"
}


resource "yandex_alb_virtual_host" "focalboard" {
  name           = "focalboard-vhost"
  http_router_id = yandex_alb_http_router.focalboard.id
  authority      = [var.domain]

  route {
    name = "focalboard-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.focalboard.id
        timeout          = "60s"
      }
    }
  }
}


resource "yandex_alb_load_balancer" "focalboard" {
  name       = "focalboard-alb"
  network_id = var.yc_network_id

        depends_on = [
    yandex_alb_backend_group.focalboard
  ]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet.id
    }
  }

  listener {
    name = "http"

    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.alb_ip.external_ipv4_address[0].address
        }
      }

      ports = [80]
    }

    http {
      redirects {
        http_to_https = true
      }
    }
  }

    listener {
    name = "https"

    endpoint {
        address {
        external_ipv4_address {
            address = yandex_vpc_address.alb_ip.external_ipv4_address[0].address
        }
        }

        ports = [443]
    }

    tls {
        default_handler {
        certificate_ids = [var.certificate_id]

        http_handler {
            http_router_id = yandex_alb_http_router.focalboard.id
        }
        }
    }
    }
}


resource "yandex_dns_recordset" "focalboard" {
  zone_id = var.dns_zone_id
  name    = "${var.domain}."
  type    = "A"
  ttl     = 300

  data = [
    yandex_vpc_address.alb_ip.external_ipv4_address[0].address
  ]
}