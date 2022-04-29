serviceAccount:
  create: false
  name: ${service_account_name}
## Default values for image
image:
  repository: haproxytech/haproxy-alpine    # can be changed to use CE or EE images
  tag: "{{ .Chart.AppVersion }}"
  pullPolicy: IfNotPresent

## Command line arguments to pass to HAProxy
args:
  enabled: true    # EE images require disabling this due to S6-overlay
  extraArgs: []    # EE images require disabling this due to S6-overlay



## Init Containers
## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
initContainers: []
# - name: sysctl
#   image: "busybox:musl"
#   command:
#     - /bin/sh
#     - -c
#     - sysctl -w net.core.somaxconn=65536
#   securityContext:
#     privileged: true

## Pod termination grace period
## ref: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/
terminationGracePeriodSeconds: 60


## Container listener port configuration
## ref: https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
containerPorts:   # has to match hostPorts when useHostNetwork is true
  http: 80
  https: 443
  stat: 1024


## Container lifecycle handlers
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/
lifecycle: {}
  ## Example preStop for graceful shutdown
  # preStop:
  #   exec:
  #     command: ["/bin/sh", "-c", "kill -USR1 $(pidof haproxy); while killall -0 haproxy; do sleep 1; done"]

## Additional volumeMounts to the controller main container
extraVolumeMounts: 
  - name: etc-haproxy
    mountPath: /etc/haproxy
# - name: tmp
#   mountPath: /tmp
# - name: var-state-haproxy
#   mountPath: /var/state/haproxy

## Additional volumes to the controller pod
extraVolumes: 
  - name: etc-haproxy
    emptyDir:
      medium: Memory
# - name: etc-haproxy
#   emptyDir: {}
# - name: tmp
#   emptyDir: {}
# - name: var-state-haproxy
#   emptyDir: {}

## HAProxy daemon configuration
# ref: https://www.haproxy.org/download/2.2/doc/configuration.txt
config: {}

## Additional secrets to mount as volumes
## This is expected to be an array of dictionaries specifying the volume name, secret name and mount path
mountedSecrets:
  - volumeName: ssl-certificate
    secretName: ${cert_secret_name}
    mountPath: /usr/local/etc/ssl

## Additional labels to add to the pod container metadata
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
podLabels: {}
#  key: value

## Additional annotations to add to the pod container metadata
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
podAnnotations:
  vault.hashicorp.com/agent-inject: "true"
  vault.hashicorp.com/log-level: "debug"
  vault.hashicorp.com/agent-configmap: "vault-haproxy"
  vault.hashicorp.com/agent-copy-volume-mounts: "haproxy"
  vault.hashicorp.com/agent-set-security-context: "false"
