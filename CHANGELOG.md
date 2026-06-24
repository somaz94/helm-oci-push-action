# Changelog

All notable changes to this project will be documented in this file.

## Unreleased (2026-06-24)

### Continuous Integration

- pin Helm version and authenticate setup-helm to reduce CI flakes ([f2a4b02](https://github.com/somaz94/helm-oci-push-action/commit/f2a4b02f60ca6d1937f2e55cd12b4a695a020307))
- add DCO check via shared reusable workflow ([7d8e394](https://github.com/somaz94/helm-oci-push-action/commit/7d8e394a7c3703dcb3a4a8b37d8d6031e947d83b))

### Chores

- **deps:** bump actions/checkout from 6 to 7 (#3) ([#3](https://github.com/somaz94/helm-oci-push-action/pull/3)) ([e6bb891](https://github.com/somaz94/helm-oci-push-action/commit/e6bb891576ebc054b524f4b12c852d79da78556e))
- **deps:** bump alpine from 3.23 to 3.24 in the docker-minor group (#2) ([#2](https://github.com/somaz94/helm-oci-push-action/pull/2)) ([3e7ad91](https://github.com/somaz94/helm-oci-push-action/commit/3e7ad914cee293d62f0a83eec2ea027c67c19b8c))

### Contributors

- somaz

<br/>

## [v1.0.2](https://github.com/somaz94/helm-oci-push-action/compare/v1.0.1...v1.0.2) (2026-06-04)

### Bug Fixes

- harden entrypoint input validation and tarball error handling ([d6b0244](https://github.com/somaz94/helm-oci-push-action/commit/d6b0244acff947f4c8af0bd18da11a4dda72a795))

### Continuous Integration

- add concurrency guards to recurring workflows ([f915a93](https://github.com/somaz94/helm-oci-push-action/commit/f915a93b2bcb920bfc13f5c2490792fbdc33e981))

### Chores

- set CODEOWNERS to @somaz94 ([8559ec0](https://github.com/somaz94/helm-oci-push-action/commit/8559ec07d5b6d089c30c41ebf6276bec8020ad22))

### Contributors

- somaz

<br/>

## [v1.0.1](https://github.com/somaz94/helm-oci-push-action/compare/v1.0.0...v1.0.1) (2026-04-21)

### Code Refactoring

- install latest helm at build time, drop hardcoded v3.16.4 pin ([0a6ab94](https://github.com/somaz94/helm-oci-push-action/commit/0a6ab94a6affe39ddb260307e3b23381585a45ac))

### Documentation

- fix license reference (MIT, matches LICENSE file) ([a64097b](https://github.com/somaz94/helm-oci-push-action/commit/a64097b42c7d09ff162377f9c20e3dbcde8df66c))

### Contributors

- somaz

<br/>

## [v1.0.0](https://github.com/somaz94/helm-oci-push-action/releases/tag/v1.0.0) (2026-04-21)

### Features

- implement helm OCI push container action ([49ddaa4](https://github.com/somaz94/helm-oci-push-action/commit/49ddaa43d31c01e0e46c636fab7373311d06e531))

### Code Refactoring

- **entrypoint:** add ::group:: logging, $GITHUB_OUTPUT guard, username check ([9fa0c08](https://github.com/somaz94/helm-oci-push-action/commit/9fa0c08994fdfea452763938bb4f5675e6ccfbb5))

### Continuous Integration

- bump actions/checkout to v6 (Node.js 20 deprecation) ([79bede4](https://github.com/somaz94/helm-oci-push-action/commit/79bede47e8fdf4fb4c85826c0b524ab89d676968))
- add release, mirror, and changelog workflows ([6f5c694](https://github.com/somaz94/helm-oci-push-action/commit/6f5c6943281166aa4c866d4cf2b0a1b10d6150a6))

### Chores

- add Makefile for local build/test/shellcheck ([0cfb0a2](https://github.com/somaz94/helm-oci-push-action/commit/0cfb0a2ac8d13037571e510da2d8c7a5e4c64074))
- add CLAUDE.md, shorten action description, clean ci ignore_paths ([29202b1](https://github.com/somaz94/helm-oci-push-action/commit/29202b1a50bd007dbca5099e0f2c3babf1532123))
- remove unused container-action template files ([74fd643](https://github.com/somaz94/helm-oci-push-action/commit/74fd6435d45fd63dbabd5eafd8b0b22daa6882e3))

### Contributors

- somaz

<br/>

