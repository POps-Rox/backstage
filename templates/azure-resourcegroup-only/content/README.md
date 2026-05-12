# ${{ values.name }}

Minimal Azure resource group provisioned by the POps-Rox
`terraform-az-overlays-resourcegroup` overlay at **v2.0.0**.

| Setting | Value |
| ------- | ----- |
| Org prefix     | `${{ values.org_name }}` |
| Environment    | `${{ values.environment }}` |
| Location       | `${{ values.location }}` |
| Resource locks | `${{ values.enable_resource_locks }}` (`${{ values.lock_level }}`) |

## Quickstart

```bash
az login
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

> The scaffold does **not** declare a remote-state backend — for shared use,
> add a `backend.tf` pointing at your `terraform-overlays-remotestate` storage.
