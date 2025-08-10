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

# Data Operations Resource
resource "permitio_resource" "data" {
  key         = "data"
  name        = "Data"
  description = "Data operations"
  actions = {
    ingest = {
      name        = "Ingest"
      description = "Ingest data into the system"
    }
    search = {
      name        = "Search"
      description = "Search for data in the system"
    }
  }
  attributes = {}
}

# Tenant Management Resource
resource "permitio_resource" "tenant" {
  key         = "tenant"
  name        = "Tenant"
  description = "Tenant management operations"
  actions = {
    create_tenants = {
      name        = "Create Tenants"
      description = "Create new tenants in the system"
    }
  }
  attributes = {}
}

###############################################################################
# Roles (permissions are "resource:action")
###############################################################################

# Agent: Can Ingest data but cannot Search or Create Tenants
resource "permitio_role" "agent" {
  key         = "agent"
  name        = "Agent"
  description = "Can only ingest data"

  permissions = [
    "data:ingest"
  ]

  extends = []
  depends_on = [
    permitio_resource.data
  ]
}

# System: Full access to all operations (Ingest, Search, Create Tenants)
resource "permitio_role" "system" {
  key         = "system"
  name        = "System"
  description = "Full system access"

  permissions = [
    "data:ingest",
    "data:search",
    "tenant:create_tenants"
  ]

  extends = []
  depends_on = [
    permitio_resource.data,
    permitio_resource.tenant
  ]
}

# User: Can only Search, cannot Ingest or Create Tenants
resource "permitio_role" "user" {
  key         = "user"
  name        = "User"
  description = "Standard user with search access"

  permissions = [
    "data:search"
  ]

  extends = []
  depends_on = [
    permitio_resource.data
  ]
}
