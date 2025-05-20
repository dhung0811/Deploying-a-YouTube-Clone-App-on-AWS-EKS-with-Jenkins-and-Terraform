resource "aws_eks_cluster" "eks-cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.EKSClusterRole.arn
  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [data.aws_security_group.sg-default.id]
  }

  version = 1.28

  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy]
}