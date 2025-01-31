output "vm_details" {
  description = "Details for each VM"
  
  value = {
    nat-instance = {
      name      = yandex_compute_instance.nat_instance.name
      hostname  = yandex_compute_instance.nat_instance.hostname
      ip        = yandex_compute_instance.nat_instance.network_interface[0].nat_ip_address
      local_ip  = yandex_compute_instance.nat_instance.network_interface[0].ip_address
    }
    public_vm = {
      name      = yandex_compute_instance.public_vm.name
      hostname  = yandex_compute_instance.public_vm.hostname
      ip        = yandex_compute_instance.public_vm.network_interface[0].nat_ip_address
      local_ip  = yandex_compute_instance.public_vm.network_interface[0].ip_address
    }
    private_vm = {
      name      = yandex_compute_instance.private_vm.name
      hostname  = yandex_compute_instance.private_vm.hostname
      ip        = yandex_compute_instance.private_vm.network_interface[0].nat_ip_address
      local_ip  = yandex_compute_instance.private_vm.network_interface[0].ip_address
    }
  }
}
