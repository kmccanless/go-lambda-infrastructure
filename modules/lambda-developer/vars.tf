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
variable "timeout" {}
variable "enable_api_gw" {
    type = bool
    default = false
}
variable "enable_dynamo" {
    type = object({
        name    =  string
        hash_key    = string
        read_capacity  = number 
        write_capacity = number
        attribute   = object({
            name = string
            type = string
        })
    })
    default = null

}