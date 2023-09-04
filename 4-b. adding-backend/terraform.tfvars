# service_principal_app_id = "e90c7fd3-7256-4daf-a2c0-cdb4f66dab7a"
# service_principal_secret = "IhS8Q~DAeSvJh4MJ0dQHiE2pF3XYejdfqrdBvaQ9"
subscription_id         = "2758777e-d279-4b89-b058-dfbf61c1e250"
tenant_id               = "6c5864a4-4b20-4b29-810e-3fb0ca8ca942"
#resource_group_name        = "caranwiterraform"
#environment_name             = "staging"


# # az login --service-principal --username e90c7fd3-7256-4daf-a2c0-cdb4f66dab7a --password IhS8Q~DAeSvJh4MJ0dQHiE2pF3XYejdfqrdBvaQ9 --tenant 6c5864a4-4b20-4b29-810e-3fb0ca8ca942

# az ad sp show --id e90c7fd3-7256-4daf-a2c0-cdb4f66dab7a --query objectId --output tsv

# az role assignment list --assignee <service-principal-object-id>


# ####install

# ```
# az graph query -q "servicePrincipals | where appDisplayName == 'cafanwiiPrincipal' | project objectId" --output tsv
# ```