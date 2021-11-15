variable "bizops_mojaloop_roles" {
  description = "bizops mojaloop roles list"
  type = list(object({
    rolename  = string
    permissions     = list(string)
  }))
  default = []
}
variable "project_root_path" {
  description = "Root path for IaC project"
}