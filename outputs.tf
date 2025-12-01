output "ec2_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = module.ec2.instance_public_ip
}

output "s3_bucket_name" {
  description = "Nom du bucket S3"
  value       = module.ec2.bucket_name
}

output "ssh_command" {
  description = "Commande pour se connecter en SSH"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${module.ec2.instance_public_ip}"
}

output "ec2_instance2_public_ip" {
  description = "IP publique de la deuxième instance EC2"
  value       = module.ec2.instance2_public_ip
}