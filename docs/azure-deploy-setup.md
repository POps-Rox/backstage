# Azure deploy setup — wiring scaffolded repos to deploy via GitHub Actions OIDC

This runbook covers the **one-time Azure / GitHub configuration** required for
the [POps-Rox Backstage scaffolder templates](../templates/) to drive
`terraform apply` against an Azure subscription. It is the missing half of
Phase 2c — the templates themselves (`templates/azure-workload-template/`,
`templates/azure-resourcegroup-only/`, `templates/azure-landing-zone/`)
already emit a `.github/workflows/terraform.yml` that uses
[`POps-Rox/terraform-gh-actions`](https://github.com/POps-Rox/terraform-gh-actions)
with OIDC-based auth; this doc tells you how to set up the Azure side so that
workflow can actually authenticate.

> **TL;DR** — create a User Assigned Managed Identity (UAMI) per environment,
> bind a federated credential to GitHub's OIDC issuer, assign Azure RBAC, then
> publish the UAMI's client ID / tenant / subscription as **GitHub Actions
> variables** (not secrets) at the org or environment scope.

## Track A vs Track B

| Track | What it is | Status |
| ----- | ---------- | ------ |
| **A (this doc)** | Scaffolded repo's GitHub Actions workflow runs `terraform apply` directly, using GitHub OIDC → Azure UAMI. Backstage's role ends at "repo created". | ✅ Implemented in Phase 2c. |
| **B** | Backstage scaffolder action (`roadiehq/scaffolder-backend-module-terraform` or custom) runs `terraform apply` from inside the Backstage backend. | ⏸ Deferred — Track A delivers the same outcome with one fewer service holding Azure credentials. |

## Architecture

```
Backstage UI ──► (publish:github) ──► POps-Rox/<new-repo>
                                            │
                                            │ workflow_dispatch
                                            ▼
                                  GitHub Actions runner
                                            │  OIDC token
                                            ▼
                              Azure AD federated credential
                                            │
                                            ▼
                          User-Assigned Managed Identity
                                            │  Contributor / UAA
                                            ▼
                                  Target subscription(s)
```

No Azure client secrets are stored anywhere. The federated credential is
scoped to a single GitHub repo (or org) + environment + branch combination,
so a leaked GitHub token cannot be used to mint Azure tokens off-platform.

---

## 1. Create the User Assigned Managed Identity

Per environment (`dev`, `test`, `prod`) — repeat the steps below, swapping the
name suffix. Doing this once per environment lets you give `prod` stricter
RBAC than `dev`.

```bash
# Vars
LOCATION=eastus
ID_RG=popsrox-identity-rg
UAMI_NAME=popsrox-tf-deploy-dev
ENV=dev

# Resource group that owns the identities
az group create -n "$ID_RG" -l "$LOCATION"

# UAMI
az identity create \
  -g "$ID_RG" \
  -n "$UAMI_NAME" \
  -l "$LOCATION"

# Capture the IDs you'll plug into GitHub later
CLIENT_ID=$(az identity show -g "$ID_RG" -n "$UAMI_NAME" --query clientId       -o tsv)
PRINCIPAL=$(az identity show -g "$ID_RG" -n "$UAMI_NAME" --query principalId    -o tsv)
TENANT_ID=$(az identity show -g "$ID_RG" -n "$UAMI_NAME" --query tenantId       -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "AZURE_CLIENT_ID=$CLIENT_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
```

> For the **landing-zone** template (four subscriptions) you can either
> create one UAMI per subscription and switch which one the workflow uses,
> or create a single UAMI and grant it Contributor on all four. Multi-UAMI
> is recommended for production; the workflow file already accepts a per-
> environment override of `AZURE_SUBSCRIPTION_ID`.

## 2. Add federated credentials

Create one federated credential per GitHub *environment* you want the
identity to be usable from. The subject claim has to match exactly what
the GitHub OIDC issuer emits.

```bash
GITHUB_ORG=POps-Rox
GITHUB_REPO="*"   # use a specific repo name for per-repo isolation

az identity federated-credential create \
  -g "$ID_RG" \
  --identity-name "$UAMI_NAME" \
  --name "github-${ENV}" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:${ENV}" \
  --audiences "api://AzureADTokenExchange"
```

Subject formats reference (use **exactly one** per federated credential):

| Trigger | Subject claim |
| ------- | ------------- |
| GitHub Environment (recommended for `terraform apply`) | `repo:OWNER/REPO:environment:ENV_NAME` |
| Push to a branch | `repo:OWNER/REPO:ref:refs/heads/BRANCH` |
| Any pull request | `repo:OWNER/REPO:pull_request` |
| Any tag | `repo:OWNER/REPO:ref:refs/tags/TAG` |

> Azure AD does **not** support wildcards in the subject. If you want one
> identity usable by many scaffolded repos, create one federated credential
> per repo, or scope at the *org* level by registering a workflow-claim-based
> credential — see [Microsoft docs][fed-creds].

## 3. Assign Azure RBAC

The terraform-apply step typically needs:

| Role | Scope | Why |
| ---- | ----- | --- |
| `Contributor` | Subscription **or** the target RG | Create / update / delete resources |
| `User Access Administrator` | Same scope | The overlays often add role assignments (e.g. Key Vault Secrets User on a managed identity) |
| `Storage Blob Data Contributor` | The remote-state storage account | Read/write the `*.tfstate` blob |

```bash
TARGET_SUB=$SUBSCRIPTION_ID                    # or set to a different sub ID
SCOPE_SUB="/subscriptions/$TARGET_SUB"
STATE_SA_ID=$(az storage account show -g popsrox-remotestate-rg -n popsroxtfstate --query id -o tsv)

az role assignment create --assignee-object-id "$PRINCIPAL" --assignee-principal-type ServicePrincipal \
  --role "Contributor"                --scope "$SCOPE_SUB"
az role assignment create --assignee-object-id "$PRINCIPAL" --assignee-principal-type ServicePrincipal \
  --role "User Access Administrator"  --scope "$SCOPE_SUB"
az role assignment create --assignee-object-id "$PRINCIPAL" --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" --scope "$STATE_SA_ID"
```

For production, prefer **RG-scoped** Contributor + UAA over subscription-
scoped. The umbrella `azure-workload-template` writes resources into a single
RG named `${org}-${name}-${env}-rg`, so you can pre-create that RG and scope
the assignment there.

## 4. Wire up GitHub

The scaffolded workflow reads three **GitHub Actions variables** (not
secrets — they are not sensitive once OIDC is in place):

| Name | Where | Value |
| ---- | ----- | ----- |
| `AZURE_CLIENT_ID` | Org variable | UAMI client ID |
| `AZURE_TENANT_ID` | Org variable | Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Org variable, can be overridden at the *environment* level | Target subscription |
| `TF_STATE_RG`        | Org variable | Remote-state RG (from `terraform-overlays-remotestate`) |
| `TF_STATE_SA`        | Org variable | Remote-state storage account |
| `TF_STATE_CONTAINER` | Org variable | Remote-state container (typically `tfstate`) |

```bash
gh variable set AZURE_CLIENT_ID       --org POps-Rox --visibility all --body "$CLIENT_ID"
gh variable set AZURE_TENANT_ID       --org POps-Rox --visibility all --body "$TENANT_ID"
gh variable set AZURE_SUBSCRIPTION_ID --org POps-Rox --visibility all --body "$SUBSCRIPTION_ID"
gh variable set TF_STATE_RG           --org POps-Rox --visibility all --body popsrox-remotestate-rg
gh variable set TF_STATE_SA           --org POps-Rox --visibility all --body popsroxtfstate
gh variable set TF_STATE_CONTAINER    --org POps-Rox --visibility all --body tfstate
```

### Per-environment overrides

Create a GitHub Environment per `dev` / `test` / `prod` on each scaffolded
repo (or set them up once on the org via `gh api`). Override
`AZURE_SUBSCRIPTION_ID` (and optionally `AZURE_CLIENT_ID` if you have one
UAMI per environment) at the environment scope:

```bash
gh api -X PUT \
  repos/POps-Rox/<scaffolded-repo>/environments/prod
gh variable set AZURE_SUBSCRIPTION_ID \
  --repo POps-Rox/<scaffolded-repo> --env prod --body "<prod-subscription-id>"
```

Add **required reviewers** on the `prod` environment to force human
approval before `terraform apply` runs against production. Backstage's
"Run workflow" UI (or `gh workflow run`) will pause until the reviewer
approves the deployment.

## 5. Deploy from Backstage

Once everything above is in place, scaffolded repos can be deployed without
any further configuration:

1. In Backstage, **Create…** → pick a POps-Rox template → fill the form →
   submit. Backstage runs `fetch:template` → `publish:github` →
   `catalog:register`.
2. Browse to the new repo's **Actions** tab → select **terraform** →
   **Run workflow** → pick `environment` (`dev` / `test` / `prod`) and
   `action` (`plan` / `apply`) → **Run workflow**.
3. The workflow:
   - Mints a GitHub OIDC token,
   - Exchanges it for an Azure AD token via the federated credential,
   - Runs `terraform plan` or `terraform apply` against the chosen
     subscription with state in the remote-state storage account.

Equivalent CLI:

```bash
gh workflow run terraform.yml \
  --repo POps-Rox/<scaffolded-repo> \
  -f environment=dev \
  -f action=apply
```

## 6. Troubleshooting

| Symptom | Likely cause | Fix |
| ------- | ------------ | --- |
| `AADSTS70021: No matching federated identity record found` | Subject claim doesn't match — usually wrong env name or missing GitHub Environment | Verify the federated credential subject equals exactly `repo:POps-Rox/<repo>:environment:<env>` |
| `RoleAssignmentRequestId conflicts` from a UAA-scoped role | UAMI is missing `User Access Administrator` | Re-run the role-assignment step against the correct scope |
| Workflow stuck at "Waiting for review" | GitHub Environment has required reviewers | Approve in the **Deployments** tab |
| `Error: building AzureRM Client: obtain subscription` | OIDC env vars not exported on the job | Confirm the workflow's `env:` block reads `vars.AZURE_*` and that those vars exist at org or environment scope |

## 7. Track B follow-up (deferred)

To run `terraform apply` from *inside* Backstage (no GitHub Actions hop):

1. `yarn add @roadiehq/scaffolder-backend-module-terraform` in
   `packages/backend`.
2. Register the action in `packages/backend/src/plugins/scaffolder.ts`.
3. Mount an Azure UAMI on the Backstage pod (Workload Identity on AKS) and
   set `ARM_USE_MSI=true` / `ARM_SUBSCRIPTION_ID`.
4. Replace the scaffolded repo's workflow apply step with a Backstage step
   `roadiehq:terraform:apply`.

This puts the Azure credential surface back inside Backstage and is only
worth doing once Backstage itself has a hardened identity story (Phase 4+).

[fed-creds]: https://learn.microsoft.com/azure/active-directory/workload-identities/workload-identity-federation-create-trust
