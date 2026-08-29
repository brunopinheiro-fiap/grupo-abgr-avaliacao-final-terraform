# ROOT VARS: DEFAULT VALUES

variable "key_name" {
  type        = string
  default     = "vockey"
  description = "Key pair EC2 para acesso SSH (usado no laboratório local). Deixe vazio (\"\") em CI para não exigir chave."
}

variable "name_prefix" {
  type        = string
  default     = "dynamicsite-lb"
  description = "Prefixo de nomes dos recursos. Vem do CI via TF_VAR_name_prefix."
}
