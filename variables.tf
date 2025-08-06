variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "private_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "vpc_name" {
  type        = string
  default     = "public"
  description = "VPC network & subnet name"
}
variable "subnet_private_name" {
  type        = string
  default     = "private"
  description = "VPC network & subnet name"
}
variable "vm_user" {
  type = string
}

variable "vm_user_nat" {
  type = string
}

variable "ssh_key_path" {
  type = string
}
variable "vm_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "ubuntu-2004 image for vm"
}
variable "nat_image" {
    type = string
    default = "nat-instance-ubuntu"
}

variable "vm_test_public_name" {
  type        = string
  default     = "test-public"
}
variable "vm_test_private_name" {
  type        = string
  default     = "test-private"
}
variable "vm_test_id" {
  type        =  string
  default     = "standard-v1"
  description = "platform id"
}

variable "vms_resources" {
  type      = map
}

variable "vms_metadata" {
  type = map
}