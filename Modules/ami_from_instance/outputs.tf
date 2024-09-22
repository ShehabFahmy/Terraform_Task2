output "ami-id" {
  value = aws_ami_from_instance.nginx-ami.id
}
