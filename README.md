# Mojaloop Platform IaC

![mojaloopIaC banner](./documents/readme_images/000-banner.png)

Welcome to release v1.0.0 of the mojaloop-IaC.

## Before Deployment - bootstrap

mojaloop-IAC is designed to run as a subset of the ["mojaloop-bootstrap for AWS"](https://github.com/mojaloop/iac-aws-bootstrap)

mojaloop-bootstrap is used to define the client or *tenancy* (these terms are used interchangeably throughout documentation and TF code)  and therefor the supporting IAM, network, routing, and code repository to allow each environment to be deployed programatically:

![mojaloop tenancy](./documents/readme_images/010-tenancy.png)

This model has two objectives:

1. To allow the mojaloop-IaC to be deployed as repeatably as possible through multiple pipelines.
2. To allow the mojaloop-IaC to be 'abstracted' in a future release, allowing the same IaC code to be consumed in AWS, Azure or OnPremises by simply selecting an appropriate bootstrap.

For more information on this structure see <https://modusbox.atlassian.net/wiki/spaces/MIT/pages/484376623/IaC+Design>

For more information, see <https://modusbox.atlassian.net/wiki/spaces/CK/pages/610796145/Creating+a+Mojaloop+platform+for+a+client>

## How To Deploy

The following included guide indicates how to deploy this release into an existing bootstrap.

[Deploying a mojaloop Environment into a Tenancy](./documents/d20.deploy_into_tenancy.md)

## Known Issues

[PSOINFRA-409](https://modusbox.atlassian.net/browse/PSOINFRA-409)
Pipeline jobs under "Run Kubespray" will occasionally fail with random errors, but succeed on 2nd or 3rd attempt.

[PSOINFRA-410](https://modusbox.atlassian.net/browse/PSOINFRA-410) After a successful WSO2 password reset, WSO continues to issue the now-invalidated token until it ages-out (~10 minutes.)

[PSOINFRA-377](https://modusbox.atlassian.net/browse/PSOINFRA-377?atlOrigin=eyJpIjoiYjg3ZTY5ZjA3ZTY2NDg4YjlmYzhhZjVkMzIzNjA3OWUiLCJwIjoiaiJ9)  WSO2 redeployment can cause SIMS to fail silently.

[PSOINFRA-439](https://modusbox.atlassian.net/browse/PSOINFRA-439)
"The Six Assertions" : Pipeline job 'Prepare Tests FXP Onboarding'  succeeds, but reports six assertion failures.    The error can be ignored, but causes the pipeline job to show as "Failed".

[PSOINFRA-440](https://modusbox.atlassian.net/browse/PSOINFRA-440)
Trying to run FXP tests requires some manual processing.

[PSOINFRA-441](https://modusbox.atlassian.net/browse/PSOINFRA-441) SDK deploymnents require the VM SSH Key to be added to the project folder before running the "SDK Installation" job.

## Improvements

[PSOINFRA-382](https://modusbox.atlassian.net/browse/PSOINFRA-382?atlOrigin=eyJpIjoiODJlNmY1MTE2ODZjNDk0Njk1N2IwZjgyNjJlNTM0NTkiLCJwIjoiaiJ9) PVCs now alert at 25% remaining, as opposed to 75%.  Threshold is now consistant across clusters.

[PSOINFRA-389 - SDK Deployment optional](https://modusbox.atlassian.net/browse/PSOINFRA-389?atlOrigin=eyJpIjoiNTQ4ZDY0YThjNjc0NDQyNWFmYWYxNjIxM2ZlMTllOWIiLCJwIjoiaiJ9) Deployment of the SDK is now optional.

## Additional Reading

[Some notes on Vault](./documents/d90.vault.md)
