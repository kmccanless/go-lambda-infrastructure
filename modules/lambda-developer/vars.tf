variable "s3_key" {}
variable "function_name" {}
variable "source_archive" {}
variable "function_handler" {}
variable "runtime" {}
variable "archive_md5" {}
variable "archive_name" {}
variable "environment" {}
variable "region" {}
variable "profile" {}
variable "project" {}
variable "archive_sha256" {}
variable "en_vars" {
    type = object
    default = {}
}
variable "timeout" {}