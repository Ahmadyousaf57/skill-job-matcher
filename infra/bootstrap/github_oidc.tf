data "aws_region" "current" {}

locals {
  github_repo  = "Ahmadyousaf57/skill-job-matcher"
  cluster_name = "skill-job-matcher-eks"
  account_id   = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.region
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.github_repo}:ref:refs/heads/main",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "skill-job-matcher-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

data "aws_iam_policy_document" "github_permissions" {
  statement {
    sid       = "EcrLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPush"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
    ]
    resources = ["arn:aws:ecr:${local.region}:${local.account_id}:repository/skill-job-matcher/*"]
  }

  statement {
    sid       = "EksKubeconfig"
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:aws:eks:${local.region}:${local.account_id}:cluster/${local.cluster_name}"]
  }

  statement {
    sid       = "RdsEndpoint"
    actions   = ["rds:DescribeDBInstances"]
    resources = ["arn:aws:rds:${local.region}:${local.account_id}:db:skill-job-matcher-db"]
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "skill-job-matcher-pipeline"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_permissions.json
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
