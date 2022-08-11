# Deploying a Mojaloop Environment

## Pre-Requisites (before deploying an environment)

 mojaloop-bootstrap v2.2.2 should already be deployed

For mojaloop-bootstrap:
<https://github.com/mojaloop/iac-aws-bootstrap#readme>

When the bootstrap code is run, you specify the environments that you wish to provision in a list.  For each of these environments, the following functionality is enabled:

1. The subnets/security groups/etc are created for the environment cloud elements to be installed into.
2. A blank repo is created in the tenancy gitlab instance named the same as the env name and with the correct group settings for successful AWS provisioning.
3. The group settings will also allow for the env IaC code to create the correct OIDC applications in gitlab to allow for admin/users to access vault/grafana/kube-api.


## 1. Preparation

### Creating a Slack Channel with WebHooks

Create a webhook for slack notifications on this page: <https://api.slack.com/apps/A019UEZ37MW/incoming-webhooks>

If the notification channel for this env doesn’t exist, create the channel in the slack along this format:

grafana-alerts-${`env.name`}-${`tenancy.name`}

Create a webhook and associate it with the new channel above.
Keep a copy of the WebHook URL.     You will need it in the next section.

### Clone Environment Repository

* Clone the environment repo from tenancy gitlab

* Grab the switch-iac directory from the gitlab_templates directory of the present repo, copy the appropriate version of the workbench config file and rename to workbench-config.json.  Copy the backend.hcl file that was used for the bootstrap to the root of the gitlab repo and push those changes to gitlab.

* Edit the `workbench-config.json` as required. At the very least you need to edit the following fields:

|         field                                  |        Notes                                       |
|------------------------------------------------|----------------------------------------------------|
| `“client": ”<placeholder>”`                    |  The Client name - usually the DNS name of the TENANT |
| `“environment": ”<placeholder>”`               |  The environment name: dev, qa, prod etc |
| `“region": ”eu-west-1”`                    |  If you need to edit region you __must__ also edit the aws_ami field below  |
| `"grafana_slack_notifier_url": "\<placeholder>"` |  Use the WebHook URL from Step 1                    |
| `"hub_currency_code": "USD"`                    |  If the deployment requires a currency other than USD it should be set here |
---


## 2. Running the CI/CD jobs to create the environment

Most of the time we will start from this step (Because we are not destroying Gitlab)
> :warning: CAUTION: GitLab provides a “Cancel” button for jobs running within the CI/CD pipeline. It is STONGLY advised that you do not cancel a CICD job - it is generally simpler to allow it to fail naturally (or complete) and clean up any damage, rather than dealing with the consequences of cancelling a job, which can include issues with Terraform State locks, and potentially inconsistent state. You have been warned.

Once the Validate and Plan job completes all the other jobs become available. To deploy the environment you must run the Deploy AWS Infrastructure, Run Kubespray, Deploy Vault and Deploy Mojaloop pipelines in that order.

### PIPELINE ORDERING

You can run the Deploy All job in order to run all steps in order for a new installation.  If you want to run each of these manually, you can run through the following order:

#### Creating the infrastructure:
1. Run **Deploy AWS Infrastructure** This creates the load-balancing, ec2 instances and route53 entities needed for the kubernetes cluster.
2. Run **Create Create Gateway Cluster and k3s Cluster** in parallel.  These jobs create the switch kubernetes cluster (via kubespray) and the internal k3s cluster for running the internal pm4mls for testing end to end.
3. Run **Deploy Base Services**  This step installs the base services (vault, cert-manager, external-dns, longhorn storage, nginx ingress controllers)
4. Run **Deploy Stateful Services** This step installs the stateful resources services (mysql, mongodb, kafka, etc)
5. Run **Deploy Support Services** This step installs support services including wso2 and other security elements (connection manager, haproxy forward proxy, loki stack, etc)
6. Run **Deploy Mojaloop Apps** This job installs mojalooop and bizops framework, it also configures the wso2 gateway with the mojaloop APIs.
7. Run **Deploy Post Install** This job will provision DFSPs and create admin accounts.
8. Run **Install Internal PM4MLs** This will install the internal pm4mls into the k3s cluster.


#### Run Tests:
1. Run **Run TTK Tests** runs ttk-based tests using internal sims
2. Run **Manual Run PM4ML GP Tests** runs GP tests using internal pm4mls (end to end with full security)


#### Portal Access:
OIDC access has been automated to allow appropriate gitlab users to access administrative consoles including vault, grafana and the kubeapi.  In order to access these resources, you will need to be connected to the wireguard instance of the tenancy.  See the bootstrap documentation for those details.
Once you are on the vpn, you can access those consoles here:

https://vault.<<env-name>>.<<tenancy-domain>>
https://grafana.<<env-name>>.<<tenancy-domain>>

When connecting to vault, select the OIDC option from the drop down, in the Role text box, type: techops-admin and then click Sign in with GitLab.  You will be presented with an option to approve the request in gitlab.  Then you will be redirected back to vault.

For grafana, you will see an option at the bottom that says: Sign in with GitLab.  Click this and you will be redirected to gitlab and then after approving, you get redirected back to grafana. 