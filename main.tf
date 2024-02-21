resource "aws_iam_policy" "auto_start_stop_ec2_policy" {
  name        = "AutoStartStopEC2Policy"
  path        = "/"
  description = "IAM policy for stop and start EC2 from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*",
        "ec2:DescribeInstances*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "auto_start_stop_ec2_role" {
  name               = "AutoStartStopEC2Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role       = aws_iam_role.auto_start_stop_ec2_role.name
  policy_arn = aws_iam_policy.auto_start_stop_ec2_policy.arn
}

resource "aws_lambda_function" "auto_stop_ec2_lambda" {
  filename         = "ec2_lambda_handler.zip"
  function_name    = "autoStopEC2Lambda"
  role             = aws_iam_role.auto_start_stop_ec2_role.arn
  handler          = "ec2_lambda_handler.stop"
  source_code_hash = filebase64sha256("ec2_lambda_handler.zip")
  runtime          = "python3.12"
  memory_size      = "250"
  timeout          = "60"



}


resource "aws_cloudwatch_event_rule" "auto_ec2_stop_rule" {
  name                = "AutoStopEC2Instances"
  description         = "Stop EC2 nodes at 11:30 from Monday to friday"
  schedule_expression = "cron(30 11 ? * 2-6 *)"
}
resource "aws_cloudwatch_event_target" "auto_ec2_stop_rule_target" {
  rule = aws_cloudwatch_event_rule.auto_ec2_stop_rule.name
  arn  = aws_lambda_function.auto_stop_ec2_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.auto_stop_ec2_lambda.function_name}"
  principal     = "events.amazonaws.com"
}

resource "aws_lambda_function" "auto_start_ec2_lambda" {
  filename      = "ec2_lambda_handler.zip"
  function_name = "autoStartEC2Lambda"
  role          = "${aws_iam_role.auto_stop_start_ec2_role.arn}"
  handler       = "ec2_lambda_handler.start"

  source_code_hash = "${filebase64sha256("ec2_lambda_handler.zip")}"

  runtime = "python3.12"
  memory_size = "250"
  timeout = "60"
}

resource "aws_cloudwatch_event_rule" "auto_ec2_start_rule" {
  name        = "StartEC2Instances"
  description = "Start EC2 nodes at 2:30 from Monday to friday"
  schedule_expression = "cron(30 3 ? * 2-6 *)"
}

resource "aws_cloudwatch_event_target" "auto_ec2_start_rule_target" {
  rule      = "${aws_cloudwatch_event_rule.auto_ec2_start_rule.name}"
  arn       = "${aws_lambda_function.auto_start_ec2_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.auto_start_ec2_lambda.function_name}"
  principal     = "events.amazonaws.com"
}
