# -- If enabled, a demo deployment with exemplary access rules and JSON Web Key Secrets will be generated.
demo: false

fullnameOverride: "oathkeeper"
# -- Configures the Kubernetes service
service:
  # -- Configures the Kubernetes service for the proxy port.
  proxy:
    # -- En-/disable the service
    enabled: true
    # -- The service type
    type: ClusterIP
    # -- The service port
    port: 4455
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    labels: {}
    #      If you do want to specify additional labels, uncomment the following
    #      lines, adjust them as necessary, and remove the curly braces after 'labels:'.
    #      e.g.  app: oathkeeper

  # -- Configures the Kubernetes service for the api port.
  api:
    # -- En-/disable the service
    enabled: true
    # -- The service type
    type: ClusterIP
    # -- The service port
    port: 4456
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    labels: {}
    #      If you do want to specify additional labels, uncomment the following
    #      lines, adjust them as necessary, and remove the curly braces after 'labels:'.
    #      e.g.  app: oathkeeper

# -- Configure ingress
ingress:
  # -- Configure ingress for the proxy port.
  proxy:
    # -- En-/Disable the proxy ingress.
    enabled: true
    className: ""
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2
#     kubernetes.io/ingress.class: nginx
#     kubernetes.io/tls-acme: "true"
    hosts:
      - host: ${portal_fqdn}
        paths: 
          - path: /proxy(/|$)(.*)
              
#    tls: []
#        hosts:
#          - ${portal_fqdn}
#      - secretName: oathkeeper-proxy-example-tls

  api:
    # -- En-/Disable the api ingress.
    enabled: false
    className: ""
    annotations: {}
#      If you do want to specify annotations, uncomment the following
#      lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
#      kubernetes.io/ingress.class: nginx
#      kubernetes.io/tls-acme: "true"
    hosts:
      - host: api-oathkeeper.local
        paths: ["/"]

#    tls: []
#      hosts:
#        - api-oathkeeper.local
#      - secretName: oathkeeper-api-example-tls

# -- Configure ORY Oathkeeper itself
oathkeeper:
  # -- The ORY Oathkeeper configuration. For a full list of available settings, check:
  #   https://github.com/ory/oathkeeper/blob/master/docs/config.yaml
  config:
    log:
      level: info
      format: json
    access_rules:
      matching_strategy: regexp
    authenticators:
      cookie_session:
        enabled: true
        config:
          # this should be the internal URL of the public Kratos service's whoami endpoint, which might look like the below
          check_session_url: http://kratos-public/sessions/whoami
          preserve_path: true
          # this means we automatically sweep up all the metadata kratos provides for use
          # in, for example, the JWT, if we ever have more
          extra_from: "@this"
          # kratos will be configured to put the subject from the IdP here
          subject_from: "identity.traits.subject"
          only:
          - ory_kratos_session
      oauth2_introspection:
        enabled: true
        config:
          introspection_url: ${wso2_host}/oauth2/introspect
          introspection_request_headers:
            # Configure the following with base64 encoded string contains admin:password of wso2 server
            authorization: "Basic ${wso2_admin_creds}"
            # cache:
            #   # disabled to make debugging easier. enable for caching.
            #   enabled: false
            #   ttl: "60s"
    authorizers:
      remote_json:
        enabled: true
        config:
          # the check URL for Keto. This will be POST'd to. See https://www.ory.sh/keto/docs/reference/rest-api#operation/postCheck
          remote: http://keto-read/check
          payload: ""
    mutators:
      id_token:
        enabled: true
        config:
          # this should be the internal base URL for the API service, which will look something like the below
          issuer_url: http://oathkeeper-api:4456/
      header:
        # Set enabled to true if the authenticator should be enabled and false to disable the authenticator. Defaults to false.
        enabled: true
        config:
          headers:
            X-User: '{{ print .Subject }}'
    errors:
      fallback:
        - json
      handlers:
        json:
          # this gives API clients pretty error JSON
          enabled: true
          config:
            verbose: true
        redirect:
          enabled: true
          config:
            # set this to whatever the main URL is, it'll ensure that browser errors redirect there
            to: http://${portal_fqdn}/
            when:
            - error:
              - unauthorized
              - forbidden
              request: 
                header:
                  accept:
                  - text/html
    serve:
      proxy:
        port: 4455
      api:
        port: 4456
  # -- If set, uses the given JSON Web Key Set as the signing key for the ID Token Mutator.
  mutatorIdTokenJWKs: {}
  # -- If set, uses the given access rules.
  # accessRules: {}

  # -- If you enable maester, the following value should be set to "false" to avoid overwriting
  # the rules generated by the CDRs. Additionally, the value "accessRules" shouldn't be
  # used as it will have no effect once "managedAccessRules" is disabled.
  managedAccessRules: false

secret:
  # -- set to true for this helm chart to manage the secret
  # -- set to false for this helm chart to NOT manage the secret
  # -- defaults to true
  manage: true

  # -- name of the secret to use. If empty, defaults to {{ include "oathkeeper.fullname" . }}
  name: "oathkeeper-jwks"

  # -- default mount path for the kubernetes secret
  mountPath: /etc/secrets
  # -- default filename of JWKS (mounted as secret)
  filename: mutator.id_token.jwks.json

deployment:
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
  securityContext:
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 1000
    allowPrivilegeEscalation: false
    privileged: false

  # https://github.com/kubernetes/kubernetes/issues/57601
  automountServiceAccountToken: false

  # -- Node labels for pod assignment.
  nodeSelector: {}
  # If you do want to specify node labels, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
  #   foo: bar

  extraEnv:
    # for whatever reason this environment variable only gets set if the JWKS is in the config even though the rest of the secret mounting
    # and such still happens
    - name: MUTATORS_ID_TOKEN_CONFIG_JWKS_URL
      value: file:///etc/secrets/mutator.id_token.jwks.json

  # -- Extra volumes you can attach to the pod.
  extraVolumes: []
  # - name: my-volume
  #   secret:
  #     secretName: my-secret

  # -- Extra volume mounts, allows mounting the extraVolumes to the container.
  extraVolumeMounts: []
  # - name: my-volume
  #   mountPath: /etc/secrets/my-secret
  #   readOnly: true

  # -- Configuration for tracing providers. Only datadog is currently supported through this block.
  # If you need to use a different tracing provider, please manually set the configuration values
  # via "oathkeeper.config" or via "deployment.extraEnv".
  tracing:
    datadog:
      enabled: false

      # -- Sets the datadog DD_ENV environment variable. This value indicates the environment where oathkeeper is running.
      # Default value: "none".
      # env: production

      # -- Sets the datadog DD_VERSION environment variable. This value indicates the version that oathkeeper is running.
      # Default value: .Values.image.tag (i.e. the tag used for the docker image).
      # version: X.Y.Z

      # -- Sets the datadog DD_SERVICE environment variable. This value indicates the name of the service running.
      # Default value: "ory/oathkeeper".
      # service: ory/oathkeeper

      # -- Sets the datadog DD_AGENT_HOST environment variable. This value indicates the host address of the datadog agent.
      # If set to true, this configuration will automatically set DD_AGENT_HOST to the field "status.hostIP" of the pod.
      # Default value: false.
      # useHostIP: true

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


# -- Configure node affinity
affinity: {}

# -- Configures controller setup
maester:
  enabled: false
  oathkeeperFullnameOverride: 'oathkeeper'

# -- PodDistributionBudget configuration
pdb:
  enabled: false
  spec:
    minAvailable: 1
