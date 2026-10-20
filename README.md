# clean_arch_lint

[![pub package](https://img.shields.io/pub/v/clean_arch_lint.svg)](https://pub.dev/packages/clean_arch_lint)
[![pub points](https://img.shields.io/pub/points/clean_arch_lint)](https://pub.dev/packages/clean_arch_lint/score)
[![CI](https://github.com/saulogatti/clean_arch_lint/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/saulogatti/clean_arch_lint/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/saulogatti/clean_arch_lint/branch/main/graph/badge.svg)](https://codecov.io/gh/saulogatti/clean_arch_lint)
[![license](https://img.shields.io/github/license/saulogatti/clean_arch_lint)](LICENSE)

Analyzer plugin for **Flutter Clean Architecture**. It inspects `import` and `export` directives (AST) and reports layer violations in the IDE and via `dart analyze` / `flutter analyze`.

Each diagnostic is its own rule (see [lib/src/rules](lib/src/rules)), so it can be enabled or disabled independently. All of them share the layer resolution in [ArchitectureImportRule](lib/src/rules/architecture_import_rule.dart).

---

## Objective

Keep this structure honest:

```
lib/
 ├─ core/
 ├─ domain/
 ├─ data/
 ├─ presentation/
 └─ screens/
```

`lib/src/{layer}/` is also detected, and so is a feature-first layout, `lib/features/<feature>/{layer}/` (or `lib/src/features/<feature>/{layer}/`). No extra configuration.

In a feature-first layout the feature name plays no part in the checks: imports between features follow the same layer rules as any other import, so `features/cart/presentation` may import `features/product/domain` but not `features/product/data`.

Monorepos with one package per layer are detected by the package name suffix: `my_app_domain`, `my_app_data`, `my_app_presentation`, `my_app_core`, `my_app_screens` (and `my_app` itself) form one project, so `my_app_presentation` importing `package:my_app_data/...` is reported. Packages of another project that just end in a layer name, such as `firebase_core`, are not layers. Enable the plugin in each package's `analysis_options.yaml`.

---

## Layers

### domain

Innermost layer. Other layers may import domain; domain imports only itself plus the pure Dart libraries (`dart:core`, `dart:async`, `dart:collection`, `dart:convert`, `dart:math`, `dart:typed_data`). Flutter, other `dart:` libraries (`dart:ui`, `dart:io`, `dart:html`, …), and third-party packages are reported. Third-party packages can be allowed with [`allow_third_party_packages_in_domain`](#allow-third-party-packages-in-domain).

Contains: entities, usecases, contracts.

### core

Shared application code with no business rule, usable by every layer except domain. Must not import `screens` or `presentation`.

Contains: utils, extensions, constants, shared services (logging, configuration).

### data

Infrastructure. Must not import `screens` or `presentation`.

Contains: datasources, models / DTOs, mappers, repository implementations.

### presentation

UI that is not a screen entrypoint. Must not import `data`.

Contains: widgets, pages, bloc / cubit, viewmodels.

### screens

Screen-level UI. Must not import `data`.

Contains: screens / routes that compose presentation and domain.

---

## Diagnostics

All of them are **WARNING** lint rules. Analyzer plugins disable lints until you turn them on.

`export` directives are checked like imports: re-exporting a forbidden library leaks it to every file that imports the exporting one.

| Code | Blocks |
| --- | --- |
| `no_data_dependencies` | `presentation` or `screens` importing `data` |
| `no_screens_dependencies` | `data` or `core` importing `screens` or `presentation` |
| `domain_only_depends_on_itself` | `domain` importing anything outside `domain`, except pure Dart libraries |

`allow_third_party_packages_in_domain` is an option, not a check; see [Configuration](#allow-third-party-packages-in-domain).

`core_no_flutter`, `core_no_data_or_presentation`, `data_no_presentation`, `presentation_no_data`, and `domain_only` no longer exist as separate rules.

---

## Installation

Requires Dart SDK **>= 3.13** (use a Flutter release that ships Dart 3.13 or newer). This is an `analysis_server_plugin`, not `custom_lint`.

### 1) Enable the plugin

Published:

```yaml
plugins:
  clean_arch_lint:
    version: ^3.1.0
    diagnostics:
      no_data_dependencies: true
      domain_only_depends_on_itself: true
      no_screens_dependencies: true
```

Local path (see `example/analysis_options.yaml`):

```yaml
plugins:
  clean_arch_lint:
    path: ../clean_arch_lint
    diagnostics:
      no_data_dependencies: true
      domain_only_depends_on_itself: true
      no_screens_dependencies: true
```

Restart the Dart Analysis Server after changing the `plugins` section.

### 2) Run analysis

```bash
dart analyze
# or
flutter analyze
```

Run it from the package root (or pass single files). Analyzing a directory, such as `dart analyze lib`, silently skips analyzer plugins: only the built-in lints run. This is a Dart SDK limitation ([dart-lang/sdk#62710](https://github.com/dart-lang/sdk/issues/62710)).

Diagnostics also appear in VS Code / Android Studio while you type.

---

## Configuration

### Raise severity

```yaml
plugins:
  clean_arch_lint:
    version: ^3.1.0
    diagnostics:
      no_data_dependencies: error
      domain_only_depends_on_itself: error
      no_screens_dependencies: error
```

### Allow third-party packages in domain

By default `domain_only_depends_on_itself` reports every third-party package in `domain`. To allow them (`equatable`, `fpdart`, `meta`, …), enable `allow_third_party_packages_in_domain`:

```yaml
plugins:
  clean_arch_lint:
    version: ^3.1.0
    diagnostics:
      domain_only_depends_on_itself: true
      allow_third_party_packages_in_domain: true
```

It never reports anything by itself; it only changes `domain_only_depends_on_itself`. Flutter SDK packages (`flutter`, `flutter_test`, …), `dart:ui`, `dart:io` and the project's other layers stay reported. The `plugins` section only accepts `diagnostics`, so the option is a diagnostic name.

### Suppress one line or a file

```dart
// ignore: clean_arch_lint/no_data_dependencies
import 'package:my_app/data/models/product_model.dart';

// ignore_for_file: clean_arch_lint/domain_only_depends_on_itself
```

---

## Examples

See [example/](example/) for a working feature split across all layers, with one intentional violation per layer (including a relative import), two violations suppressed with `// ignore`, and a naming convention that makes the layer of each class obvious from its suffix (`ProductEntity`, `ProductModel`, `ProductRepositoryImpl`, `ProductPage`, ...).

Allowed:

```dart
import 'package:my_app/domain/entities/product_entity.dart';
import 'package:my_app/core/utils/price_formatter_util.dart';
```

Forbidden (`presentation` → `data`):

```dart
import 'package:my_app/data/models/product_model.dart'; // no_data_dependencies
```

Forbidden (`domain` → Flutter):

```dart
import 'package:flutter/material.dart'; // domain_only_depends_on_itself
```

---

## Dependency flow

| Layer        | Must not import                         |
| ------------ | --------------------------------------- |
| domain       | anything outside domain (except pure Dart libraries) |
| core         | screens, presentation                   |
| data         | screens, presentation                   |
| presentation | data                                    |
| screens      | data                                    |

---

## What this plugin does not do

- Does not generate code
- Does not auto-fix imports
- Does not replace code review

---

## Stack

- Dart SDK >= 3.13
- `analysis_server_plugin`
- `analyzer`

No `custom_lint`, `build_runner`, or `source_gen`.
