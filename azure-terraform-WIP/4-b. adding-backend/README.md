

added:
- backend.tf 

***NOTE:*** You must configure storage before later adding backend and lock. So you muct do 4a before 4b

***Note:*** If you choose to deploy just storage byitself. cd into [storage-optional] and run

```
terraform destroy -target=azurerm_storage_container.cafanwi_container
```
