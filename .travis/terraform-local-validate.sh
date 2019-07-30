#!/bin/bash

TERRAFORM_BIN="/usr/local/bin"
TERRAFORM="${TERRAFORM_BIN}/terraform"

# https://github.com/hashicorp/terraform/issues/21408
# This is needed because the provider schema region is needed, but for testing purposes,
# we don't want to set this on each module.
export AWS_DEFAULT_REGION="us-west-2"

${TERRAFORM} init -backend=false
${TERRAFORM} validate
