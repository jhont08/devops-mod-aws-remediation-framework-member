# Member remediator, used for polling and for the remediator
resource "aws_iam_role" "member_remediator" {
  name = "member-remediator"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
	    "AWS": ["arn:aws:iam::${var.master}:role/remediator", "arn:aws:iam::${var.master}:role/poller"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    var.tags,
    {
      app    = "remediator"
      team   = "devops-security"
      system = "aws-remediation"
    },
  )
}


data "aws_iam_policy_document" "member_remediator_policy_document" {
  statement {
    actions = [
      # Actions required for the poller
      "elb:DescribeLoadBalancers",
      "iam:ListUsers",
      "rds:DescribeDbInstances",
      "rds:DescribeDbSnapshots",
      "redshift:DescribeClusters",
      "s3:ListAllMyBuckets",
      "sqs:ListQueues",

      # SQS
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",

      # EBS Snapshot
      "ec2:ModifySnapshotAttribute",

      # AMI
      "ec2:ModifyImageAttribute",

      # IAM user MFA
      "iam:GetUser",
      "iam:GetLoginProfile",
      "iam:ListMfaDevices",
      "iam:DeleteLoginProfile",
      "iam:ListAccessKeys",
      "iam:GetAccessKeyLastUsed",
      "iam:DeleteAccessKey",

      # IAM roles
      "iam:ListRoles",
      "iam:GetRole",
      "iam:UpdateAssumeRolePolicy",

      # RDS no encryption or public
      "rds:DescribeDbInstances",
      "rds:StopDbCluster",
      "rds:StopDbInstance",
      "rds:ModifyDbInstance",
      # RDS has required tags
      "rds:ListTagsForResource",

      # RDS Snapshot
      "rds:DescribeDbSnapshotAttributes",
      "rds:ModifyDbSnapshotAttribute",

      # S3 Bucket
      "s3:DeleteBucketPolicy",
      "s3:GetBucket*",
      "s3:PutBucketAcl",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:PutBucketPublicAccessBlock",

      # Redshift
      "redshift:DescribeClusters",
      "redshift:ModifyCluster",
      "redshift:DescribeClusterParameters",

      # Region checks
      "guardduty:ListDetectors",
      "guardduty:GetMasterAccount",
      "config:DescribeDeliveryChannels",
      "cloudtrail:DescribeTrails",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",

      # EC2
      "ec2:CreateTags",
      "ec2:Describe*",
      "ec2:DisassociateAddress",
      "ec2:ModifyInstanceMetadataOptions",
      "ec2:TerminateInstances",

      # Security Group
      "ec2:RevokeSecurityGroupIngress",

      # ELB
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DeregisterTargets",

      # Lambda
      "lambda:ListFunctions",
      "lambda:GetPolicy",
      "lambda:RemovePermission",

      # organizations
      "organizations:ListAccounts"
    ]
    resources = [
      "*",
    ]
  }
}

# Create the policy for the role
resource "aws_iam_policy" "member_remediator" {
  name   = "${var.tags.stack}-member-remediator"
  path   = "/"
  policy = data.aws_iam_policy_document.member_remediator_policy_document.json
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "member_remediator" {
  role       = aws_iam_role.member_remediator.name
  policy_arn = aws_iam_policy.member_remediator.arn
}

#role for allowing event forward to bus
resource "aws_iam_role" "event_forward" {
  name = "${var.tags.stack}-event-forward"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    var.tags,
    {
      app    = "remediator"
      team   = "devops-security"
      system = "aws-remediation"
    },
  )
}

resource "aws_iam_role_policy" "event_bus_policy" {
  name = "${var.tags.stack}-event-bus-policy"
  role = aws_iam_role.event_forward.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "events:PutEvents"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:events:*:${var.master}:event-bus/default"
          ]
      }
    ]
  }
  EOF
}
