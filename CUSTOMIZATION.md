# 🔧 Customization Guide

This Backstage instance is designed to be forked and deployed by any organization.
Below are all the configuration points you need to update when setting up your own deployment.

## Quick Start

1. Fork the entire [POps-Rox](https://github.com/POps-Rox) organization
2. Update the configuration points below
3. Set environment variables
4. Deploy with `backstage-bootstrap`

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GITHUB_TOKEN` | GitHub PAT with `repo` and `read:org` scopes | ✅ |
| `GITHUB_CLIENT_ID` | GitHub OAuth App client ID | ✅ |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth App client secret | ✅ |
| `POSTGRES_HOST` | PostgreSQL host (production only) | Production |
| `POSTGRES_PORT` | PostgreSQL port (production only) | Production |
| `POSTGRES_USER` | PostgreSQL user (production only) | Production |
| `POSTGRES_PASSWORD` | PostgreSQL password (production only) | Production |
| `APP_BASE_URL` | Frontend URL (production only) | Production |
| `BACKEND_BASE_URL` | Backend URL (production only) | Production |

## Configuration Points

All customization points are marked with `✏️ CUSTOMIZE` comments in the config files.

### `app-config.yaml`
- **`organization.name`** — Your org display name
- **`catalog.providers.github.popsRoxOrg.organization`** — Your GitHub org name

### `app-config.production.yaml`
- **`app.baseUrl`** — Your production frontend URL
- **`backend.baseUrl`** — Your production backend URL
- **`catalog.providers.github.popsRoxOrg.organization`** — Your GitHub org name

### `catalog-entities/all.yaml`
- **System entity** — Update description to match your platform
- **Group entity** — Update team name, description, and members
- **Resource entity** — Update GitHub org link

### `catalog-info.yaml` (in every repo)
- **`spec.owner`** — Change `platform-ops-team` to your Backstage group name
- **`spec.system`** — Change `pops-rox-platform` if you renamed the system
- **`metadata.annotations.github.com/project-slug`** — Update org name prefix

## Creating a GitHub OAuth App

1. Go to your GitHub org → Settings → Developer settings → OAuth Apps → New OAuth App
2. Set **Homepage URL** to your Backstage URL
3. Set **Authorization callback URL** to `<your-backstage-url>/api/auth/github/handler/frame`
4. Copy the Client ID and Client Secret to your environment variables
