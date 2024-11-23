output "instance_id" {
  value = aws_instance.default.id
}

output "instance_ip" {
  value = aws_instance.default.private_ip
}
