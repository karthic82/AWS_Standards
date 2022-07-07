# Region restriction to use standard Region
resource "aws_iam_policy" "policy" {
  name        = "Permission_Boundry_policy"
  description = "HT Permission_Boundry policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "*",
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          StringNotEquals= {
            "aws:RequestedRegion"= [
              "eu-central-1",
              "us-east-1"
            ]
          }
        }
      },
    ]
  })
}

# Lambda to Encrypt S3 bucket

resource "aws_lambda_function" "s3_lambda" {
  filename      = "S3_encryption.zip"
  function_name = "S3_auto_Encryption"
  role          = var.role_arn
  handler       = "index.test"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("S3_encryption.zip")

  runtime = "python3.8"

}

# Event Bridge for Lambda Trigger

resource "aws_cloudwatch_event_rule" "console" {
  name        = "capture-s3-bucket-creation"
  description = "Capture each s3 bucket creation"

  event_pattern = <<EOF
  {
    "source": [
      "aws.s3"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "s3.amazonaws.com"
      ],
      "eventName": [
        "CreateBucket"
      ]
    }
  }
EOF
}


resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.console.name
  arn       = aws_lambda_function.s3_lambda.arn
}


# Billing budgest Notification
resource "aws_budgets_budget" "alert_notification" {
  name              = "budget-monthly"
  budget_type       = "COST"
  limit_amount      = "1000"
  limit_unit        = "USD"
  time_period_start = "2022-06-12_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 75
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["smartharimon@gmail.com"]
  }
}