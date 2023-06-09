output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-ami-image.id
}

output "ec2_public_ip" {
    value = aws_instance.private-instance.public_ip
}