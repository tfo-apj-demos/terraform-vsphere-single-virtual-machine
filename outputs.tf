output "virtual_machine_id" {
  description = "The ID of the virtual machine."
  value       = module.vm.virtual_machine_id
}

output "vsphere_compute_cluster_id" {
  description = "The ID of the vSphere compute cluster where the VM is deployed."
  value       = module.vm.vsphere_compute_cluster_id
}

output "virtual_machine_name" {
  description = "The name of the virtual machine."
  value       = module.vm.virtual_machine_name
}

output "ip_address" {
  description = "The default IP address of the virtual machine."
  value       = module.vm.ip_address
}

output "template_metadata" {
  description = "Metadata about the VM template being used (HCP Packer or fallback)."
  value       = local.cloud_image_metadata
}

output "template_name" {
  description = "The name of the VM template being used."
  value       = local.cloud_image_id
}
