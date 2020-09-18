provider "aws" {
  region      = "us-east-1"
  access_key  = ""
  secret_key  = ""
}

resource "aws_key_pair" "my-key" {
  key_name = "my-key"
  public_key = "${file("/Users/nome_usuario/.ssh/id_rsa.pub")}"
}
