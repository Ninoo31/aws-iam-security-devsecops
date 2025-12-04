output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "aws_cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.vpc_flow_logs.arn
}