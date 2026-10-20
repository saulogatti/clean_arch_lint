---
name: add-lint-check
description: Checklist for adding or changing a clean_arch_lint diagnostic, message variant or layer rule (lib/src/rules, lint_utils.dart, example, docs).
---

# Adding or changing a check

Mirrors `.cursor/rules/add-lint-rule.mdc` and CONTRIBUTING.

- Use `AnalysisRule` / `MultiAnalysisRule` + `registerNodeProcessors`, report with `rule.reportAtNode(node, diagnosticCode: ...)`. Never `custom_lint_builder` / `DartLintRule`.
- New message variant of an existing diagnostic → new `LintCodeArchitecture` (same `LintNames` name, unique `uniqueName`) listed in that rule's `diagnosticCodes`. New diagnostic name → new `ArchitectureImportRule` subclass whose `name` is that diagnostic, registered and exported in `lib/clean_arch_lint.dart`. Don't resurrect the removed per-layer rules (`core_no_flutter`, `data_no_presentation`, `presentation_no_data`, `domain_only`).
- Reuse the `import_resolver.dart` helpers (work with resolved URIs, not paths).
- Then: enable the name in `example/analysis_options.yaml`, add good/`bad_example_*.dart` files under `example/lib/{layer}/` (CI fails unless exactly the `bad_example_*.dart` files are reported) with a row in `example/README.md`, dartdoc the code, and update README.md, USAGE.md, RULES.md, CHANGELOG.md (plus the library dartdoc in `lib/clean_arch_lint.dart`).
- Tests: rule cases in `test/rules_test.dart`, resolver behavior in `test/import_resolver_test.dart`.
