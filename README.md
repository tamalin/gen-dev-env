General Purpose Development Environment

Can be used to bring up one or more VMs with terraform, either locally
using libvirt or in a supported Cloud such AWS, or Azure.

NOTE: Expects that you have already logged in to the respective cloud
providers using the desired credentials.

Run the bin/dev-env-setup script to setup your environment ready to
deploy instances.

The dev-env-setup script performs the following actions:

* Validates that you are using a compatible ansible version (min 2.9 as
  of writing)

* Installs the github:nbering/terraform-inventory/terraform.py inventory
  script for use with terraform deployed systems.

* Downloads a version of terraform (0.15.1 as of writing this, but can be
  overriden using the `DEV_ENV_TERRAFORM_VERSION` env var) to the bin
  directory under this repo

* Sets up the dmacvicar/libvirt terraform provider under the users
  ~/.local/share/terraform/plugins/registry.terraform.io/ area.

* Downloads and sets up the latest available go version under the go/
  directory and symlinks it as bin/go; intended to support
  terraform-provider-libvirt development work, if needed.

Once dev-env-setup has completed you should be ready to cd into
the terraform directory and create a terraform.tfvars; see the
terraform.tfvars.example for reference.

In the terraform directory you can run `terraform init` to initialise the
environment, and then run through the use terraform plan/apply/destroy
lifecycle operations to create the dev env instances.

Right now it just unconditionally brings up one of each of the following
instances using the libvirt provider:
  * Ubuntu Bionic/18.04
  * Ubuntu Focal/20.04
  * openSUSE Leap 15.2

The plan is to add support for additional distributions & releases,
as well as allow customising which distribution/release combinations to
bring up, and how many instances of each, and which provider to use.

Once the instances have been brough up by running `terraform apply` you
can run Ansible playbooks like so:

    % cd terraform
    % ansible-playbook -i ../ansible/terraform.py ../ansible/hello-world.yml
