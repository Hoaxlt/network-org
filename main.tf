data "template_file" "cloudinit" {
  template = file("./cloud-init.yaml")
  vars = {
    ssh_public_key      = file(var.ssh_key_path)
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

###-------------------------------

resource "yandex_iam_service_account" "buckets_account" {
  name        = var.service_account.bucket_account.name
  description = var.service_account.bucket_account.desc
}

resource "yandex_resourcemanager_folder_iam_member" "buckets-account-role" {
  folder_id = var.folder_id
  role      = var.service_account.bucket_account.role
  member    = "serviceAccount:${yandex_iam_service_account.buckets_account.id}"
}

resource "yandex_iam_service_account_static_access_key" "buckets-account-key" {
  service_account_id = "${yandex_iam_service_account.buckets_account.id}"
  description        = var.sa_key_desc
}

resource "yandex_kms_symmetric_key" "key-a" {
  name              = var.kms_key.key_a.name
  description       = var.kms_key.key_a.desc
  default_algorithm = var.kms_key.key_a.default_algorithm
  rotation_period   = var.kms_key.key_a.rotation_period
}

resource "yandex_storage_bucket" "test" {
  bucket     = var.test_bucket_name
  access_key = "${yandex_iam_service_account_static_access_key.buckets-account-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.buckets-account-key.secret_key}"
  server_side_encryption_configuration {
    rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = yandex_kms_symmetric_key.key-a.id
      sse_algorithm     = "aws:kms"
    }
  }
  }
}
