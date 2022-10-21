## Overriding the image to older one because of some schema changes not compatible with kratios UI implemented
## This can be reverted when we upgrade the kratos-ui according to the new schema
image:
  repository: oryd/kratos
  tag: v0.5.5-alpha.1
# -- Number of replicas in deployment
replicaCount: 1
# -- Deployment update strategy
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 30%
    maxUnavailable: 0

fullnameOverride: "kratos"

service:
  admin:
    enabled: true
    type: ClusterIP
    port: 80
    # -- The service port name. Useful to set a custom service port name if it must follow a scheme (e.g. Istio)
    name: http
    # -- Provide custom labels. Use the same syntax as for annotations.
    labels: {}
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    annotations:
      kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  public:
    enabled: true
    type: ClusterIP
    port: 80
    # -- The service port name. Useful to set a custom service port name if it must follow a scheme (e.g. Istio)
    name: http
    # -- Provide custom labels. Use the same syntax as for annotations.
    labels: {}
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    annotations:
      kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"

secret:
  # -- switch to false to prevent creating the secret
  enabled: true
  # -- Provide custom name of existing secret, or custom name of secret to be created
  nameOverride: ""
  # nameOverride: "myCustomSecret"
  # -- Annotations to be added to secret. Annotations are added only when secret is being created. Existing secret will not be modified.
  secretAnnotations:
    # Create the secret before installation, and only then. This saves the secret from regenerating during an upgrade
    # pre-upgrade is needed to upgrade from 0.7.0 to newer. Can be deleted afterwards.
    helm.sh/hook-weight: "0"
    helm.sh/hook: "pre-install, pre-upgrade"
    helm.sh/hook-delete-policy: "before-hook-creation"
    helm.sh/resource-policy: "keep"
  # -- switch to false to prevent checksum annotations being maintained and propogated to the pods
  hashSumEnabled: true

ingress:
  admin:
    enabled: false
    className: ""
    annotations:
      kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"
    hosts:
      - host: kratos.admin.local.com
        paths:
          - path: /
            pathType: ImplementationSpecific
    tls: []
    #  - secretName: chart-example-tls
    #    hosts:
    #      - chart-example.local
  public:
    enabled: false
    className: ""
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: letsencrypt
    hosts:
      - host: ${portal_fqdn}
        paths:
          - path: /kratos(/|$)(.*)
            pathType: ImplementationSpecific
    tls:
      - hosts:
        - "${portal_fqdn}"
        secretName: ""

kratos:
  development: true
  # -- Enable the initialization job. Required to work with a DB

  # -- Enables database migration
  automigration:
    enabled: true
    # -- Configure the way to execute database migration. Possible values: job, initContainer
    # When set to job, the migration will be executed as a job on release or upgrade.
    # When set to initContainer, the migration will be executed when kratos pod is created
    # Defaults to job
    type: job
    # -- Ability to override the entrypoint of the automigration container
    # (e.g. to source dynamic secrets or export environment dynamic variables)
    customCommand: []
    # -- Ability to override arguments of the entrypoint. Can be used in-depended of customCommand 
    # eg:
    # - sleep 5;
    #   - kratos
    customArgs: []

  # -- You can add multiple identity schemas here. You can pass JSON schema using `--set-file` Helm CLI argument.
  identitySchemas:
    "identity.default.schema.json": |
      {
        "$id": "https://mojaloop.io/kratos-schema/identity.schema.json",
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": "Person",
        "type": "object",
        "properties": {
          "traits": {
            "type": "object",
            "properties": {
              "email": {
                "title": "E-Mail",
                "type": "string",
                "format": "email"
              },
              "subject": {
                "title": "Subject",
                "type": "string"
              },
              "name": {
                "title": "Name",
                "type": "string"
              }
            }
          }
        }
      }

  # -- You can customize the emails kratos is sending (also uncomment config.courier.template_override_path below)
  emailTemplates: {}
  # emailTemplates:
  #   recovery:
  #     valid:
  #       subject: Recover access to your account
  #       body: |-
  #         Hi, please recover access to your account by clicking the following link:
  #         <a href="{{ .RecoveryURL }}">{{ .RecoveryURL }}</a>
  #       plainBody: |-
  #         Hi, please recover access to your account by clicking the following link: {{ .RecoveryURL }}
  #     invalid:
  #       subject: Account access attempted
  #       body: |-
  #         Hi, you (or someone else) entered this email address when trying to recover access to an account.
  #         However, this email address is not on our database of registered users and therefore the attempt has failed. If this was you, check if you signed up using a different address. If this was not you, please ignore this email.
  #       plainBody: |-
  #         Hi, you (or someone else) entered this email address when trying to recover access to an account.
  #   verification:
  #     valid:
  #       subject: Please verify your email address
  #       body: |-
  #         Hi, please verify your account by clicking the following link:
  #         <a href="{{ .VerificationURL }}">{{ .VerificationURL }}</a>
  #       plainBody: |-
  #         Hi, please verify your account by clicking the following link: {{ .VerificationURL }}
  #     invalid:
  #       subject:
  #       body:
  #       plainBody:

  config:
    # TODO: note sure if the following parameter still exists in the latest helm
    # dsn: memory
    dsn: mysql://${kratos_db_user}:${kratos_db_password}@tcp(${kratos_db_host}:3306)/${kratos_db_database}?max_conns=20&max_idle_conns=4
    courier:
      smtp:
        connection_uri: smtps://test:test@mailslurper:1025/?skip_ssl_verify=true&legacy_ssl=true
    serve:
      public:
        base_url: https://${portal_fqdn}/kratos/
        port: 4433
        cors:
          enabled: true
      admin:
        port: 4434

    selfservice:
      default_browser_return_url: https://${portal_fqdn}/
      whitelisted_return_urls:
        - https://${portal_fqdn}/

      methods:
        oidc:
          enabled: true
          config:
            providers:
            - id: idp
              provider: generic
              # TODO both the client_id and client_secret need to be set appropriately to the client supporting authorization code grants with openid
              # TODO these can alternatively be set via environment variable from a k8s secret
              client_id: ${wso2_client_id}
              client_secret: ${wso2_client_secret}
              # mapper_url: file:///etc/config2/oidc.jsonnet
              mapper_url: base64://bG9jYWwgY2xhaW1zID0gc3RkLmV4dFZhcignY2xhaW1zJyk7Cgp7CiAgaWRlbnRpdHk6IHsKICAgIHRyYWl0czogewogICAgICBlbWFpbDogY2xhaW1zLmVtYWlsLAogICAgICBuYW1lOiBjbGFpbXMuZW1haWwsCiAgICAgIHN1YmplY3Q6IGNsYWltcy5zdWIKICAgIH0sCiAgfSwKfQ==
              # issuer_url is the OpenID Connect Server URL. You can leave this empty if `provider` is not set to `generic`.
              # If set, neither `auth_url` nor `token_url` are required.
              issuer_url: ${wso2_host}/oauth2/token

              # auth_url is the authorize url, typically something like: https://example.org/oauth2/auth
              # Should only be used when the OAuth2 / OpenID Connect server is not supporting OpenID Connect Discovery and when
              # `provider` is set to `generic`.
              # auth_url: http://openid-connect-provider/oauth2/auth

              # token_url is the token url, typically something like: https://example.org/oauth2/token
              # Should only be used when the OAuth2 / OpenID Connect server is not supporting OpenID Connect Discovery and when
              # `provider` is set to `generic`.
              # token_url: http://openid-connect-provider/oauth2/token
              scope:
              # # TODO adjust requested scope based on IdP (WSO2) documentation
              - openid
      flows:
        error:
          ui_url: https://${portal_fqdn}/selfui/error

        settings:
          ui_url: https://${portal_fqdn}/selfui/settings
          privileged_session_max_age: 15m

        recovery:
          enabled: true
          ui_url: https://${portal_fqdn}/selfui/recovery

        verification:
          enabled: true
          ui_url: https://${portal_fqdn}/selfui/verify
          after:
            default_browser_return_url: https://${portal_fqdn}/selfui/

        login:
          ui_url: https://${portal_fqdn}/selfui/auth/login
          lifespan: 10m

        logout:
          after:
            default_browser_return_url: ${wso2_host}/oidc/logout

        registration:
          lifespan: 10m
          ui_url: https://${portal_fqdn}/selfui/auth/
          after:
            oidc:
              hooks:
                - hook: session
    secrets:
      cookie:
        - PLEASE-CHANGE-ME-I-AM-VERY-INSECURE
    hashers:
      argon2:
        parallelism: 1
        ## This one is changed in the new kratos version
        ## This change is because the kratos docker image version is overridden to older version. See the comments at image parameter above.
        # memory: "128MB"
        memory: 120000
        iterations: 3
        salt_length: 16
        key_length: 32
    identity:
      default_schema_url: file:///etc/config/identity.default.schema.json

deployment:
  # -- Configure the probes for when the deployment is considered ready and ongoing health check
  livenessProbe:
    httpGet:
      path: /health/alive
      port: http-admin
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 5
  readinessProbe:
    httpGet:
      path: /health/ready
      port: http-admin
    initialDelaySeconds: 30
    periodSeconds: 10
    failureThreshold: 5

  # -- Configure a custom livenessProbe. This overwrites the default object
  customLivenessProbe: {}
  # -- Configure a custom readinessProbe. This overwrites the default object
  customReadinessProbe: {}

  # -- Array of extra arguments to be passed down to the deployment. Kubernetes args format is expected
  # - --foo
  # - --sqa-opt-out
  extraArgs: []

  # -- Array of extra envs to be passed to the deployment. Kubernetes format is expected
  # - name: FOO
  #   value: BAR
  extraEnv: []
  # -- If you want to mount external volume
  # For example, mount a secret containing Certificate root CA to verify database
  # TLS connection.
  extraVolumes: []
  # - name: my-volume
  #   secret:
  #     secretName: my-secret
  extraVolumeMounts: []
  # - name: my-volume
  #   mountPath: /etc/secrets/my-secret
  #   readOnly: true

  # extraVolumes:
  #   - name: postgresql-tls
  #     secret:
  #       secretName: postgresql-root-ca
  # extraVolumeMounts:
  #   - name: postgresql-tls
  #     mountPath: "/etc/postgresql-tls"
  #     readOnly: true

  # -- If you want to add extra init containers. These are processed before the migration init container.
  # extraInitContainers: {}
  # extraInitContainers: |
  #  - name: ...
  #    image: ...
  extraInitContainers: |-
    - name: wait-for-mysql
      image: mysql
      imagePullPolicy: IfNotPresent
      command:
        - sh
        - -c
        - until mysql -h $${DB_HOST} -P $${DB_PORT} -u $${DB_USER} --password=$${DB_PASSWORD}  $${DB_DATABASE} -e 'select version()' ; 
          do
            echo --------------------;
            echo Waiting for MySQL...;
            sleep 2; 
          done;
          echo ====================; 
          echo MySQL ok!;
      env:
      - name: DB_HOST
        value: '${kratos_db_host}'
      - name: DB_PORT
        value: '3306'
      - name: DB_USER
        value: '${kratos_db_user}'
      - name: DB_PASSWORD
        value: '${kratos_db_password}'
      - name: DB_DATABASE
        value: '${kratos_db_database}'

  # -- If you want to add extra sidecar containers.
  extraContainers: ""
  # extraContainers: |
  #  - name: ...
  #    image: ...

  # -- Set desired resource parameters
  #  We usually recommend not to specify default resources and to leave this as a conscious
  #  choice for the user. This also increases chances charts run on environments with little
  #  resources, such as Minikube. If you do want to specify resources, uncomment the following
  #  lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  resources: {}
  #  limits:
  #    cpu: 100m
  #    memory: 128Mi
  #  requests:
  #    cpu: 100m
  #  memory: 128Mi

  # -- Node labels for pod assignment.
  nodeSelector: {}
  # If you do want to specify node labels, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'nodeSelector:'.
  #   foo: bar

  # -- Configure node tolerations.
  tolerations: []

  labels: {}
  #      If you do want to specify additional labels, uncomment the following
  #      lines, adjust them as necessary, and remove the curly braces after 'labels:'.
  #      e.g.  type: app

  annotations: {}
  #      If you do want to specify annotations, uncomment the following
  #      lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
  #      e.g.  sidecar.istio.io/rewriteAppHTTPProbers: "true"

  # -- The secret specified here will be used to load environment variables with envFrom.
  # This allows arbitrary environment variables to be provided to the application which is useful for
  # sensitive values which should not be in a configMap.
  # This secret is not created by the helm chart and must already exist in the namespace.
  # https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#configure-all-key-value-pairs-in-a-secret-as-container-environment-variables
  # environmentSecretsName:

  # -- Specify the serviceAccountName value.
  # In some situations it is needed to provide specific permissions to Kratos deployments.
  # Like for example installing Kratos on a cluster with a PosSecurityPolicy and Istio.
  # Uncomment if it is needed to provide a ServiceAccount for the Kratos deployment.
  serviceAccount:
    # -- Specifies whether a service account should be created
    create: true
    # -- Annotations to add to the service account
    annotations: {}
    # -- The name of the service account to use. If not set and create is true, a name is generated using the fullname template
    name: ""

  # https://github.com/kubernetes/kubernetes/issues/57601
  automountServiceAccountToken: true

  # -- Specify pod metadata, this metadata is added directly to the pod, and not higher objects
  podMetadata:
    # -- Extra pod level labels
    labels: {}
    # -- Extra pod level annotations
    annotations: {}

## -- Configuration options for the k8s statefulSet
statefulSet:
  resources: {}
  #  We usually recommend not to specify default resources and to leave this as a conscious
  #  choice for the user. This also increases chances charts run on environments with little
  #  resources, such as Minikube. If you do want to specify resources, uncomment the following
  #  lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  #  limits:
  #    cpu: 100m
  #    memory: 128Mi
  #  requests:
  #    cpu: 100m
  #  memory: 128Mi

  # -- Array of extra arguments to be passed down to the StatefulSet. Kubernetes args format is expected
  extraArgs: []
  # - --foo
  # - --sqa-opt-out

  extraEnv: []
  # -- If you want to mount external volume
  # For example, mount a secret containing Certificate root CA to verify database
  # TLS connection.
  extraVolumes: []
  # - name: my-volume
  #   secret:
  #     secretName: my-secret
  extraVolumeMounts: []
  # - name: my-volume
  #   mountPath: /etc/secrets/my-secret
  #   readOnly: true

  # -- If you want to add extra init containers. These are processed before the migration init container.
  extraInitContainers: ""
  # extraInitContainers: |
  #  - name: ...
  #    image: ...

  # -- If you want to add extra sidecar containers.
  extraContainers: ""
  # extraContainers: |
  #  - name: ...
  #    image: ...

  annotations: {}
  #      If you do want to specify annotations, uncomment the following
  #      lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
  #      e.g.  sidecar.istio.io/rewriteAppHTTPProbers: "true"

  labels: {}
  #      If you do want to specify additional labels, uncomment the following
  #      lines, adjust them as necessary, and remove the curly braces after 'labels:'.
  #      e.g.  type: app

  # -- Node labels for pod assignment.
  nodeSelector: {}
  # If you do want to specify node labels, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'nodeSelector:'.
  #   foo: bar

  log:
    format: json
    level: trace

    # -- Specify pod metadata, this metadata is added directly to the pod, and not higher objects
  podMetadata:
    # -- Extra pod level labels
    labels: {}
    # -- Extra pod level annotations
    annotations: {}

securityContext:
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 100
  allowPrivilegeEscalation: false
  privileged: false

# -- Horizontal pod autoscaling configuration
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

# -- Values for initialization job
job:
  # -- If you do want to specify annotations, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
  annotations:
    helm.sh/hook-weight: "1"
    helm.sh/hook: "pre-install, pre-upgrade"
    helm.sh/hook-delete-policy: "before-hook-creation,hook-succeeded"
  # kubernetes.io/ingress.class: nginx
  # kubernetes.io/tls-acme: "true"

  # -- If you want to add extra sidecar containers.
  extraContainers: ""
  # extraContainers: |
  #  - name: ...
  #    image: ...

  # -- If you want to add extra init containers.
  extraInitContainers: ""
  # extraInitContainers: |
  #  - name: ...
  #    image: ...
  # -- Node labels for pod assignment.
  nodeSelector: {}
  # If you do want to specify node labels, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'nodeSelector:'.
  #   foo: bar

  # -- If you want to add lifecycle hooks.
  lifecycle: ""
  # lifecycle: |
  #   preStop:
  #     exec:
  #       command: [...]

  # -- Set automounting of the SA token
  automountServiceAccountToken: true

  # -- Set sharing process namespace
  shareProcessNamespace: false

  # -- Specify the serviceAccountName value.
  # In some situations it is needed to provides specific permissions to Hydra deployments
  # Like for example installing Hydra on a cluster with a PosSecurityPolicy and Istio.
  # Uncoment if it is needed to provide a ServiceAccount for the Hydra deployment.
  serviceAccount:
    # -- Specifies whether a service account should be created
    create: true
    # -- Annotations to add to the service account
    annotations:
      helm.sh/hook-weight: "0"
      helm.sh/hook: "pre-install, pre-upgrade"
      helm.sh/hook-delete-policy: "before-hook-creation"
    # -- The name of the service account to use. If not set and create is true, a name is generated using the fullname template
    name: ""

  # -- Specify pod metadata, this metadata is added directly to the pod, and not higher objects
  podMetadata:
    # -- Extra pod level labels
    labels: {}
    # -- Extra pod level annotations
    annotations: {}

  spec:dsnigure node affinity
affinity: {}
# -- Node labels for pod assignment.
nodeSelector: {}
# -- If you do want to specify node labels, uncomment the following
# lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
#   foo: bar
# Configure node tolerations.
tolerations: []

# -- Configuration of the watcher sidecar
watcher:
  enabled: false
  image: oryd/k8s-toolbox:0.0.4
  # -- Path to mounted file, which wil be monitored for changes. eg: /etc/secrets/my-secret/foo
  mountFile: ""
  # -- Specify pod metadata, this metadata is added directly to the pod, and not higher objects
  podMetadata:
    # -- Extra pod level labels
    labels: {}
    # -- Extra pod level annotations
    annotations: {}

# -- PodDistributionBudget configuration
pdb:
  enabled: false
  spec:
    minAvailable: 1

# -- Parameters for the Prometheus ServiceMonitor objects.
# Reference: https://docs.openshift.com/container-platform/4.6/rest_api/monitoring_apis/servicemonitor-monitoring-coreos-com-v1.html
serviceMonitor:
  # -- switch to false to prevent creating the ServiceMonitor
  enabled: true
  # -- HTTP scheme to use for scraping.
  scheme: http
  # -- Interval at which metrics should be scraped
  scrapeInterval: 60s
  # -- Timeout after which the scrape is ended
  scrapeTimeout: 30s
  # -- Provide additionnal labels to the ServiceMonitor ressource metadata
  labels: {}
  # -- TLS configuration to use when scraping the endpoint
  tlsConfig: {}

configmap:
  # -- switch to false to prevent checksum annotations being maintained and propogated to the pods
  hashSumEnabled: true
  # -- If you do want to specify annotations for configmap, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
  annotations: {}