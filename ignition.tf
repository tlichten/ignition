# Configure the Packet Provider
provider "packet" {
  auth_token = "${var.packet_api_key}"
}

# Create a new SSH key
resource "packet_ssh_key" "ignitionkey" {
    name = "ignitionkey"
    public_key = "${file("${var.ssh_private_key}.pub")}"
}

# Create a project
resource "packet_project" "ignition" {
        name = "Ignition"
}

# Create a device and add it to ignition
resource "packet_device" "ignition" {
        hostname = "${var.hostname}"
        plan = "${var.packet_machine_type}"
        facility = "${var.packet_location}"
        operating_system = "centos_7"
        billing_cycle = "hourly"
        project_id = "${packet_project.ignition.id}"

        connection {
          type = "ssh"
          user = "root"
          port = 22
          timeout = "1200"
          private_key = "${file("${var.ssh_private_key}")}"
        }

        # Copies the provison folder to /root/provison
        provisioner "file" {
            source = "env.yaml"
            destination = "/root/env.yaml"
        }

        # Copies the provison folder to /root/provison
        provisioner "file" {
            source = "./provision"
            destination = "/root"
        }

        provisioner "remote-exec" {
          inline = [
            "cd provision && sh launch.sh ${var.fuel_openstack_password}"
          ]
        }
}

output "Fuel" {
    value = "https://${packet_device.ignition.network.0.address}.xip.io:8443"
}

output "Horizon" {
    value = "https://${packet_device.ignition.network.0.address}.xip.io"
}

output "User" {
    value = "admin"
}

output "Password" {
    value = "${var.fuel_openstack_password}"
}
