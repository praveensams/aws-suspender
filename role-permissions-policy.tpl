{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:me-south-1:${AWS}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutRetentionPolicy",
                "logs:PutLogEvents",
                "rds:*"
            ],
            "Resource": [
                "arn:aws:logs:me-south-1:${AWS}:log-group:/aws/lambda/${LAMBDA}:*",
                "arn:aws:rds:*:${AWS}:*"
            ]
        },        
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:GetMetricData",
                "cloudwatch:GetMetricStatistics",
                "logs:PutRetentionPolicy",
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        }
    ]
}
