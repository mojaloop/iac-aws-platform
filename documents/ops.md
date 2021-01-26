# Operational Tips

A collection of tips to make operating a deployment easier.

## Set Environment variables

Having your local environment setup with certain variables will make you life at the command line a lot easier. Most shells can be configured to automatically loading environment variables from a `.env`. If you don't do that already it is highly recommended you do.

### Dependencies

None

### Process

Add the following to a `.env` file in the root of the env repo.

```bash
BUCKET=<AWS S3 bucket name>
AWS_PROFILE=<AWS profile name>
```

## Get Kubeconfigs

The admin kubeconfigs are stored the S3 bucket created for the tenant. You will need these kubeconfigs to interact with the clusters.

### Dependencies

- [AWS CLI](https://aws.amazon.com/cli/)
- [Set Environment variables](#set-environment-variables)

### Process

To get the kubeconfigs for all the clusters in a deployment, run the following commands:

```bash
cd $(git rev-parse --show-toplevel)
aws s3 cp s3://$BUCKET/$(basename $PWD)/ . --sse --recursive --exclude "*" --include "admin-*"
cd -
```

## Install Krew

To make working with the Kubernetes clusters at the command line a lot easier, it is recommended you install Krew.

### Dependencies

- Installation of `kubectl`

### Process

Follow the [install instructions](https://github.com/kubernetes-sigs/krew/). Then install the following plugins:

```bash
kubectl krew install view-secret
kubectl krew install images
```

## Accessing Grafana

The `admin` password is randomly generated at deploy time and stored in a Kubernetes Secret object.

### Dependencies

- [Get Kubeconfigs](#get-kube-configs)
- For Linux OSes (not MacOS) you will need to [install and setup pbcopy](https://ostechnix.com/how-to-use-pbcopy-and-pbpaste-commands-on-linux/)
- [Install Krew](#install-krew)

### Process

Run the command from the root of the env repo:

```bash
KUBECONFIG=admin-support-services.conf kubectl view-secret grafana-support-services -n monitoring admin-password | pbcopy
```

You can then paste the password into the login page.

## Getting cluster Endpoints

A lot of endpoints are created for each of the clusters. It can be challenging to know what all are. The following command makes that process a lot easier.

### Dependencies

- Installation of `kubectl`
- Installation of `jq`

### Process

```bash
kubectl get ing -A -o json | jq -r '.items[].spec.rules[] | .host as $host | .http.paths[].path as $path | "http://" + $host + ":30000" + $path'
```
