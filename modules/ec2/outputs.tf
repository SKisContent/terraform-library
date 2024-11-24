output "instance_id" {
  value = aws_instance.instance.id
}

output "instance_ip" {
  value = aws_instance.instance.private_ip
}
