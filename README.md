

## Vorbereitungen
- `Terraform` und `Azure CLI` installieren
- `terraform.ftvars` in der ensprechenden Umgebung erstellen und die Variablen setzen (siehe `terraform.ftvars.example`)


## Dokumentation
- For Schleifen: https://developer.hashicorp.com/terraform/language/expressions/for
- For Each: https://developer.hashicorp.com/terraform/language/meta-arguments/for_each


## Azure VPN Gateway konfigurieren (Point-to-Side VPN)
-> https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-certificates-linux-openssl

- Ordner `certs` in der entsprechenden Umgebung anlegen
- Root Key erstellen: `openssl genrsa -out PoCrootCA.key 4096`
- Root Zertifikat erstellen: `openssl req -x509 -new -nodes -key PoCrootCA.key -sha256 -days 3650 -subj "/CN=PoCRootCA" -out PoCrootCA.pem`
- Client Key erstellen: `openssl genrsa -out PoCclient.key 2048`
- Client CSR (Certificate Signing Request) Datei erstellen: `openssl req -new -key PoCclient.key -subj "/CN=PoCVpnClient" -out PoCclient.csr`
- Client CSR mit Root Zertifikat signieren: `openssl x509 -req -in PoCclient.csr -CA PoCrootCA.pem -CAkey PoCrootCA.key -CAcreateserial -out PoCclient.crt -days 365 -sha256`





# Sign client CSR with root


# Create PFX for client import (password-protect)
openssl pkcs12 -export -out client.pfx -inkey client.key -in client.crt -certfile rootCA.pem -passout pass:YourPfxPassword

# Export root cert in DER base64 form if needed by Terraform (one-liner)
# DER (binary) base64, single-line (Azure generally accepts the PEM as well but some methods require base64 DER)
openssl x509 -in rootCA.pem -outform der | base64 -w 0 > rootCA.der.base64

# Alternatively keep rootCA.pem and use file() in Terraform





Root-CA erstellen: `openssl req -x509 -nodes -newkey rsa:2048 -keyout rootCA.key -out rootCA.pem -subj "/CN=PoCRootCA" -days 3650`
Client-Zertifikat erstellen: `openssl req -new -nodes -newkey rsa:2048 -keyout client.key -out client.csr -subj "/CN=PoCClient"`
Client-CSR mit der Root-CA signieren: `openssl x509 -req -in client.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out client.crt -days 365`

-> poc

grep -v '^-' rootCA.pem | tr -d '\n' | pbcopy