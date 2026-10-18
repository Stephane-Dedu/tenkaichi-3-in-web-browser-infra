# Partial configuration: the bucket and prefix are in backend.hcl (gitignored, see backend.hcl.example).
terraform {
  backend "gcs" {}
}
