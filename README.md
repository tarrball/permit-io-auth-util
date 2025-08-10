# Auth Utility using Permit.io

## Purpose

This utility provides an example implementation of an auth utility that integrates
with [Permit.io](https://permit.io).  
The README includes:

- A **sample role matrix**
- The **matching Terraform output** for Permit.io

You can adapt this by:

1. Creating a `Roles.md` file with your actual role matrix.
2. Using a coding assistant (e.g., Copilot) to generate matching Terraform based on the provided example.
3. Optionally adding `README.md`, `Roles.md`, and `Roles.tf` to your Copilot context.

**Example Copilot prompt** (assumes *agentic mode* where Copilot can read/write files):

```text
Read the sample role matrix and matching Permit.io Terraform code in README.md.
Read the actual role matrix in Roles.md.
Generate Terraform code for Permit.io that matches the example’s format, naming conventions, and resource structure.
Write the output to Roles.tf (overwriting if it exists). Abort if there are issues parsing the roles from Roles.md.
```

## Using Terraform

> [!IMPORTANT]
> Permit.io often creates sample roles and permissions when you first set up an account.
> If you don’t delete these before running Terraform, you may run into naming conflicts or unexpected behavior.
> For example: a preexisting "Admin" role in the dashboard may cause Terraform to fail when trying to create its own "
> Admin" role.

> [!WARNING]
> Terraform tracks the resources it creates in state.
> If you delete a resource directly in the Permit.io dashboard, Terraform’s state will be out of sync.
> To reset your local state, remove:
> • .terraform.lock.hcl
> • .terraform/
> • terraform.tfstate
> • terraform.tfstate.backup
>
> Then run terraform init again.

1. [Install the Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

2. Export your API key from Permit.io into an environment variable.
    ```sh
    export TF_VAR_PERMITIO_API_KEY="YOUR API KEY HERE"
    ```

3. Run
   ```sh
   terraform init
   ```
   _(First-time setup for this project)_

4. Preview changes:
   ```sh
   terraform plan
   ```

5. Apply changes:
   ```sh
   terraform apply
   ```

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
resource "permitio_role" "admin" {
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

## TODO

- Example of a using Docker compose to use the local policy-deployment model.
- Tests.