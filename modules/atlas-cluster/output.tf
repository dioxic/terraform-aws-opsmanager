output "mongo_uri" {
  value = mongodbatlas_cluster.main.mongo_uri
}

output "srv_address" {
  value = mongodbatlas_cluster.main.srv_address
}

output "cluster_name" {
  value = mongodbatlas_cluster.main.name
}

output "admin_user_name" {
  value = length(mongodbatlas_database_user.root) > 0 ? mongodbatlas_database_user.root[0].username : "N/A"
}

output "admin_user_password" {
  value = length(mongodbatlas_database_user.root) > 0 ? mongodbatlas_database_user.root[0].password : "N/A"
}