# Changelog

All notable changes to this project will be documented in this file.

## [v1.2.0](https://github.com/somaz94/helm-oci-push-action/compare/v1.1.0...v1.2.0) (2026-11-12)

### Features

- retry failed helm pushes with backoff and report failed_charts ([c660193](https://github.com/somaz94/helm-oci-push-action/commit/c6601932c5ec4b4ed150674b0f993d6928e508d7))

### Continuous Integration

- adopt the shared git-cliff template to skip changelog commits and duplicate lines ([32be9a5](https://github.com/somaz94/helm-oci-push-action/commit/32be9a55e73d14c1482de0bd7a7e5a05b20b6e36))
- correct stale image-seeding comments ([890ba49](https://github.com/somaz94/helm-oci-push-action/commit/890ba490e3299981881c16f90ca1b2ff44fe4827))
- trim redundant comments in gitlab-mirror workflow ([ffda73f](https://github.com/somaz94/helm-oci-push-action/commit/ffda73fb6404e570e3358464825f999c631c4c72))
- correct the image-seeding comment in the release workflow ([1d81da9](https://github.com/somaz94/helm-oci-push-action/commit/1d81da9d16f468a83a752d5e3ac3ce881f78728f))
- retry mirror pushes on transient remote failures ([924dbfa](https://github.com/somaz94/helm-oci-push-action/commit/924dbfa8b63daa4a0973a7a9f463d023a87f6db1))
- drop the dead issue-close trigger from changelog generation ([a2e9a91](https://github.com/somaz94/helm-oci-push-action/commit/a2e9a91682504aff42203bc9cabed196c8105f9e))
- skip release-triggered runs on the image-seeding dispatch ([1170640](https://github.com/somaz94/helm-oci-push-action/commit/1170640e89f63e79c3b90c37ec8f69b7c887a878))

### Chores

- bump the action image to v1.2.0 ([beb8704](https://github.com/somaz94/helm-oci-push-action/commit/beb870447986fd9cd3a44338dd63528a0edab328))
- drop Node.js boilerplate from .gitignore ([76cd407](https://github.com/somaz94/helm-oci-push-action/commit/76cd40700f65a2a722f9f925e1a20082a4abda17))
- trim redundant comments in CODEOWNERS ([55c211f](https://github.com/somaz94/helm-oci-push-action/commit/55c211f171ab455139a90543ec92ccf9259290c6))

### Contributors

- somaz

<br/>

## [v1.1.0](https://github.com/somaz94/helm-oci-push-action/compare/v1.0.2...v1.1.0) (2026-08-07)

### Bug Fixes

- fetch helm on the build platform so the arm64 image builds without emulation ([6163690](https://github.com/somaz94/helm-oci-push-action/commit/61636900eeeb40dc9158a2c48b22aab7d11bfa4c))
- resolve helm latest via get.helm.sh to avoid GitHub API rate limit ([438970a](https://github.com/somaz94/helm-oci-push-action/commit/438970a81559ee8fdbb3e268def06ca41bee334c))

### Performance Improvements

- ship a prebuilt multi-arch image instead of building per run ([3d5364a](https://github.com/somaz94/helm-oci-push-action/commit/3d5364a75b9578ae11b582a228001489ba625f0b))

### Continuous Integration

- remove DCO workflow ([89fb70c](https://github.com/somaz94/helm-oci-push-action/commit/89fb70cbde9d529b8ed118c6ca9ad7f87721dc6c))
- adopt semantic-pr, labels, lock-threads, PR size, and auto-assign reusables ([1423e52](https://github.com/somaz94/helm-oci-push-action/commit/1423e529393abcbcce283d351688caf7246a99ad))
- use reusable stale-issues workflow ([9d5d1bd](https://github.com/somaz94/helm-oci-push-action/commit/9d5d1bd12310d6d5d9ab8d6a0340c4f0ab611327))
- use reusable issue-greeting workflow ([02c310d](https://github.com/somaz94/helm-oci-push-action/commit/02c310daff95f67be6dd53d63dc293d254cd659a))
- use reusable dependabot-auto-merge workflow ([fad8371](https://github.com/somaz94/helm-oci-push-action/commit/fad8371d2643dd69b70a68bf32df493a191fac59))
- use reusable contributors workflow ([9a37e8c](https://github.com/somaz94/helm-oci-push-action/commit/9a37e8c085bbb78506af67fda03fbef332f50665))
- add ok-to-test workflow stub ([53bf7d8](https://github.com/somaz94/helm-oci-push-action/commit/53bf7d8a829dff50f5f7b0c7dd1f7688a595ec68))
- add PR welcome workflow stub ([531af39](https://github.com/somaz94/helm-oci-push-action/commit/531af3965d258ee91e27988c169dedfd1e901917))
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

