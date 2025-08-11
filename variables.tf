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
variable "bucket_name" {
  type        = string
  default     = "bigdatabucket"
}
variable "bucket_acl" {
  type        = string
  default     = "public-read"
}
variable "bucket_size" {
  type        = number
  default     = 524288
}
variable "ssh_key_path" {
    type      = string
}


variable "default_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "vpc_name" {
  type        = string
  default     = "public"
  description = "VPC network & subnet name"
}
variable "lamp_image" {
  type = string
  default = "fd827b91d99psvq5fjit"
}
variable "lamp_resources" {
  type = map(any)
}
variable "service_account" {
  type = string
}