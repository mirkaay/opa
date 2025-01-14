package terraform.resource_group_location

# Define the allowed locations as a set
allowed_locations = {"East US", "West US", "Central US"}

# Define a deny rule for disallowed locations
deny contains msg if {
  input.resource_changes[_].type == "azurerm_resource_group"
  location := input.resource_changes[_].change.after.location
  not location in allowed_locations
  msg := sprintf("Location '%v' is not allowed for resource groups.", [location])
}