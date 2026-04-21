# helm-oci-push-action

[![CI](https://github.com/somaz94/helm-oci-push-action/actions/workflows/ci.yml/badge.svg)](https://github.com/somaz94/helm-oci-push-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Latest Tag](https://img.shields.io/github/v/tag/somaz94/helm-oci-push-action)](https://github.com/somaz94/helm-oci-push-action/tags)
[![Top Language](https://img.shields.io/github/languages/top/somaz94/helm-oci-push-action)](https://github.com/somaz94/helm-oci-push-action)
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Helm%20OCI%20Push-blue?logo=github)](https://github.com/marketplace/actions/helm-oci-push)

A GitHub Action that pushes Helm charts to any OCI registry (GHCR, ECR, GAR, Harbor, Quay, Artifactory). Supports pre-packaged tarball globs, comma-separated chart paths, and directory scans — all from a single step.

<br/>

## Features

- Push to **any OCI registry** (GHCR by default, plus ECR, GAR, Harbor, Quay, Artifactory, ...)
- Three input modes: **`tarballs`** glob, **`charts`** comma-separated paths, **`charts_dir`** auto-scan
- **Dry-run** mode for PR validation without publishing
- **Skip existing** chart versions to make releases idempotent
- **`continue_on_error`** to keep going when one chart fails
- Built-in `helm registry login` (or skip and let your workflow handle it)
- Self-contained Docker action — `helm` is bundled, no `azure/setup-helm` required

<br/>

## Quick Start

```yaml
- name: Push chart to GHCR
  uses: somaz94/helm-oci-push-action@v1
  with:
    charts: ./helm/my-app
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

## Usage

### 1. Push pre-packaged tarballs (most common)

Use this when an earlier step already produced `.tgz` files (e.g., `helm package` to a staging directory, or `chart-releaser-action`).

```yaml
- name: Package
  run: helm package ./helm/my-app -d /tmp/staging

- name: Push to GHCR
  uses: somaz94/helm-oci-push-action@v1
  with:
    tarballs: /tmp/staging/*.tgz
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

### 2. Package and push a single chart

```yaml
- uses: somaz94/helm-oci-push-action@v1
  with:
    charts: ./helm/my-app
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

### 3. Package and push multiple charts

```yaml
- uses: somaz94/helm-oci-push-action@v1
  with:
    charts: charts/foo,charts/bar,charts/baz
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

### 4. Auto-scan a directory of charts

Every immediate subdirectory containing a `Chart.yaml` is packaged and pushed.

```yaml
- uses: somaz94/helm-oci-push-action@v1
  with:
    charts_dir: charts
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

### 5. Combine with `chart-releaser-action`

`chart-releaser-action` emits `changed_charts` as a comma-separated list — feed it directly to the `charts` input.

```yaml
- name: Run chart-releaser
  id: cr
  uses: helm/chart-releaser-action@v1.7.0
  with:
    charts_dir: charts
    skip_existing: true
  env:
    CR_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- name: Push released charts to GHCR
  if: steps.cr.outputs.changed_charts != ''
  uses: somaz94/helm-oci-push-action@v1
  with:
    charts: ${{ steps.cr.outputs.changed_charts }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

### 6. Push to a non-GHCR registry (Harbor / ECR / etc.)

When you've already authenticated via a provider-specific action (e.g., `aws-actions/amazon-ecr-login`), set `registry_login: false`.

```yaml
- name: Login to ECR
  uses: aws-actions/amazon-ecr-login@v2

- uses: somaz94/helm-oci-push-action@v1
  with:
    tarballs: dist/*.tgz
    registry: oci://123456789012.dkr.ecr.us-east-1.amazonaws.com/charts
    registry_login: false
```

<br/>

### 7. Dry-run for PR validation

Package and validate without publishing — perfect for PR checks.

```yaml
- uses: somaz94/helm-oci-push-action@v1
  with:
    charts_dir: charts
    dry_run: true
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

### 8. Skip existing versions

Make releases idempotent — chart versions already present in the registry are skipped.

```yaml
- uses: somaz94/helm-oci-push-action@v1
  with:
    charts_dir: charts
    skip_existing: true
    password: ${{ secrets.GITHUB_TOKEN }}
```

<br/>

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `tarballs` | Glob pattern for pre-packaged chart tarballs (e.g., `dist/*.tgz`) | No | `''` |
| `charts` | Comma-separated chart directory paths to package and push | No | `''` |
| `charts_dir` | Directory whose immediate subdirectories are packaged and pushed | No | `''` |
| `registry` | Target OCI registry URL | No | `oci://ghcr.io/${{ github.repository_owner }}/charts` |
| `registry_login` | Run `helm registry login` inside the action | No | `true` |
| `username` | Registry username | No | `${{ github.actor }}` |
| `password` | Registry password / token (typically `secrets.GITHUB_TOKEN` for GHCR) | No | `''` |
| `dry_run` | Package and validate but do not push | No | `false` |
| `skip_existing` | Skip chart@version pairs already in the registry (best-effort) | No | `false` |
| `continue_on_error` | Continue with the next chart when a push fails | No | `false` |

At least one of `tarballs`, `charts`, or `charts_dir` must be provided.

<br/>

## Outputs

| Output | Description |
|--------|-------------|
| `pushed_charts` | Comma-separated `name:version` pairs actually pushed |
| `skipped_charts` | Comma-separated `name:version` pairs skipped (existing or dry-run) |

Example:

```yaml
- id: push
  uses: somaz94/helm-oci-push-action@v1
  with:
    charts_dir: charts
    skip_existing: true
    password: ${{ secrets.GITHUB_TOKEN }}

- run: |
    echo "Pushed: ${{ steps.push.outputs.pushed_charts }}"
    echo "Skipped: ${{ steps.push.outputs.skipped_charts }}"
```

<br/>

## Login Behavior

By default the action runs `helm registry login` against the host portion of `registry`. If `password` is empty, the step fails with a clear error.

Set `registry_login: false` when:

- A previous step already authenticated (e.g., `docker/login-action`, `aws-actions/amazon-ecr-login`, `google-github-actions/auth`).
- You want to use a non-username/password auth flow your provider supports.

<br/>

## Permissions

For pushing to GHCR with the default `${{ secrets.GITHUB_TOKEN }}`, the calling workflow needs:

```yaml
permissions:
  contents: read
  packages: write
```

<br/>

## Helm Version

The action installs the **latest stable Helm** at image build time (resolved via the GitHub releases API). To pin a specific version, fork the repo and override the `HELM_VERSION` build arg in the `Dockerfile` (e.g., `ARG HELM_VERSION=v3.16.4`).

<br/>

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
