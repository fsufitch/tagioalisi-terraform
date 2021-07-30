# tagioalisi-terraform

[Terraform](https://www.terraform.io) configuration for standing up the stack for the
[Tagioalisi bot](https://github.com/fsufitch/tagioalisi-bot).

## Usage

Download and unzip the Terraform appropriate for your platform (https://www.terraform.io/downloads.html).

Initialize the directory for use as a Terraform instance.

    ./terraform init

Then, create a workspace for each stack version (dev, test, prod, etc).

    ./terraform workspace new test

Run terraform commands against this workspace. You *must* specify `TF_VAR_stack_id` as an 
all-lowercase-letter string, in order to provide a method to isolate resources of different stacks.

    TF_VAR_STACK_ID=test ./terraform plan

Keep in mind that the instructions above set up **local** state tracking for Terraform. Setting up S3
or Consul state tracking is left as an exercise for the reader.