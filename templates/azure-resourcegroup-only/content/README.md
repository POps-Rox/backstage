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

## Deploy to Azure

The scaffolded repo includes `.github/workflows/terraform.yml`, which uses
**GitHub OIDC** to authenticate to Azure via a User-Assigned Managed
Identity (no long-lived secrets). Required GitHub Actions variables:

| Name | Scope | Purpose |
| ---- | ----- | ------- |
| `AZURE_CLIENT_ID`        | org var | Federated UAMI client ID |
| `AZURE_TENANT_ID`        | org var | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID`  | org var | Target subscription |

See [`backstage/docs/azure-deploy-setup.md`](https://github.com/POps-Rox/backstage/blob/main/docs/azure-deploy-setup.md)
for the one-time UAMI + federated-credential + RBAC bootstrap.

Then:

1. Open the repo on GitHub → **Actions** → **terraform** →
   **Run workflow** → pick `environment` and `action = apply`.
2. Or via CLI: `gh workflow run terraform.yml -f environment=dev -f action=apply`
