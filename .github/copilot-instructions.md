# clean_arch_lint - AI Agent Instructions

## Project Overview

This is an **analyzer plugin** (`analysis_server_plugin`) that enforces Clean Architecture layer boundaries in Flutter/Dart projects by inspecting `import` and `export` directives. It is **not** a `custom_lint` plugin.

Requires Dart SDK >= 3.13. Diagnostics show up in the IDE and in `dart analyze` / `flutter analyze`.

## Architecture

```
lib/
 ├─ core/          → must not import screens or presentation
 ├─ domain/        → only itself + pure Dart libraries (dart:core, async, collection, convert, math, typed_data)
 ├─ data/          → must not import screens or presentation
 ├─ presentation/  → must not import data
 └─ screens/       → must not import data
```

Also detected: `lib/src/{layer}/`, feature-first `lib/features/<feature>/{layer}/` (and under `lib/src/`), and monorepos with one package per layer (`my_app_data`, `my_app_presentation`, ...).

**Rule:** UI must not depend on data implementations; data/core must not depend on UI; domain is inward-only.

### Key Components

1. **Plugin entry** ([lib/main.dart](../lib/main.dart), [lib/clean_arch_lint.dart](../lib/clean_arch_lint.dart))
   - `main.dart` holds the top-level `plugin` loaded by the analysis server
   - `CleanArchitectureLintPlugin.register` calls `registry.registerLintRule(...)` for every rule

2. **Rules** ([lib/src/rules](../lib/src/rules))
   - One rule per diagnostic name: `NoDataDependenciesRule`, `NoScreensDependenciesRule`, `DomainOnlyDependsOnItselfRule`
   - All extend `ArchitectureImportRule`, which visits `ImportDirective` and `ExportDirective` and resolves layers; subclasses implement `diagnosticCodeFor`
   - `AllowThirdPartyPackagesInDomainRule` is an option, not a check: it never reports, and `DomainOnlyDependsOnItselfRule.isAllowedImport` reads whether it is enabled
   - The analyzer runs a rule only when the diagnostic named after `rule.name` is enabled, so each name needs its own rule
   - Former classes (`CoreNoFlutter`, `DataNoPresentation`, `DomainOnly`, `PresentationNoData`, `NoImportVisitor`, `OnlyImportVisitor`) were removed

3. **Codes** ([lib/src/lint_utils.dart](../lib/src/lint_utils.dart))
   - Shared `LintCode.name` values users enable in yaml (`LintNames`)
   - Unique `uniqueName` per message variant

4. **Import resolver** ([lib/src/utils/import_resolver.dart](../lib/src/utils/import_resolver.dart))
   - `layerOf()`, `packageLayerOf()`, `isSameProject()`, `isThirdPartyPackage()`, `isPureDartLibrary()`, `importedUriOf()`, `exportedUriOf()`
   - Layers come from the analyzer's canonical `package:` URIs, not file paths

## Diagnostics

| Code | Severity | Typical trigger |
|------|----------|-----------------|
| `no_data_dependencies` | WARNING* | presentation/screens → data |
| `no_screens_dependencies` | WARNING* | data/core → screens/presentation |
| `domain_only_depends_on_itself` | WARNING* | domain imports anything but domain and pure Dart libraries |

\*Lints are **off until enabled** under `plugins.clean_arch_lint.diagnostics`. Use `error` instead of `true` to raise severity.

`allow_third_party_packages_in_domain` is an option enabled the same way: `domain_only_depends_on_itself` then allows third-party packages (not Flutter SDK packages).

## Development Workflows

```bash
dart test                       # rule tests (analyzer_testing) + resolver tests
dart analyze lib test
dart format lib test            # never `dart format .`

cd example
flutter pub get
dart analyze                    # from the package root; `dart analyze lib` skips plugins
```

Do not run `dart run custom_lint`.

### Adding a check

1. New variant of an existing diagnostic: new `LintCodeArchitecture` listed in that rule's `diagnosticCodes`; new diagnostic name: new `ArchitectureImportRule` subclass, registered and exported in `lib/clean_arch_lint.dart`
2. Enable the name in `example/analysis_options.yaml`
3. Add violations as `example/lib/{layer}/bad_example_*.dart` (CI requires each one to be reported)
4. Tests in `test/rules_test.dart` and `test/import_resolver_test.dart`
5. Update README.md, USAGE.md, RULES.md, CHANGELOG.md and the library dartdoc
6. Dartdoc on public APIs

## Project-Specific Conventions

### Import order

1. `dart:`
2. `package:` (code in `lib/` imports its own files via `package:clean_arch_lint/...`)
3. Relative
4. Alphabetical within each group

### Layer detection

- Layers: `package:<pkg>/{layer}/...` and `package:<pkg>/src/{layer}/...` (i.e. `lib/{layer}/` and `lib/src/{layer}/`), skipping `features/<feature>/`
- Fallback: the `_{layer}` suffix of the package name (`packageLayerOf`), for monorepos with one package per layer
- Only imports from the same project count as project layers (`isSameProject`: same package, or the same name once the layer suffix is stripped)

## Common Gotchas

1. `importedUriOf()` / `exportedUriOf()` need a resolved AST; relative imports are already canonicalized by the analyzer.
2. Pure Dart libraries (`pureDartLibraries`) are allowed everywhere. Other `dart:` libraries and packages of other projects have no layer, so domain reports them and the other layers ignore them.
3. Lint rules registered with `registerLintRule` are disabled by default.
4. After changing `plugins` in yaml, restart the analysis server.
5. `analyzer_testing` pins an exact `analyzer` version; bump them together.

## Dependencies

`analyzer` and `analysis_server_plugin`; see `pubspec.yaml` for the versions.

## When Making Changes

1. One rule per diagnostic name on top of `ArchitectureImportRule`; do not resurrect the old per-layer rule classes
2. Reuse `import_resolver.dart`
3. Keep documentation in sync (README, USAGE, RULES, library dartdoc)
4. Verify with `dart analyze` in `example/`
5. Conventional Commits; update CHANGELOG.md and the `pubspec.yaml` version together
