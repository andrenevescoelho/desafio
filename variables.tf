variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "elb_port" {
  description = ""
  type        = number
  default     = 80
}

variable "allocated_storage" {
  description = ""
  type = number
  default = 20
}

variable "storage_type" {
  description = ""
  type = string
  default = "gp2"
}

variable "skip_final_snapshot" {
  description = ""
  default = "true"
  type = string
}
