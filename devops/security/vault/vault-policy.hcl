path "secret/data/cartit/*" { capabilities = ["read","list"] }
path "database/creds/cartit-readonly"  { capabilities = ["read"] }
path "database/creds/cartit-readwrite" { capabilities = ["read"] }
path "sys/renew/*" { capabilities = ["update"] }
