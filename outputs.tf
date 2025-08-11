output metadata {
  value = "\n${data.template_file.cloudinit.rendered}"
}
output "ipaddress_group-nlb" {
  value = yandex_compute_instance_group.lamp.instances[*].network_interface[0].ip_address
}