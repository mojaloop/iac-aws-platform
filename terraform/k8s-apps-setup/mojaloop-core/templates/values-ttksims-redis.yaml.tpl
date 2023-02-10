## Reference: https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml
## @param architecture Redis&reg; architecture. Allowed values: `standalone` or `replication`
##
architecture: standalone

## Redis&reg; Authentication parameters
## ref: https://github.com/bitnami/containers/tree/main/bitnami/redis#setting-the-server-password-on-first-run
##
auth:
  ## @param auth.enabled Enable password authentication
  ##
  enabled: false

## @section Persistence parameters
##
master:
  ## Enable persistence using Persistent Volume Claims
  ## ref: https://kubernetes.io/docs/user-guide/persistent-volumes/
  ##
  persistence:
    ## @param persistence.enabled Enable MongoDB(&reg;) data persistence using PVC
    ##
    enabled: false

  ## @param affinity Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}

  ## @param nodeSelector Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  # nodeSelector: {}
  
  ## Example
  # nodeSelector:
  #     "node-role.mojaloop.io": redis

  ## @param tolerations Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  # tolerations: []

  ## Example
  # tolerations:
  #   - key: "node-role.mojaloop.io"
  #     operator: "Equal"
  #     value: redis
  #     effect: "NoSchedule"

replica:
  enabled: false
  ## Enable persistence using Persistent Volume Claims
  ## ref: https://kubernetes.io/docs/user-guide/persistent-volumes/
  ##
  persistence:
    ## @param persistence.enabled Enable MongoDB(&reg;) data persistence using PVC
    ##
    enabled: false
