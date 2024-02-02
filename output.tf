output "us_east_public_ip" {
  value = module.us_east_instances.public_ip
}

output "ap_northeast_public_ip" {
  value = module.ap_northeast_instances.public_ip
}

output "eu_west_public_ip" {
  value = module.eu_west_instances.public_ip
}