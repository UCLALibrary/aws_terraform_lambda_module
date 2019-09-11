variable "app_environment_variables" {
  type     = "map"
  default  = {
    hello  = "world"
    hello2 = "world2"
  }
}

variable "app_artifact" {}

variable "app_name" {}

variable "app_layers" {}

variable "app_handler" {
  default = "com.example"
}

variable "app_filter_suffix" {}

variable "app_runtime" {}

variable "app_memory_size" {
  default = "1024"
}

variable "app_timeout" {
  default = "600"
}

variable "bucket_event" {}

variable "cloudwatch_iam_allowed_actions" {
  default = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
}

variable "s3_iam_allowed_actions" {
  default = ["s3:*"]
}

variable "s3_iam_allowed_resources" {
  default = ["arn:aws:s3:::bucketname"]
}

variable "trigger_s3_bucket_arn" {}
variable "trigger_s3_bucket_id" {}

variable "subnet_ids" { default = "" }
variable "security_group_ids" { default = "" }

