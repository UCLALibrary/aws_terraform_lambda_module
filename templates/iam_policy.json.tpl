{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ${cloudwatch_permissions},
            "Resource": ["arn:aws:logs:*:*:*"]
        },
        {
            "Effect": "Allow",
            "Action": ${s3_permissions},
            "Resource": ${s3_list_of_buckets}
        }
    ]
}

