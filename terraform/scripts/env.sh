#!/bin/sh
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:       sep-2023
#
# usage:      reformat environment variables for consumption by Terraform.
#             Called by Terraform data "external"
#------------------------------------------------------------------------------

# https://support.hashicorp.com/hc/en-us/articles/4547786359571-Reading-and-using-environment-variables-in-Terraform-runs


set -o allexport
source ../.env set    # this is relative to the calling Terraform resource
+o allexport

# Change the contents of this output to get the environment variables
# of interest. The output must be valid JSON, with strings for both
# keys and values.
cat <<EOF
{
  "OPENAI_API_KEY": "$OPENAI_API_KEY",
  "OPENAI_API_ORGANIZATION": "$OPENAI_API_ORGANIZATION"
}
EOF
