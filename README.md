

## Vorbereitungen
- `Terraform` und `Azure CLI` installieren
- `terraform.ftvars` in der ensprechenden Umgebung erstellen und die Variablen setzen (siehe `terraform.ftvars.example`)


## Dokumentation
- For Schleifen: https://developer.hashicorp.com/terraform/language/expressions/for
- For Each: https://developer.hashicorp.com/terraform/language/meta-arguments/for_each


export TF_VAR_admin_password="<passwort>"

echo $TF_VAR_admin_password