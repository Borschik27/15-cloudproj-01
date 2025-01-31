### Local vars
locals {
  vpc_name          = "cloud-nat"
  subnet_name1      = "public"
  subnet_name2      = "private"
  sg_nat_name       = "nat-instance-sg"
  vm_test_pub_name  = "public-vm"
  vm_test_priv_name = "private-vm"
  vm_nat_name       = "nat-instance"
  route_table_name  = "nat-instance-route"
  public_cidr       = ["192.168.10.0/24"]
  private_cidr      = ["192.168.20.0/24"]
  image_family      = "ubuntu-24-04-lts"
  nat_image_id      = "fd8lq67qr9o6fhjc64fl"

  local_nat_ipa     = "192.168.10.254"
  local_pub_vm_ipa  = "192.168.10.88"
  local_priv_vm_ipa = "192.168.20.66"
}
### End local vars

### Cloud init for ubunutu 2404
data "template_file" "cloudinit_2404" {
  template = file("${path.module}/templates/cloud-init-2404.yaml.tpl")

  vars = {
    ssh_key          = var.vms_ssh_root_key,
    uname            = var.vm_user,
    ugroup           = var.vm_u_group,
    shell            = var.vm_u_shell,
    s_com            = var.sudo_cloud_init,
    pack             = join("\n  - ", var.pack_list),
    vm_user_password = var.vm_user_password
  }
}
### End cloud init

### Cloud init for ubunutu nat-instance
data "template_file" "cloudinit_nat" {
  template = file("${path.module}/templates/cloud-init-nat.yaml.tpl")

  vars = {
    ssh_key          = var.vms_ssh_root_key,
    uname            = var.vm_user,
    ugroup           = var.vm_u_group,
    shell            = var.vm_u_shell,
    s_com            = var.sudo_cloud_init,
    vm_user_password = var.vm_user_password
  }
}
### End cloud init

### Create VPC
resource "yandex_vpc_network" "cloud_nat" {
  name = local.vpc_name
}
### End VPC

### Create subnet
resource "yandex_vpc_subnet" "public" {
  name           = local.subnet_name1
  zone           = var.default_zone
  network_id     = yandex_vpc_network.cloud_nat.id
  v4_cidr_blocks = local.public_cidr
}

resource "yandex_vpc_subnet" "private" {
  name           = local.subnet_name2
  zone           = var.default_zone
  network_id     = yandex_vpc_network.cloud_nat.id
  v4_cidr_blocks = local.private_cidr
  route_table_id = yandex_vpc_route_table.nat_instance_route.id
}
### End create

### Create security group
resource "yandex_vpc_security_group" "nat_instance_sg" {
  name       = local.sg_nat_name
  network_id = yandex_vpc_network.cloud_nat.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}
### End create security group 

### Set images name
data "yandex_compute_image" "nat_image" {
  image_id = local.nat_image_id
}

data "yandex_compute_image" "vm" {
  family = local.image_family
}
### End images name

### Create nat-instance
resource "yandex_compute_instance" "nat_instance" {
  name        = local.vm_nat_name
  platform_id = var.platform_id
  zone        = var.default_zone
  hostname    = local.vm_nat_name

  metadata = {
    user-data          = data.template_file.cloudinit_nat.rendered
    serial-port-enable = 1
  }

  resources {
    cores         = "2"
    memory        = "2"
    core_fraction = "50"
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat_image.id
      size = "20"
      type = "network-ssd"
    }
  }

  network_interface {
    subnet_id   = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.nat_instance_sg.id]
    nat         = true
    ip_address  = local.local_nat_ipa
  }
}
### End create nat-instace

### Create test VM in PUBLIC-network
resource "yandex_compute_instance" "public_vm" {
  
  name        = local.vm_test_pub_name
  platform_id = var.platform_id
  zone        = var.default_zone
  hostname    = local.vm_test_pub_name

  metadata = {
    user-data          = data.template_file.cloudinit_2404.rendered
    serial-port-enable = 1
  }

  resources {
    cores         = "2"
    memory        = "2"
    core_fraction = "50"
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm.id
      size = "30"
      type = "network-ssd"
    }
}

  network_interface {
    subnet_id   = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.nat_instance_sg.id]
    nat         = false
    ip_address  = local.local_pub_vm_ipa
  }
}
### End create test VM in public-network

### Create test Vm in PRIVATE-network
resource "yandex_compute_instance" "private_vm" {
  
  name        = local.vm_test_priv_name
  platform_id = var.platform_id
  zone        = var.default_zone
  hostname    = local.vm_test_priv_name

  metadata = {
    user-data          = data.template_file.cloudinit_2404.rendered
    serial-port-enable = 1
  }

  resources {
    cores         = "2"
    memory        = "2"
    core_fraction = "50"
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm.id
      size = "30"
      type = "network-ssd"
    }
}

  network_interface {
    subnet_id   = yandex_vpc_subnet.private.id
    security_group_ids = [yandex_vpc_security_group.nat_instance_sg.id]
    nat = false
    ip_address = local.local_priv_vm_ipa
    
  }
}
### End create test VM in PRIVATE-network

## Create route-table/static-route
resource "yandex_vpc_route_table" "nat_instance_route" {
  name       = local.route_table_name
  network_id = yandex_vpc_network.cloud_nat.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance.network_interface.0.ip_address
  }
}
## End create route-table/static-route

### Wait complite cloud-init
resource "null_resource" "wait_for_cloud_init" {
  for_each = {
    nat_instance  = yandex_compute_instance.nat_instance
  }

  provisioner "remote-exec" {
    inline = [
      "while ! cloud-init status --wait >/dev/null; do echo 'Waiting for cloud-init to complete...'; sleep 30; done"
    ]

    connection {
      type     = "ssh"
      host     = each.value.network_interface[0].nat_ip_address
      user     = var.vm_user
      private_key = file(var.vms_ssh_root_key_file) 
    }
  }

  depends_on = [
    yandex_compute_instance.nat_instance,
    yandex_compute_instance.private_vm,
    yandex_compute_instance.public_vm
  ]
}
### End wait

# resource "local_file" "ansible_inventory" {
#   depends_on = [data.template_file.cloudinit]
#   filename = "${path.module}/ansible/inventory/hosts.yaml"
#   content  = templatefile("${path.module}/templates/hosts.yaml.tpl", {
#     vm_details = yandex_compute_instance.vm
#     vm_user    = var.vm_user
#   })
# }

# resource "null_resource" "ansible_apply" {
#   provisioner "local-exec" {
#     command = <<EOT
#       ANSIBLE_CONFIG=ansible/ansible.cfg  ansible-playbook -i ${path.module}/ansible/inventory/hosts.yaml ${path.module}/ansible/playbooks/playbook_roles.yaml
#     EOT

#     environment = {
#       ANSIBLE_HOST_KEY_CHECKING = "false"
#     }
#   }

#   depends_on = [ local_file.ansible_inventory, null_resource.wait_for_cloud_init ]
# }
