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
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    annotations:
      kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  public:
    enabled: true
    type: ClusterIP
    port: 80
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    annotations:
      kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"

secret:
  # -- switch to false to prevent creating the secret
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

ingress:
  admin:
    enabled: false
    className: ""
    annotations:
      kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"
    hosts:
      - host: kratos-admin.local
        paths: 
          - /
    tls: []
    #  - secretName: kratos-admin-tls
    #    hosts:
    #      - kratos-admin.local
  public:
    enabled: true
    className: ""
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"
    hosts:
      -
        host: ${portal_fqdn}
        paths: 
          - /kratos(/|$)(.*)
    tls: []
    #  - secretName: kratos-public-tls
    #    hosts:
    #      - ${portal_fqdn}

kratos:
  log:
    ## Leak Sensitive Log Values ##
    #
    # If set will leak sensitive values (e.g. emails) in the logs.
    #
    # Set this value using environment variables on
    # - Linux/macOS:
    #    $ export LOG_LEAK_SENSITIVE_VALUES=<value>
    # - Windows Command Line (CMD):
    #    > set LOG_LEAK_SENSITIVE_VALUES=<value>
    #
    leak_sensitive_values: false
    ## format ##
    #
    # The log format can either be text or JSON.
    #
    # One of:
    # - json
    # - text
    #
    # Set this value using environment variables on
    # - Linux/macOS:
    #    $ export LOG_FORMAT=<value>
    # - Windows Command Line (CMD):
    #    > set LOG_FORMAT=<value>
    #
    format: text
    ## level ##
    #
    # Debug enables stack traces on errors. Can also be set using environment variable LOG_LEVEL.
    #
    # Default value: info
    #
    # One of:
    # - trace
    # - debug
    # - info
    # - warning
    # - error
    # - fatal
    # - panic
    level: info
  development: true
  # -- Enable the initialization job. Required to work with a DB
  autoMigrate: true

  # -- You can add multiple identity schemas here
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

  config:
    # dsn: memory
    dsn: mysql://user:password@tcp(kratos-db:3306)/kratos?max_conns=20&max_idle_conns=4
    courier:
      smtp:
        connection_uri: smtps://test:test@mailslurper:1025/?skip_ssl_verify=true&legacy_ssl=true
    serve:
      public:
        base_url: http://${portal_fqdn}/kratos/
        port: 4433
        cors:
          enabled: true
      admin:
        port: 4434

    selfservice:
      default_browser_return_url: http://${portal_fqdn}/
      whitelisted_return_urls:
        - http://${portal_fqdn}/

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
          ui_url: http://${portal_fqdn}/selfui/error

        settings:
          ui_url: http://${portal_fqdn}/selfui/settings
          privileged_session_max_age: 15m

        recovery:
          enabled: true
          ui_url: http://${portal_fqdn}/selfui/recovery

        verification:
          enabled: true
          ui_url: http://${portal_fqdn}/selfui/verify
          after:
            default_browser_return_url: http://${portal_fqdn}/selfui/

        login:
          ui_url: http://${portal_fqdn}/selfui/auth/login
          lifespan: 10m

        logout:
          after:
            default_browser_return_url: ${wso2_host}/oidc/logout

        registration:
          lifespan: 10m
          ui_url: http://${portal_fqdn}/selfui/auth/
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
        value: 'kratos-db'
      - name: DB_PORT
        value: '3306'
      - name: DB_USER
        value: 'user'
      - name: DB_PASSWORD
        value: 'password'
      - name: DB_DATABASE
        value: 'kratos'

  # -- Configuration for tracing providers. Only datadog is currently supported through this block.
  # If you need to use a different tracing provider, please manually set the configuration values
  # via "kratos.config" or via "deployment.extraEnv".
  tracing:
    datadog:
      enabled: false

      # Sets the datadog DD_ENV environment variable. This value indicates the environment where kratos is running.
      # Default value: "none".
      # env: production

      # Sets the datadog DD_VERSION environment variable. This value indicates the version that kratos is running.
      # Default value: .Values.image.tag (i.e. the tag used for the docker image).
      # version: X.Y.Z

      # Sets the datadog DD_SERVICE environment variable. This value indicates the name of the service running.
      # Default value: "ory/kratos".
      # service: ory/kratos

      # Sets the datadog DD_AGENT_HOST environment variable. This value indicates the host address of the datadog agent.
      # If set to true, this configuration will automatically set DD_AGENT_HOST to the field "status.hostIP" of the pod.
      # Default value: false.
      # useHostIP: true

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

  # -- Node labels for pod assignment.
  nodeSelector: {}
  # If you do want to specify node labels, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
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

  # https://github.com/kubernetes/kubernetes/issues/57601
  automountServiceAccountToken: true

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
  annotations: {}
  ttlSecondsAfterFinished: 60

statefulset:
  log:
    format: json
    level: trace

# -- Configure node affinity
affinity: {}
# -- Node labels for pod assignment.
nodeSelector: {}
# -- If you do want to specify node labels, uncomment the following
# lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
#   foo: bar
# Configure node tolerations.
tolerations: []

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