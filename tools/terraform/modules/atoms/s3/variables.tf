variable "name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket (delete all objects) when destroying the bucket"
  type        = bool
}
