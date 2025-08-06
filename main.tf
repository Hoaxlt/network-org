resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "public" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
resource "yandex_vpc_subnet" "private" {
  name           = var.subnet_private_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.private_cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_image
}
data "yandex_compute_image" "nat" {
  family = var.nat_image
}


resource "yandex_compute_instance" "test-public" {
  name        = var.vm_test_public_name
  platform_id = var.vm_test_id
  resources {
    cores         = var.vms_resources.test.cores
    memory        = var.vms_resources.test.memory
    core_fraction = var.vms_resources.test.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
    }   
  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
  }    
  
 metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }  
}
resource "yandex_compute_instance" "test-private" {
  name        = var.vm_test_private_name
  platform_id = var.vm_test_id
  resources {
    cores         = var.vms_resources.test.cores
    memory        = var.vms_resources.test.memory
    core_fraction = var.vms_resources.test.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
    }   
  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
  }    
  
 metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }  
}

resource "yandex_compute_instance" "nat-instance" {
  name        = local.vm_nat_name
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    core_fraction = var.vms_resources.nat.core_fraction
    cores         = var.vms_resources.nat.cores
    memory        = var.vms_resources.nat.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat.image_id
  }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    ip_address         = "192.168.10.254"
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }
}

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.develop.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}