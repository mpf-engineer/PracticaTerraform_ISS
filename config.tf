terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_network" "my_network" {
  name = "my_unique_network" 
}

resource "docker_image" "wordpress" {
  name         = "wordpress:latest"
  keep_locally = false
}

resource "docker_image" "mariadb" {
  name         = "mariadb:latest"
  keep_locally = false
}

resource "docker_container" "wordpress_container" {
  name  = var.wordpress_container_name
  image = docker_image.wordpress.name

  ports {
    internal = var.wordpress_internal_port
    external = var.wordpress_external_port
  }

  volumes {
    volume_name    = docker_volume.my_volume.name
    container_path = "/var/www/html"
  }
  
  networks_advanced {
    name = docker_network.my_network.id
  }
}

resource "docker_container" "mariadb_container" {
  name  = "mariadb_container" 
  image = docker_image.mariadb.name
  ports {
    internal = 3306
    external = 3306
  }

  volumes {
    volume_name    = docker_volume.my_volume.name
    container_path  = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.my_network.id 
  }
}

resource "docker_volume" "my_volume" {
  name = "my_volume"
}