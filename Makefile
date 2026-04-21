.PHONY: build shellcheck fixtures test test-charts test-charts-dir test-tarballs clean help

IMAGE         := helm-oci-push-action:local
FIXTURE_DIR   := fixtures
DIST_DIR      := dist
TEST_REGISTRY := oci://ghcr.io/somaz94/test

DOCKER_RUN := docker run --rm \
	-v $$(pwd):/github/workspace -w /github/workspace \
	-e INPUT_REGISTRY=$(TEST_REGISTRY) \
	-e INPUT_REGISTRY_LOGIN=false \
	-e INPUT_DRY_RUN=true \
	-e INPUT_USERNAME= -e INPUT_PASSWORD= \
	-e INPUT_SKIP_EXISTING=false \
	-e INPUT_CONTINUE_ON_ERROR=false

## Build

build: ## Build the action Docker image
	docker build -t $(IMAGE) .

## Quality

shellcheck: ## Run shellcheck on entrypoint.sh (uses dockerized shellcheck, no host install needed)
	docker run --rm -v $$(pwd):/mnt -w /mnt koalaman/shellcheck:stable entrypoint.sh

## Fixtures

fixtures: ## Create a local fixture chart used by all test targets
	@mkdir -p $(FIXTURE_DIR)/charts/test-chart/templates
	@printf 'apiVersion: v2\nname: test-chart\nversion: 0.1.0\nappVersion: "1.0.0"\ndescription: local fixture\ntype: application\n' > $(FIXTURE_DIR)/charts/test-chart/Chart.yaml
	@printf 'apiVersion: v1\nkind: ConfigMap\nmetadata:\n  name: test-chart\ndata:\n  hello: world\n' > $(FIXTURE_DIR)/charts/test-chart/templates/configmap.yaml

## Test (dry-run only; no real registry push)

test: build fixtures test-charts test-charts-dir test-tarballs ## Build image, prep fixtures, run all dry-run tests
	@echo "[PASS] all local tests"

test-charts: build fixtures ## Verify 'charts' input mode (dry-run)
	@out=$$($(DOCKER_RUN) -e INPUT_TARBALLS= -e INPUT_CHARTS=$(FIXTURE_DIR)/charts/test-chart -e INPUT_CHARTS_DIR= $(IMAGE) 2>&1); \
		echo "$$out" | grep -q 'dry-run.*test-chart:0.1.0' && echo "[PASS] charts mode"

test-charts-dir: build fixtures ## Verify 'charts_dir' input mode (dry-run)
	@out=$$($(DOCKER_RUN) -e INPUT_TARBALLS= -e INPUT_CHARTS= -e INPUT_CHARTS_DIR=$(FIXTURE_DIR)/charts $(IMAGE) 2>&1); \
		echo "$$out" | grep -q 'dry-run.*test-chart:0.1.0' && echo "[PASS] charts_dir mode"

test-tarballs: build fixtures ## Verify 'tarballs' input mode (pre-packages a chart first, then dry-run)
	@mkdir -p $(DIST_DIR)
	@docker run --rm -v $$(pwd):/w -w /w --entrypoint helm $(IMAGE) package $(FIXTURE_DIR)/charts/test-chart -d $(DIST_DIR)/ >/dev/null
	@out=$$($(DOCKER_RUN) -e 'INPUT_TARBALLS=$(DIST_DIR)/*.tgz' -e INPUT_CHARTS= -e INPUT_CHARTS_DIR= $(IMAGE) 2>&1); \
		echo "$$out" | grep -q 'dry-run.*test-chart:0.1.0' && echo "[PASS] tarballs mode"

## Cleanup

clean: ## Remove fixtures, packaged charts, and the local image
	rm -rf $(FIXTURE_DIR) $(DIST_DIR)
	-docker rmi $(IMAGE) 2>/dev/null || true

## Help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
