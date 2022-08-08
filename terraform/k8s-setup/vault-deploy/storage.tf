resource "aws_iam_user" "longhorn-backup" {
  name = "${var.environment}-${var.client}-longhorn-backup"
  tags = merge({ Name = "${var.environment}-${var.client}-longhorn-backup" }, local.default_tags)
}
resource "aws_iam_access_key" "longhorn-backup" {
  user = aws_iam_user.longhorn-backup.name
}

resource "aws_s3_bucket" "longhorn-backups" {
  bucket = "${var.environment}-${var.client}-lhbck"
  acl    = "private"
  force_destroy = var.longhorn_backup_s3_destroy
  tags = merge({ Name = "${var.environment}-${var.client}-longhorn-backups" }, local.default_tags)
}

resource "aws_iam_user_policy" "longhorn-backups" {
  name = "${var.environment}-${var.client}-lhbck"
  user = aws_iam_user.longhorn-backup.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GrantLonghornBackupstoreAccess0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.environment}-${var.client}-lhbck",
                "arn:aws:s3:::${var.environment}-${var.client}-lhbck/*"
            ]
        }
    ]
}
EOF
}

resource "kubernetes_namespace" "longhorn-system" {
  metadata {
   name = var.longhorn_namespace
  }
  provider = kubernetes.k8s-gateway
}

resource "kubernetes_secret" "longhorn-s3-credentials" {
  metadata {
    name = "longhorn-s3-credentials"
    namespace = kubernetes_namespace.longhorn-system.metadata[0].name
  }

  data = {
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.longhorn-backup.secret
    AWS_ACCESS_KEY_ID = aws_iam_access_key.longhorn-backup.id
  }

  type = "opaque"
  provider = kubernetes.k8s-gateway
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = var.helm_longhorn_version
  namespace  = kubernetes_namespace.longhorn-system.metadata[0].name
  values     = [templatefile("templates/values-longhorn.yaml.tpl", {
    replica_count = 3
    region = var.region
    secret_name = kubernetes_secret.longhorn-s3-credentials.metadata[0].name
    longhorn_backups_bucket_name = aws_s3_bucket.longhorn-backups.id
    reclaim_policy = "Retain"
  })]
  timeout    = 300
  provider   = helm.helm-gateway
}

resource "kubectl_manifest" "longhorn-backup-crds" {
    yaml_body = templatefile("${path.module}/templates/longhorn-crds.yaml.tpl", {
    })
    override_namespace = kubernetes_namespace.longhorn-system.metadata[0].name
    provider = kubectl.k8s-gateway
    depends_on = [helm_release.longhorn]
}
