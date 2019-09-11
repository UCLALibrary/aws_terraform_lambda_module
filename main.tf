# IAM Trust Policy attach to IAM role
data "aws_iam_policy_document" "lambda-assume-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]
 
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "template_file" "iam_policy_permissions_for_lambda" {
  template = "${file("${path.module}/templates/iam_policy.json.tpl")}"
  vars = {
    s3_list_of_buckets = "${jsonencode(var.s3_iam_allowed_resources)}"
    s3_permissions = "${jsonencode(var.s3_iam_allowed_actions)}"
    cloudwatch_permissions = "${jsonencode(var.cloudwatch_iam_allowed_actions)}"
  }
}

# IAM Role for lambda to assume
resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.app_name}_iam_for_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda-assume-policy-document.json}"
}

# Adding IAM policy to IAM role
resource "aws_iam_role_policy" "iam_policy_for_lambda" {
  name = "${var.app_name}-iam-policy-for-lambda"
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy = "${data.template_file.iam_policy_permissions_for_lambda.rendered}"
}

# Adding VPC access to role
resource "aws_iam_role_policy_attachment" "eni_execute_attachment" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "{var.eni_execute_policy_arn}"
}

# Create converter Lambda function
resource "aws_lambda_function" "app" {
  filename          = "${var.app_artifact}"
  source_code_hash  = "${filebase64sha256("${var.app_artifact}")}"
  function_name     = "${var.app_name}"
  role              = "${aws_iam_role.iam_for_lambda.arn}"
  handler           = "${var.app_handler}"
  runtime           = "${var.app_runtime}"
  memory_size       = "${var.app_memory_size}"
  timeout           = "${var.app_timeout}"
  layers            = "${var.app_layers}"

  vpc_config {
    subnet_ids         = "${var.subnet_ids}"
    security_group_ids = "${var.security_group_ids}"
  }

  environment {
    variables = "${var.app_environment_variables}"
  }
}

# Create CloudWatch log group using the name Lambda expects
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.app.function_name}"
  retention_in_days = 14
}

# Create S3 bucket permission
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.app.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.trigger_s3_bucket_arn}"
}

# Create TIFF bucket notification for converter Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${var.trigger_s3_bucket_id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.app.arn}"
    events              = "${var.bucket_event}"
    filter_suffix       = "${var.app_filter_suffix}"
  }
}

