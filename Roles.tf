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