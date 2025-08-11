data "template_file" "cloudinit" {
  template = file("./cloud-init.yaml")
  vars = {
    ssh_public_key      = file(var.ssh_key_path)
    index = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Моя страница</title>
      </head>
      <body>
          <h1>Добро пожаловать!</h1>
          <img src="https://storage.yandexcloud.net/bigdatabucket/burd.jpg" alt="Моя картинка">
      </body>
      </html>
      EOF
  }
}

resource "yandex_storage_bucket" "big_data_bucket" {
  bucket     = var.bucket_name 
  acl        = var.bucket_acl
  max_size   = var.bucket_size

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
resource "yandex_storage_object" "picture" {
  bucket     = yandex_storage_bucket.big_data_bucket.bucket
  key        = "burd.jpg" 
  source     = "/home/vboxuser/VSC/network-org/task2/birt.jpeg" 
  acl        = var.bucket_acl
}

resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "public" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

data "yandex_compute_image" "lamp" {
  family = "lamp"
}

resource "yandex_compute_instance_group" "lamp" {
  name                = "test-ig"
  service_account_id  = var.service_account
  deletion_protection = false
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = var.lamp_resources.memory
      cores  = var.lamp_resources.cores
      core_fraction = var.lamp_resources.core_fraction
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.lamp.id
        size     = var.lamp_resources.disk_size
      }
    }
    network_interface {
      network_id = yandex_vpc_network.develop.id
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
      nat       = true
    }
    metadata = {
      user-data = data.template_file.cloudinit.rendered
      serial-port-enable = 1
      #ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 3
    max_creating    = 3
    max_expansion   = 3
    max_deleting    = 3
  }
   load_balancer {
    target_group_name = "target-nlb"
  }
  health_check {
    interval = 15
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
    http_options {
      path = "/"
      port = 80
}
}
resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nlb"
  listener {
    name = "nlb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp.load_balancer.0.target_group_id
    healthcheck {
      name = "http"
      interval = 10
      timeout = 5
      healthy_threshold = 5
      unhealthy_threshold = 2
      http_options {
        path = "/"
        port = 80
      }
    }
  }
}