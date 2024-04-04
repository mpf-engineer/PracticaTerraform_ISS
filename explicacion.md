# 1. Crea una infraestructura Docker personalizada utilizando Terraform.
# Para este paso creamos un archivo de configuración config.tf que contenga a un proveedor docker:

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# 2. La infraestructura debe contener un contenedor con una aplicación Wordpress y otro contenedor con una base de datos MariaDB.
# Establecemos la configuración básica de wordpress y mariadb.
# - Con resource "docker_image" descargamos la imagen, y gracias a name = "nombre_imagen:latest" obtenemos la más reciente.
# - Con keep_locally = false eliminamos la imagen descargada localmente después de que se hayan creado los contenedores Docker. Esto es útil para ahorrar espacio en disco y mantener el entorno de desarrollo limpio, especialmente si la imagen es grande o si se están utilizando múltiples imágenes diferentes en el mismo entorno.
# - Con resource "docker_container" creamos el contenedor.
# - Y por último, establecemos los puertos.

resource "docker_image" "wordpress" {
  name         = "wordpress:latest"
  keep_locally = false
}

resource "docker_image" "mariadb" {
  name         = "mariadb:latest"
  keep_locally = false
}

resource "docker_container" "wordpress_container" {
  name  = "wordpress_container"
  image = docker_image.wordpress.name

  ports {
    internal = 80
    external = 8000
  }
}

resource "docker_container" "mariadb_container" {
  name  = "mariadb_container"
  image = docker_image.mariadb.name
  ports {
    internal = 3306
    external = 3306
  }
}

# 3. Deben estar conectados a una red Docker.

# - Primero creamos la red:

resource "docker_network" "my_network" {
  name = "my_unique_network" 
}

# - Luego, la agregamos a los diferentes contenedores:

networks_advanced {
  name = docker_network.my_network.id 
}

# 4. Debe existir un volumen para almacenar los datos de la base de datos y que no se Eliminen al destruir la infraestructura.

# - Primero creamos el volumen:

resource "docker_volume" "my_volume" {
  name = "my_volume"
}

# - Luego, agregamos el volumen a los diferentes contenedores:

  volumes {
    volume_name    = docker_volume.my_volume.name
    container_path  = "/var/lib/mysql"
  }

# 5. Deben usarse variables de entorno para configurar la aplicación Wordpress.

# 6. Debe existir un archivo de configuración variables.tf con las variables de entorno.

# - Primero creamos un archivo variables.tf y establecemos las variables para configurar el contenedor wordpress:

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

# - Luego, incluimos los cambios modificando el config.tf:

resource "docker_container" "wordpress_container" {
  name  = var.wordpress_container_name
  image = docker_image.wordpress.name

  ports {
    internal = var.wordpress_internal_port
    external = var.wordpress_external_port
  }
}

# Por último, ejecutamos los comandos, terraform init y terraform apply.