resource "local_file" "ansible_inventory" {

  filename = "../../../ansible/inventory/hosts.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    ollama_private_ip    = module.ollama.instance_id
    openwebui_private_ip = module.openwebui.instance_id
  })
}