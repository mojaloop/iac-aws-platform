##
## The following is the sample format to install custom reporting templates from a third-party helm repository.
##
# resource "helm_release" "sample-release-name" {
#   name       = "sample-release-name"
#   repository = "<helm-repo-url-which-contains-reporting-templates>"
#   chart      = "<helm-chart-name>"
#   version    = "<helm-chart-version>"
#   namespace  = "mojaloop"
#   timeout    = 300
#   skip_crds  = true
#   repository_username = "<username-to-access-helm-repo-if-private>"
#   repository_password = "<password-to-access-helm-repo-if-private>"
#   provider = helm.helm-gateway
# }