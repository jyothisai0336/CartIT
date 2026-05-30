resource "aws_kms_key" "eks" { description = "CartIt EKS ${var.env}"; enable_key_rotation = true; tags = var.tags }
resource "aws_kms_alias" "eks" { name = "alias/${var.project}-${var.env}-eks"; target_key_id = aws_kms_key.eks.key_id }
resource "aws_cloudwatch_log_group" "eks" { name = "/aws/eks/${var.project}-${var.env}/cluster"; retention_in_days = 30 }
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project}-${var.env}-eks-cluster-role"
  assume_role_policy = jsonencode({ Version="2012-10-17"; Statement=[{ Effect="Allow"; Principal={ Service="eks.amazonaws.com" }; Action="sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" { role = aws_iam_role.eks_cluster.name; policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" }
resource "aws_security_group" "eks_cluster" {
  name   = "${var.project}-${var.env}-eks-cluster-sg"; vpc_id = var.vpc_id
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
  tags   = merge(var.tags, { Name="${var.project}-${var.env}-eks-cluster-sg" })
}
resource "aws_eks_cluster" "main" {
  name     = "${var.project}-${var.env}"; role_arn = aws_iam_role.eks_cluster.arn; version = var.kubernetes_version
  vpc_config { subnet_ids = var.private_subnet_ids; endpoint_private_access = true; endpoint_public_access = var.env=="prod"?false:true; security_group_ids = [aws_security_group.eks_cluster.id] }
  encryption_config { provider { key_arn = aws_kms_key.eks.arn }; resources = ["secrets"] }
  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy, aws_cloudwatch_log_group.eks]
  tags = merge(var.tags, { Name="${var.project}-${var.env}-eks" })
}
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project}-${var.env}-eks-node-role"
  assume_role_policy = jsonencode({ Version="2012-10-17"; Statement=[{ Effect="Allow"; Principal={ Service="ec2.amazonaws.com" }; Action="sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "eks_worker_node" { role=aws_iam_role.eks_nodes.name; policy_arn="arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" }
resource "aws_iam_role_policy_attachment" "eks_cni"         { role=aws_iam_role.eks_nodes.name; policy_arn="arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" }
resource "aws_iam_role_policy_attachment" "ecr_read"        { role=aws_iam_role.eks_nodes.name; policy_arn="arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" }
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.project}-${var.env}-node-"
  metadata_options { http_endpoint="enabled"; http_tokens="required"; http_put_response_hop_limit=1 }
  block_device_mappings { device_name="/dev/xvda"; ebs { volume_size=50; volume_type="gp3"; encrypted=true; kms_key_id=aws_kms_key.eks.arn; delete_on_termination=true } }
}
resource "aws_eks_node_group" "app" {
  cluster_name = aws_eks_cluster.main.name; node_group_name = "${var.project}-${var.env}-app"; node_role_arn = aws_iam_role.eks_nodes.arn
  subnet_ids = var.private_subnet_ids; instance_types = var.node_instance_types; capacity_type = "ON_DEMAND"
  scaling_config { desired_size=var.node_desired; min_size=var.node_min; max_size=var.node_max }
  update_config { max_unavailable=1 }
  launch_template { id=aws_launch_template.eks_nodes.id; version=aws_launch_template.eks_nodes.latest_version }
  depends_on = [aws_iam_role_policy_attachment.eks_worker_node, aws_iam_role_policy_attachment.eks_cni, aws_iam_role_policy_attachment.ecr_read]
  tags = var.tags
}
resource "aws_eks_addon" "vpc_cni"    { cluster_name=aws_eks_cluster.main.name; addon_name="vpc-cni" }
resource "aws_eks_addon" "coredns"    { cluster_name=aws_eks_cluster.main.name; addon_name="coredns" }
resource "aws_eks_addon" "kube_proxy" { cluster_name=aws_eks_cluster.main.name; addon_name="kube-proxy" }
resource "aws_eks_addon" "ebs_csi"    { cluster_name=aws_eks_cluster.main.name; addon_name="aws-ebs-csi-driver" }
