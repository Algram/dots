variable "target_user" {
  type = string
}

variable "target_host" {
  type = string
}

variable "ssh_private_key_file" {
  type = string
}

module "deploy_nixos" {
  source               = "github.com/tweag/terraform-nixos//deploy_nixos"
  nixos_config         = "${path.module}/configuration.nix"
  target_user          = var.target_user
  target_host          = var.target_host
  ssh_agent            = false
  ssh_private_key_file = var.ssh_private_key_file
  build_on_target      = true
}
