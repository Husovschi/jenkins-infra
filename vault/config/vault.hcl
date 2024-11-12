storage "s3" {
  bucket              = "husovschi-vault"
  region              = "pl-waw"
  endpoint            = "s3.pl-waw.scw.cloud"
  s3_force_path_style = true
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
  tls_disable = 1
}

ui            = true
disable_mlock = true
api_addr      = "http://localhost:8200"