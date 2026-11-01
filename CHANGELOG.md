# Changelog

All notable changes to this project are recorded here.
Versioning follows Semantic Versioning.

## [Unreleased]

### Added
- Repository scaffolding: folder layout, formatting rules, PR and issue templates
- docs/SRS.md added at v0.2 (Ubuntu/WSL2 as primary environment)
- Makefile build with automatic header dependency tracking
- Test harness (CHECK, CHECK_EQUAL) and `make test`
- Sanitizer build (`make sanitize`) using AddressSanitizer and UndefinedBehaviorSanitizer
- Formatting targets (`make format`, `make format-check`)
- GitHub Actions CI on Ubuntu 26.04
