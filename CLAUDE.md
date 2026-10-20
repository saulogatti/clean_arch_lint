# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`clean_arch_lint` is a Dart **analyzer plugin** (`analysis_server_plugin`, not `custom_lint`) that protects a
Flutter/Dart app's Clean Architecture by inspecting `import` and `export` directives (AST only, no codegen) and reporting
layer violations in the IDE and in `dart analyze` / `flutter analyze`.

The product is the code in `lib/`. `example/` is only a Flutter app used to see diagnostics fire manually.

## Commands

```powershell
dart pub get
dart test                                             # all tests
dart test test/import_resolver_test.dart --name "layerOf"     # single test by name
dart test test/rules_test.dart --name "test_srcLayout"        # matches the test_* method name
dart analyze lib test
dart format lib test                                  # never `dart format .` (formatter page_width is 100)

# Manual end-to-end check: the example loads the plugin via `path: ../`
cd example; dart pub get; dart analyze
```

Run `dart analyze` on the package root (or on single files) when checking plugin diagnostics: analyzing a directory such as `dart analyze lib` silently skips analyzer plugins (built-in lints still run). This is a Dart SDK limitation (dart-lang/sdk#62710), not a bug in this plugin.

Requires Dart SDK >= 3.13 — the code uses primary constructors (`class _Visitor(final ArchitectureImportRule rule, ...)`)
and dot shorthands (`severity: .WARNING`). After editing plugin code or the `plugins:` section, the Dart Analysis
Server must be restarted for the IDE/example to pick up changes. `docs/` is generated `dart doc` output; don't edit it.

## Architecture

Flow (also diagrammed in `lib/clean_arch_lint.mmd`):

1. `lib/main.dart` — top-level `plugin` variable; the analysis server looks for exactly this.
2. `lib/clean_arch_lint.dart` — `CleanArchitectureLintPlugin.register` registers one rule per diagnostic (`NoDataDependenciesRule`, `NoScreensDependenciesRule`, `DomainOnlyDependsOnItselfRule`) and exports them. `AllowThirdPartyPackagesInDomainRule` is also registered but never reports: it is an option (plugins only accept `diagnostics`). Its `registerNodeProcessors` marks the shared `RuleContext` in an `Expando`, and `DomainOnlyDependsOnItselfRule.isAllowedImport` reads the mark while visiting (every enabled rule registers before any unit is visited). Library dartdoc here mirrors the README.
3. `lib/src/rules/architecture_import_rule.dart` — abstract `MultiAnalysisRule` base. Its `_Visitor` on `ImportDirective` and `ExportDirective` (both go through `_check`) resolves the layer of the current file and of the imported library, then asks the subclass's `diagnosticCodeFor(currentLayer, importedLayer)` which code to report. **One rule per diagnostic name is required**: the analyzer's registry (`analyzer/lib/src/lint/registry.dart`, `enabled`) only runs a rule when the diagnostic named after `rule.name` is enabled, and then filters each code by its own name. A single rule serving several names would make all of them depend on the rule's name being enabled.
4. `lib/src/lint_utils.dart` — `LintCodeArchitecture` constants. `LintCode.name` (from `LintNames`) is the user-facing diagnostic name enabled in `plugins.clean_arch_lint.diagnostics` and used in `// ignore: clean_arch_lint/<name>`; several codes share a `name` and are distinguished by `uniqueName`. Every code must also be listed in the rule's `diagnosticCodes`.
5. `lib/src/utils/import_resolver.dart` — layer detection from the analyzer's **resolved URIs**, no file-system paths. The current file comes from `context.currentUnit?.unit.declaredFragment?.source.uri` and the import/export from `node.libraryImport?.uri` / `node.libraryExport?.uri` (`DirectiveUriWithSource.source.uri`, via `importedUriOf` / `exportedUriOf`). Both are canonical `package:<pkg>/...` URIs for anything under `lib/`, so relative and `package:` imports resolve the same way. `layerOf` reads the layer from `package:<pkg>/{layer}/...` or `package:<pkg>/src/{layer}/...` (`ArchitectureLayer` enum), skipping `features/<feature>/` (`featuresDirectory`) for feature-first layouts; the feature name is ignored, so there is no rule between features. Layers are only matched at those positions: `lib/widgets/data/` is not `data`. When no directory matches, `layerOf` falls back to the package name suffix (`packageLayerOf`: `my_app_data` → `data`) for monorepos with one package per layer. Only imports from the same project count as project layers (`isSameProject`: equal `projectNameOf`, i.e. the package name without its layer suffix, so `my_app`, `my_app_data` and `my_app_presentation` are one project and `firebase_core` is not); `isThirdPartyPackage` uses the same check. `pureDartLibraries` (`dart:core`, `async`, `collection`, `convert`, `math`, `typed_data`) are skipped in every layer; any other `dart:` library (`ui`, `io`, `html`, …) arrives with no layer, so only domain reports it.

Layer policy: domain imports only domain (+ pure Dart libraries); core and data must not import presentation/screens;
presentation and screens must not import data.

### Tests

- `test/rules_test.dart` — real rule tests with `AnalysisRuleTest` (`analyzer_testing`) + `test_reflective_loader`: classes annotated `@reflectiveTest`, methods named `test_*`, registered in `main`. `_ArchitectureRuleTest` writes one type per layer (`lib/{layer}/{layer}_type.dart`) in an in-memory package named `test`, and `assertImports(path, directives, body, reported: [...])` asserts which import directives get the lint. The `body` must use every import, otherwise `unused_import` shows up as an unexpected diagnostic. Other packages come from `newPackage(...)` (`newLayerPackage(layer)` for a sibling `test_{layer}` package) and Flutter/`dart:ui` from `addFlutterPackageDep`, both set before `super.setUp()`. To analyze a file inside a layer package, pass `libPath: newAnalyzedLayerPackage(layer, dependencies: [...])` to `assertImports` (packages from `newPackage` live under `/package/`, outside the analyzed workspace).
- `test/import_resolver_test.dart` — unit tests of the pure URI helpers.
- `analyzer_testing` pins an exact `analyzer` version; bump them together.

## Adding or changing a check (from `.cursor/rules/add-lint-rule.mdc` and CONTRIBUTING)

- Use `AnalysisRule` / `MultiAnalysisRule` + `registerNodeProcessors`, report with `rule.reportAtNode(node, diagnosticCode: ...)`. Never `custom_lint_builder` / `DartLintRule`.
- New message variant of an existing diagnostic → new `LintCodeArchitecture` (same `LintNames` name, unique `uniqueName`) listed in that rule's `diagnosticCodes`. New diagnostic name → new `ArchitectureImportRule` subclass whose `name` is that diagnostic, registered and exported in `lib/clean_arch_lint.dart`. Don't resurrect the removed per-layer rules (`core_no_flutter`, `data_no_presentation`, `presentation_no_data`, `domain_only`).
- Reuse the `import_resolver.dart` helpers (work with resolved URIs, not paths).
- Then: enable the name in `example/analysis_options.yaml`, add good/`bad_example_*.dart` files under `example/lib/{layer}/`, dartdoc the code, and update README.md, USAGE.md, RULES.md, CHANGELOG.md (plus the library dartdoc in `lib/clean_arch_lint.dart`).

## Conventions

- Imports: `dart:`, then `package:`, then relative; alphabetical in each group. Code in `lib/` imports its own files via `package:clean_arch_lint/...`.
- `///` dartdoc on public APIs (Effective Dart, see `.github/instructions/dartcode.instructions.md`).
- Commits: `<type>: <description>` (feat, fix, docs, style, refactor, test); `.github/copilot-commit-message-instructions.md` asks for the description in Portuguese, mentioning changed class names when possible. Update CHANGELOG.md and the `pubspec.yaml` version together.
