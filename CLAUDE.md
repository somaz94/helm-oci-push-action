# CLAUDE.md

<br/>

## Project Structure

- Shell-based GitHub Action (Docker container action)
- Pushes Helm charts to any OCI registry (GHCR, ECR, GAR, Harbor, Quay, Artifactory)
- Three input modes: `tarballs` glob, `charts` comma-separated paths, `charts_dir` auto-scan
- Built-in `helm registry login`, `dry_run`, `skip_existing`, `continue_on_error`

<br/>

## Key Files

- `action.yml` — GitHub Action definition (11 inputs, 2 outputs, `runs.using: docker`)
- `Dockerfile` — alpine 3.23 + latest stable helm (resolved at build time via GitHub releases API; `HELM_VERSION` ARG defaults to `latest`, override for a pinned version)
- `entrypoint.sh` — main push logic (`$INPUT_*` env vars, writes to `$GITHUB_OUTPUT` and `$GITHUB_STEP_SUMMARY`)
- `cliff.toml` — git-cliff conventional commit groups for release notes

<br/>

## Build & Test

```bash
docker build -t helm-oci-push-action:local .
docker run --rm --entrypoint helm helm-oci-push-action:local version --short

# Dry-run with a fixture chart
docker run --rm \
  -v "$PWD/fixtures:/github/workspace/fixtures" -w /github/workspace \
  -e INPUT_CHARTS=fixtures/charts/test-chart \
  -e INPUT_REGISTRY=oci://ghcr.io/somaz94/test \
  -e INPUT_REGISTRY_LOGIN=false \
  -e INPUT_DRY_RUN=true \
  -e GITHUB_OUTPUT=/dev/stdout \
  helm-oci-push-action:local
```

<br/>

## Workflows

- `ci.yml` — shellcheck + docker build + matrix(`tarballs`/`charts`/`charts_dir`) dry-run verification
- `release.yml` — git-cliff release notes + `softprops/action-gh-release` + `somaz94/major-tag-action` for v1 sliding tag
- `use-action.yml` — post-release smoke tests against `oci://ghcr.io/<owner>/test-helm-oci-push`
- `gitlab-mirror.yml`, `changelog-generator.yml`, `contributors.yml`, `dependabot-auto-merge.yml`, `issue-greeting.yml`, `stale-issues.yml` — standard repo automation

<br/>

## Release

Push a `vX.Y.Z` tag → `release.yml` runs → GitHub release published → `v1` major tag updated → `use-action.yml` smoke-tests the published version.

<br/>

## Action Inputs

Key inputs: `tarballs`, `charts`, `charts_dir` (one required), `registry` (default GHCR), `registry_login`, `username`, `password`, `dry_run`, `skip_existing`, `continue_on_error`. See [README.md](README.md) for the full table.
