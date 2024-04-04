variable "wordpress_container_name" {
  description = "Nombre del contenedor de WordPress"
  type        = string
  default     = "wordpress"
}

variable "wordpress_internal_port" {
  description = "Puerto interno del contenedor de WordPress"
  type        = number
  default     = 80
}

variable "wordpress_external_port" {
  description = "Puerto externo del contenedor de WordPress"
  type        = number
  default     = 8000
}
