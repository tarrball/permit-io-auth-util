# Auth Utility using Permit.io

## Purpose

This utility is intended to provide an example implementation of an auth utility that utilizes Permit.io. This README
includes a sample role matrix and the matching Terraform output as an example. To adapt it, add role matrices to
Roles.md, and use a coding assistant (e.g., Copilot) to generate the corresponding Terraform (steps to use Terraform
listed below) based on the provided examples. If helpful, add README.md, Roles.md, and Roles.tf, to your Copilot
context. Here's an example prompt (assumes agentic mode):

```text
Read the sample role matrix and matching Permit.io Terraform code in README.md.  
Read the actual role matrix in Roles.md.  
Generate Terraform code for Permit.io that matches the example’s format, naming conventions, and resource structure, then write it to Roles.tf.
Abort if there are issues parsing the roles from Roles.md.
```

## Using Terraform

> [!IMPORTANT]
> Permit.io might give you sample roles and permissions when you create an account. If you don't clear these you, then
> using Terraform might throw errors with naming conflicts or have other unexpected results. For example, if you get a
> default "Admin" role, then Terraform might throw a fit about you messing with the "Admin" role.

> [!WARNING]
> Terraform keeps tracks of the things it created. If you delete stuff in the portal after creating it with Terraform,
> your local files will be out of sync. You can fix this by removing `.terraform.lock.hcl`, `.terraform` (directory),
`terraform.tfstate`, `terraform.tfstate.backup`, and then running `terraform init` again.

1. [Install the Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
2. Export your API key from Permit.io into an environment variable.
    ```sh
    export TF_VAR_PERMITIO_API_KEY="YOUR API KEY HERE"
    ```
3. Run `terraform init` (this is a one-time step).
4. Run a dry run using `terraform plan`.
5. Run `terraform apply` when you're ready to deploy.

## TODO

- Example of a using Docker compose to use the local policy-deployment model.
- Tests.
- Probably more helpful text in the README.

## Example: Role Permission Matrix

### Project Permissions

| Role   | View | Edit | Delete | Manage Members |
|--------|------|------|--------|----------------|
| Admin  | yes  | yes  | yes    | yes            |
| Member | yes  | yes  | no     | no             |

### Billing Permissions

| Role    | View Invoices | Pay Invoices | Manage Payment Methods |
|---------|---------------|--------------|------------------------|
| Admin   | yes           | yes          | yes                    |
| Finance | yes           | yes          | yes                    |
| Member  | no            | no           | no                     |

## Example: Terraform

```hcl
###############################################################################
# Provider
###############################################################################
terraform {
  required_providers {
    permitio = {
      source  = "registry.terraform.io/permitio/permit-io"
      version = "~> 0.0.14"
    }
  }
}

variable "PERMITIO_API_KEY" {
  type = string
}

provider "permitio" {
  api_url = "https://api.permit.io"
  api_key = var.PERMITIO_API_KEY
}

###############################################################################
# Resources + Actions
###############################################################################

# Project Permissions
resource "permitio_resource" "project" {
  key         = "project"
  name        = "Project"
  description = "Project-scoped operations"
  actions = {
    view = {
      name        = "View"
      description = "View project data"
    }
    edit = {
      name        = "Edit"
      description = "Edit project data"
    }
    delete = {
      name        = "Delete"
      description = "Delete project data"
    }
    manage_members = {
      name        = "Manage Members"
      description = "Manage project membership"
    }
  }
  attributes = {}
}

# Billing Permissions
resource "permitio_resource" "billing" {
  key         = "billing"
  name        = "Billing"
  description = "Billing and payments"
  actions = {
    view_invoices = {
      name        = "View Invoices"
      description = "View invoices"
    }
    pay_invoices = {
      name        = "Pay Invoices"
      description = "Pay invoices"
    }
    manage_payment_methods = {
      name        = "Manage Payment Methods"
      description = "Manage payment methods"
    }
  }
  attributes = {}
}

###############################################################################
# Roles (permissions are "resource:action")
###############################################################################

# Admin: Project (view, edit, delete, manage_members) + Billing (view/pay/manage)
resource "permitio_role" "adminer" {
  key         = "admin"
  name        = "Admin"
  description = "Full access to project and billing"

  permissions = [
    # Billing
    "billing:view_invoices",
    "billing:pay_invoices",
    "billing:manage_payment_methods",
    # Project
    "project:view",
    "project:edit",
    "project:delete",
    "project:manage_members",
  ]

  extends = []
  depends_on = [
    permitio_resource.billing,
    permitio_resource.project
  ]
}

# Member: Project (view, edit); no billing permissions
resource "permitio_role" "member" {
  key         = "member"
  name        = "Member"
  description = "Standard project contributor"

  permissions = [
    "project:view",
    "project:edit",
  ]

  extends = []
  depends_on = [
    permitio_resource.project
  ]
}

# Finance: Billing (view/pay/manage); no project permissions
resource "permitio_role" "finance" {
  key         = "finance"
  name        = "Finance"
  description = "Billing operations access"

  permissions = [
    "billing:view_invoices",
    "billing:pay_invoices",
    "billing:manage_payment_methods",
  ]

  extends = []
  depends_on = [
    permitio_resource.billing
  ]
}
```