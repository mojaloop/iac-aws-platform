## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.storageClass Global StorageClass for Persistent Volume(s)
##
global:
  imageRegistry: ""
  ## E.g.
  ## imagePullSecrets:
  ##   - myRegistryKeySecretName
  ##
  imagePullSecrets: []
  storageClass: ""

## @section Common parameters

## @param nameOverride String to partially override kafka.fullname
##
nameOverride: ""
## @param fullnameOverride String to fully override kafka.fullname
##
fullnameOverride: "keto"
## @param clusterDomain Default Kubernetes cluster domain
##
clusterDomain: cluster.local
## @param commonLabels Labels to add to all deployed objects
##
commonLabels: {}
## @param commonAnnotations Annotations to add to all deployed objects
##
commonAnnotations: {}
## @param extraDeploy Array of extra objects to deploy with the release
##
extraDeploy: []

## Enable diagnostic mode in the deployment
##
diagnosticMode:
  ## @param diagnosticMode.enabled Enable diagnostic mode (all probes will be disabled and the command will be overridden)
  ##
  enabled: false
  ## @param diagnosticMode.command Command to override all containers in the deployment
  ##
  command:
    - sleep
  ## @param diagnosticMode.args Args to override all containers in the deployment
  ##
  args:
    - infinity

## @section Keto parameters

## Ory Keto image version
## ref: https://k8s.ory.sh/helm/charts
## @param image.registry Kafka image registry
## @param image.repository Keto image repository
## @param image.tag Kafka image tag (immutable tags are recommended)
## @param image.pullPolicy Kafka image pull policy
## @param image.pullSecrets Specify docker-registry secret names as an array
##
# Default values for keto.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
# -- Number of replicas in deployment
replicaCount: 1

image:
  # -- Ory KETO image
  repository: oryd/keto
  # -- Default image pull policy
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  # -- Ory KETO version
  tag: "v0.6.0-alpha.1-sqlite"

imagePullSecrets: []

serviceAccount:
  # -- Specifies whether a service account should be created
  create: true
  # -- Annotations to add to the service account
  annotations: {}
  # -- The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

podAnnotations: {}

podSecurityContext: {}
  # fsGroup: 2000

# https://github.com/kubernetes/kubernetes/issues/57601
automountServiceAccountToken: true

# -- Default security context configuration
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 100
  allowPrivilegeEscalation: false
  privileged: false

job:
  annotations: {}

ingress:
  read:
    enabled: false
    className: ""
    annotations:
      kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    hosts:
      - host: keto.local
        paths:
          - path: /read
            pathType: Prefix
    tls: []
    #  - secretName: keto-tls
    #    hosts:
    #      - keto.local
  write:
    enabled: false
    className: ""
    annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    hosts:
      - host: keto.local
        paths:
          - path: /write
            pathType: Prefix
    tls: []
    #  - secretName: keto-tls
    #    hosts:
    #      - keto.local

service:
  read:
    enabled: true
    type: ClusterIP
    name: http-read
    port: 80
  write:
    enabled: true
    type: ClusterIP
    name: http-write
    port: 80

secret:
  # -- Switch to false to prevent creating the secret
  enabled: true
  # ... and choose a different name for a secret you provide like this
  # nameOverride: "MyOtherName"
  secretAnnotations:
    # Create the secret before installation, and only then. This saves the secret from regenerating during an upgrade
    # pre-upgrade is needed to upgrade from 0.7.0 to newer. Can be deleted afterwards.
      helm.sh/hook-weight: "0"
      helm.sh/hook: "pre-install, pre-upgrade"
      helm.sh/hook-delete-policy: "before-hook-creation"
      helm.sh/resource-policy: "keep"

keto:
  # https://www.ory.sh/keto/docs/reference/configuration
  config:
    dsn: mysql://${keto_db_user}:${keto_db_password}@tcp(${keto_db_host}:3306)/${keto_db_database}?max_conns=20&max_idle_conns=4
    serve:
      read:
        port: 4466
      write:
        port: 4467
    namespaces:
      - id: 0
        name: role
      - id: 1
        name: permission
      - id: 2
        name: participant

  autoMigrate: true

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

nodeSelector: {}

extraEnv: []

extraVolumes: []
# - name: my-volume
#   secret:
#     secretName: my-secret

extraVolumeMounts: []
# - name: my-volume
#   mountPath: /etc/secrets/my-secret
#   readOnly: true

# -- Configuration for tracing providers. Only datadog is currently supported through this block.
# If you need to use a different tracing provider, please manually set the configuration values
# via "keto.config" or via "extraEnv".
tracing:
  datadog:
    enabled: false

    # Sets the datadog DD_ENV environment variable. This value indicates the environment where keto is running.
    # Default value: "none".
    # env: production

    # Sets the datadog DD_VERSION environment variable. This value indicates the version that keto is running.
    # Default value: .Chart.AppVersion (i.e. the tag used for the docker image).
    # version: X.Y.Z

    # Sets the datadog DD_SERVICE environment variable. This value indicates the name of the service running.
    # Default value: "ory/keto".
    # service: ory/keto

    # Sets the datadog DD_AGENT_HOST environment variable. This value indicates the host address of the datadog agent.
    # If set to true, this configuration will automatically set DD_AGENT_HOST to the field "status.hostIP" of the pod.
    # Default value: false.
    # useHostIP: true

tolerations: []

affinity: {}

# -- Configure the probes for when the deployment is considered ready and ongoing health check
deployment:
  livenessProbe:
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 5
  readinessProbe:
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 5

# -- Watcher sidecar configuration
watcher:
  enabled: false
  image: oryd/k8s-toolbox:0.0.2
  mountFile: ''
  # mountFile: /etc/secrets/my-secret/foo

# -- PodDistributionBudget configuration
pdb:
  enabled: false
  spec:
    minAvailable: 1