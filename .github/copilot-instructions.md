# clean_arch_lint - AI Agent Instructions

## Project Overview

This is an **analyzer plugin** (`analysis_server_plugin`) that enforces Clean Architecture layer boundaries in Flutter/Dart projects by inspecting `import` directives. It is **not** a `custom_lint` plugin.

Requires Dart SDK >= 3.13. Diagnostics show up in the IDE and in `dart analyze` / `flutter analyze`.

## Architecture

```
lib/
 ├─ core/          → must not import screens or presentation
 ├─ domain/        → only itself + Dart SDK
 ├─ data/          → must not import screens or presentation
 ├─ presentation/  → must not import data
 └─ screens/      → must not import data
```

`lib/src/{layer}/` is detected the same way.

**Rule:** UI must not depend on data implementations; data/core must not depend on UI; domain is inward-only.

### Key Components

1. **Plugin entry** ([lib/main.dart](../lib/main.dart))
   - Top-level `plugin` loaded by the analysis server
   - `CleanArchitectureLintPlugin.register` calls `registry.registerLintRule(...)`

2. **Rule** ([lib/src/rules/no_screens_dependencies_rule.dart](../lib/src/rules/no_screens_dependencies_rule.dart))
   - One `MultiAnalysisRule` + one `_Visitor` on `ImportDirective`
   - Former classes (`CoreNoFlutter`, `DataNoPresentation`, `DomainOnly`, `PresentationNoData`, `NoImportVisitor`, `OnlyImportVisitor`) were removed

3. **Codes** ([lib/src/lint_utils.dart](../lib/src/lint_utils.dart))
   - Shared `LintCode.name` values users enable in yaml
   - Unique `uniqueName` per message variant

4. **Import resolver** ([lib/src/utils/import_resolver.dart](../lib/src/utils/import_resolver.dart))
   - `isInLayer()`, `importsFromLayer()`, `resolveImport()`, `isFlutterImport()`

## Diagnostics

| Code | Severity | Typical trigger |
|------|----------|-----------------|
| `no_data_dependencies` | WARNING* | presentation/screens → data; data/core → UI |
| `no_screens_dependencies` | WARNING* | data/core → screens/presentation |
| `domain_only_depends_on_itself` | WARNING* | domain imports anything but domain |

\*Lints are **off until enabled** under `plugins.clean_arch_lint.diagnostics`. Use `error` instead of `true` to raise severity.

## Development Workflows

```bash
dart test

cd example
dart pub get
dart analyze
```

Do not run `dart run custom_lint`.

### Adding a check

1. Prefer a new `LintCodeArchitecture` on `NoScreensDependenciesRule` (keeps one visitor per file)
2. Enable the name in `example/analysis_options.yaml`
3. Add examples in `example/lib/`
4. Update README.md, USAGE.md, RULES.md, CHANGELOG.md
5. Dartdoc on public APIs

## Project-Specific Conventions

### Import order

1. `dart:`
2. `package:`
3. Relative
4. Alphabetical within each group

### Path handling

- Normalize with `normalizePath()` (`/` separators)
- Layers: `/lib/{layer}/` and `/lib/src/{layer}/`

## Common Gotchas

1. `resolveImport()` needs the **full** current file path and a real project root. `shortName` is not a path.
2. `dart:` imports return `null` (treated as allowed). Other `package:` URIs that are not the current package keep the URI as `resolvedPath`.
3. Lint rules registered with `registerLintRule` are disabled by default.
4. After changing `plugins` in yaml, restart the analysis server.

## Dependencies

- `analyzer` ^14.3.0
- `analysis_server_plugin` ^0.3.22
- `path` ^1.9.1

## When Making Changes

1. Match the single-rule visitor; do not resurrect per-layer rule classes without a reason
2. Reuse `import_resolver.dart`
3. Keep documentation in sync (README, USAGE, RULES, library dartdoc)
4. Verify with `dart analyze` in `example/`
5. Conventional Commits; update CHANGELOG.md
