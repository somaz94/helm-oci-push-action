#!/usr/bin/env bash
set -euo pipefail

# Helm OCI Push GitHub Action
# Reads $INPUT_* environment variables defined in action.yml.

log()      { echo "==> $*"; }
log_info() { echo "::notice::$*"; }
log_warn() { echo "::warning::$*"; }
log_err()  { echo "::error::$*" >&2; }

is_true() {
  case "${1:-}" in
    1|true|TRUE|True|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

# ---- Read inputs ----
TARBALLS_GLOB="${INPUT_TARBALLS:-}"
CHARTS_CSV="${INPUT_CHARTS:-}"
CHARTS_DIR="${INPUT_CHARTS_DIR:-}"
REGISTRY="${INPUT_REGISTRY:-}"
REGISTRY_LOGIN="${INPUT_REGISTRY_LOGIN:-true}"
USERNAME="${INPUT_USERNAME:-}"
PASSWORD="${INPUT_PASSWORD:-}"
DRY_RUN="${INPUT_DRY_RUN:-false}"
SKIP_EXISTING="${INPUT_SKIP_EXISTING:-false}"
CONTINUE_ON_ERROR="${INPUT_CONTINUE_ON_ERROR:-false}"

if [[ -z "$REGISTRY" ]]; then
  log_err "Input 'registry' is required."
  exit 1
fi

if [[ -z "$TARBALLS_GLOB" && -z "$CHARTS_CSV" && -z "$CHARTS_DIR" ]]; then
  log_err "At least one of inputs 'tarballs', 'charts', 'charts_dir' must be provided."
  exit 1
fi

# ---- Login ----
if is_true "$REGISTRY_LOGIN"; then
  if [[ -z "$PASSWORD" ]]; then
    log_err "registry_login is true but 'password' is empty."
    exit 1
  fi
  REGISTRY_HOST=$(echo "$REGISTRY" | sed -E 's|^oci://||; s|/.*$||')
  log "Login to $REGISTRY_HOST as ${USERNAME:-<unset>}"
  printf '%s' "$PASSWORD" | helm registry login "$REGISTRY_HOST" \
    --username "${USERNAME:-}" --password-stdin
else
  log "registry_login=false; assuming caller has already logged in."
fi

# ---- Stage tarballs ----
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT

# Extract chart name + version from a packaged tarball's Chart.yaml.
tgz_meta() {
  local tgz="$1" tmp chart_yaml name version
  tmp=$(mktemp -d)
  tar -xzf "$tgz" -C "$tmp"
  chart_yaml=$(find "$tmp" -maxdepth 2 -name 'Chart.yaml' | head -n1)
  if [[ -z "$chart_yaml" ]]; then
    rm -rf "$tmp"
    log_err "No Chart.yaml found inside $tgz"
    return 1
  fi
  name=$(awk '/^name:/ {print $2; exit}' "$chart_yaml" | tr -d '"')
  version=$(awk '/^version:/ {print $2; exit}' "$chart_yaml" | tr -d '"')
  rm -rf "$tmp"
  echo "$name $version"
}

declare -a TARBALLS=()

# (a) tarballs glob
if [[ -n "$TARBALLS_GLOB" ]]; then
  shopt -s nullglob
  # shellcheck disable=SC2206
  GLOB_MATCHES=( $TARBALLS_GLOB )
  shopt -u nullglob
  for f in "${GLOB_MATCHES[@]}"; do
    [[ -f "$f" ]] && TARBALLS+=("$f")
  done
fi

# (b) charts: comma-separated chart directory paths
if [[ -n "$CHARTS_CSV" ]]; then
  IFS=',' read -ra CHART_PATHS <<< "$CHARTS_CSV"
  for cp in "${CHART_PATHS[@]}"; do
    cp="${cp#"${cp%%[![:space:]]*}"}"
    cp="${cp%"${cp##*[![:space:]]}"}"
    [[ -z "$cp" ]] && continue
    if [[ ! -d "$cp" ]]; then
      log_err "Chart path not found: $cp"
      exit 1
    fi
    log "Packaging $cp"
    helm package "$cp" -d "$STAGING_DIR"
  done
fi

# (c) charts_dir: scan subdirectories that contain Chart.yaml
if [[ -n "$CHARTS_DIR" ]]; then
  if [[ ! -d "$CHARTS_DIR" ]]; then
    log_err "charts_dir not found: $CHARTS_DIR"
    exit 1
  fi
  for d in "$CHARTS_DIR"/*/; do
    [[ -d "$d" && -f "$d/Chart.yaml" ]] || continue
    log "Packaging ${d%/}"
    helm package "${d%/}" -d "$STAGING_DIR"
  done
fi

# Collect freshly packaged tarballs
shopt -s nullglob
for f in "$STAGING_DIR"/*.tgz; do
  TARBALLS+=("$f")
done
shopt -u nullglob

if [[ ${#TARBALLS[@]} -eq 0 ]]; then
  log_warn "No chart tarballs to push (no matches and no charts to package)."
  echo "pushed_charts=" >> "$GITHUB_OUTPUT"
  echo "skipped_charts=" >> "$GITHUB_OUTPUT"
  exit 0
fi

# ---- Push ----
declare -a PUSHED=()
declare -a SKIPPED=()

REGISTRY_TRIMMED="${REGISTRY%/}"

for tgz in "${TARBALLS[@]}"; do
  read -r name version < <(tgz_meta "$tgz")
  ref="$name:$version"

  if is_true "$SKIP_EXISTING"; then
    if helm show chart "${REGISTRY_TRIMMED}/${name}" --version "$version" >/dev/null 2>&1; then
      log "[skip] $ref already exists in $REGISTRY"
      SKIPPED+=("$ref")
      continue
    fi
  fi

  if is_true "$DRY_RUN"; then
    log "[dry-run] would push $ref to $REGISTRY"
    SKIPPED+=("$ref")
    continue
  fi

  log "Pushing $ref to $REGISTRY"
  if helm push "$tgz" "$REGISTRY"; then
    PUSHED+=("$ref")
  else
    log_err "Failed to push $ref"
    if is_true "$CONTINUE_ON_ERROR"; then
      log_warn "continue_on_error=true; moving on"
      continue
    fi
    exit 1
  fi
done

# ---- Outputs ----
join_csv() { local IFS=','; echo "$*"; }

PUSHED_CSV=""
SKIPPED_CSV=""
[[ ${#PUSHED[@]} -gt 0 ]] && PUSHED_CSV=$(join_csv "${PUSHED[@]}")
[[ ${#SKIPPED[@]} -gt 0 ]] && SKIPPED_CSV=$(join_csv "${SKIPPED[@]}")

echo "pushed_charts=${PUSHED_CSV}" >> "$GITHUB_OUTPUT"
echo "skipped_charts=${SKIPPED_CSV}" >> "$GITHUB_OUTPUT"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## Helm OCI Push"
    echo ""
    echo "Registry: \`$REGISTRY\`"
    echo ""
    echo "| Status | Chart |"
    echo "|--------|-------|"
    for r in "${PUSHED[@]}"; do echo "| pushed | \`$r\` |"; done
    for r in "${SKIPPED[@]}"; do echo "| skipped | \`$r\` |"; done
  } >> "$GITHUB_STEP_SUMMARY"
fi

log "Done. Pushed: ${#PUSHED[@]}, Skipped: ${#SKIPPED[@]}"
