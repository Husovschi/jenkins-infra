storage "s3" {
  bucket = "husovschi-vault"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
  tls_disable = 1
}

seal "awskms" {
}

ui            = true
disable_mlock = true
api_addr      = "http://localhost:8200"