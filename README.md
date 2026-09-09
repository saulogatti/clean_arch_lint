# clean_arch_lint

Analyzer plugin for **Flutter Clean Architecture**. It inspects `import` directives (AST) and reports layer violations in the IDE and via `dart analyze` / `flutter analyze`.

A single [MultiAnalysisRule](lib/src/rules/no_screens_dependencies_rule.dart) covers every layer, so the analyzer walks each file once.

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

`lib/src/{layer}/` is also detected. No extra configuration.

---

## Layers

### domain

Innermost layer. Other layers may import domain; domain imports only itself (plus Dart SDK). Flutter, `dart:ui`, and third-party packages are reported.

Contains: entities, usecases, contracts.

### core

Shared application code. Must not import `screens` or `presentation`.

Contains: entities, usecases, contracts, business rules.

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

| Code | Blocks |
| --- | --- |
| `no_data_dependencies` | `presentation` or `screens` importing `data`; also `data`/`core` importing those UI layers |
| `no_screens_dependencies` | `data` or `core` importing `screens` or `presentation` |
| `domain_only_depends_on_itself` | `domain` importing anything outside `domain` |

`core_no_flutter`, `core_no_data_or_presentation`, `data_no_presentation`, `presentation_no_data`, and `domain_only` no longer exist as separate rules.

---

## Installation

Requires Dart SDK **>= 3.13** (Flutter 3.38+). This is an `analysis_server_plugin`, not `custom_lint`.

### 1) Enable the plugin

Published:

```yaml
plugins:
  clean_arch_lint:
    version: ^1.3.0
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

Diagnostics also appear in VS Code / Android Studio while you type.

---

## Configuration

### Raise severity

```yaml
plugins:
  clean_arch_lint:
    version: ^1.3.0
    diagnostics:
      no_data_dependencies: error
      domain_only_depends_on_itself: error
      no_screens_dependencies: error
```

### Suppress one line or a file

```dart
// ignore: clean_arch_lint/no_data_dependencies
import 'package:my_app/data/models/product_model.dart';

// ignore_for_file: clean_arch_lint/domain_only_depends_on_itself
```

---

## Examples

Allowed:

```dart
import 'package:my_app/domain/entities/product.dart';
import 'package:my_app/core/entities/product.dart';
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
| domain       | anything outside domain (except Dart SDK) |
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
- `path`

No `custom_lint`, `build_runner`, or `source_gen`.
