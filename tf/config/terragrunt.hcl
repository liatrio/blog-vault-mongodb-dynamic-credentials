include {
  path = "${find_in_parent_folders()}"
}


dependency "k8s" {
  config_path = "../infra"
  skip_outputs = true
}

// inputs = {
//   vault_root_token  = dependency.infra.outputs.vault_root_token
// }
