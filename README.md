# Create an Environment

This repository is used to create a deployment of Mojaloop and supporting services.

## Before Deployment

Ensure the environment is defined in the ["bootstrap repository"](https://github.com/mojaloop/iac-aws-bootstrap) following the instructions defined there.

## How To Deploy

This [guide](./documents/d20.deploy_into_tenancy.md) walk you through creating a mojaloop deployment.

## Known Issues

* After a successful WSO2 password reset, WSO continues to issue the now-invalidated token until it ages-out (~10 minutes.)

* WSO2 redeployment can cause SIMS to fail silently.

## Additional Reading

[Some notes on Vault](./documents/d90.vault.md)
