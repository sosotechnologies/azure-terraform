# service_principal_app_id = "e90c7fd3-7256-4daf-a2c0-cdb4f66dab7a"
# service_principal_secret = "IhS8Q~DAeSvJh4MJ0dQHiE2pF3XYejdfqrdBvaQ9"
subscription_id         = "02586025-9515-4eac-9a28-cd52e33fbaa4"
tenant_id               = "6c5864a4-4b20-4b29-810e-3fb0ca8ca942"

environment_name        = "prod"

Cafanwii_sshAccess = "Deny" # Allow or Deny

# app_vm_size = "Standard_DS2_v2"
# app_admin_user = "adminuser"





#resource_group_name        = "caranwiterraform"
#environment_name             = "staging"


# # az login --service-principal --username e90c7fd3-7256-4daf-a2c0-cdb4f66dab7a --password IhS8Q~DAeSvJh4MJ0dQHiE2pF3XYejdfqrdBvaQ9 --tenant 6c5864a4-4b20-4b29-810e-3fb0ca8ca942

# az ad sp show --id e90c7fd3-7256-4daf-a2c0-cdb4f66dab7a --query objectId --output tsv

# az role assignment list --assignee <service-principal-object-id>


# ####install

# 
# az graph query -q "servicePrincipals | where appDisplayName == 'cafanwiiPrincipal' | project objectId" --output tsv
# 