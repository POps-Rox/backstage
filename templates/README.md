# POps-Rox Backstage Scaffolder Templates

This directory holds the **Backstage software templates** used to provision new
Azure workloads on top of the [POps-Rox terraform overlays](https://github.com/POps-Rox)
at **v2.0.0** (Terraform ≥ 1.10, azurerm 4.x).

| Template | Use it when… |
| -------- | ------------ |
| [`azure-workload-template/`](./azure-workload-template/) | You want a multi-module Azure workload and want to cherry-pick which overlays (resource group, storage, key vault, AKS, etc.) get wired up. |
| [`azure-resourcegroup-only/`](./azure-resourcegroup-only/) | You just need an empty Azure resource group as a placeholder / isolation boundary. |
| [`azure-landing-zone/`](./azure-landing-zone/) | You're standing up a new SCCA-style enclave with hub network + management hub + management spoke + initial workload spoke. |

Every template:

* Scaffolds a brand-new GitHub repo under `POps-Rox`.
* Pins module sources to `?ref=v2.0.0`.
* Includes a `.github/workflows/terraform.yml` that uses
  [`POps-Rox/terraform-gh-actions`](https://github.com/POps-Rox/terraform-gh-actions)
  `terraform-plan@v1.0.0` and `terraform-apply@v1.0.0`, **authenticating to
  Azure via GitHub OIDC** (no client secrets — see
  [`docs/azure-deploy-setup.md`](../docs/azure-deploy-setup.md) for the
  one-time UAMI + federated-credential bootstrap).
* Exposes a `workflow_dispatch` trigger so deploys can be kicked off from
  the repo's GitHub Actions UI or via `gh workflow run terraform.yml -f environment=dev -f action=apply`.
* Documents the Azure Storage remote-state backend wiring in `backend.tf`
  (the actual values come from
  [`terraform-overlays-remotestate`](https://github.com/POps-Rox/terraform-overlays-remotestate)).
* Emits a Backstage `catalog-info.yaml` and auto-registers the new repo with
  `catalog:register`.

## How the templates are wired into Backstage

`backstage/app-config.yaml` registers each `template.yaml` as a `catalog.locations`
entry with `rules: [{ allow: [Template] }]`. Re-loading the catalog (or
restarting the backend) makes them appear under **Create…** in the UI.

## Adding a new template

1. Copy one of the existing folders (the umbrella template is the most complete
   reference).
2. Edit `template.yaml`'s `parameters`, `steps`, and `output` blocks.
3. Edit `content/` — files are processed through Backstage's
   [nunjucks template syntax](https://backstage.io/docs/features/software-templates/writing-templates),
   with values from `parameters` exposed as `${{ values.foo }}`.
4. Register the new `template.yaml` in `backstage/app-config.yaml` under
   `catalog.locations`.

Phase 2b of the POps-Rox Go-To-Market initiative. Phase 2c adds the OIDC /
`workflow_dispatch` wiring documented in
[`docs/azure-deploy-setup.md`](../docs/azure-deploy-setup.md).
