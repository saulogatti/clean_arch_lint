# Usage Guide - clean_arch_lint

How to use `clean_arch_lint` in a Flutter/Dart project.

## Installation

This package is an **analyzer plugin** (`analysis_server_plugin`), not `custom_lint`. Requires Dart SDK >= 3.13.

### 1. Enable the plugin

In the **root** `analysis_options.yaml` (plugins are not inherited from nested options files unless you `include` a file that already lists them):

```yaml
plugins:
  clean_arch_lint:
    version: ^3.1.0
    diagnostics:
      no_data_dependencies: true
      domain_only_depends_on_itself: true
      no_screens_dependencies: true
```

Local checkout:

```yaml
plugins:
  clean_arch_lint:
    path: ../clean_arch_lint
    diagnostics:
      no_data_dependencies: true
      domain_only_depends_on_itself: true
      no_screens_dependencies: true
```

Restart the Dart Analysis Server after any change to `plugins`.

### 2. Run analysis

```bash
dart analyze
# or
flutter analyze
```

---

## Layer structure

Three folder layouts are detected automatically.

### Direct (simple projects)

```
lib/
 ├─ core/
 ├─ domain/
 ├─ data/
 ├─ presentation/
 └─ screens/
```

### With `src/` (larger projects)

```
lib/
 └─ src/
     ├─ core/
     ├─ domain/
     ├─ data/
     ├─ presentation/
     └─ screens/
```

### Feature-first

```
lib/
 ├─ core/
 └─ features/
     ├─ cart/
     │   ├─ domain/
     │   ├─ data/
     │   └─ presentation/
     └─ product/
         ├─ domain/
         ├─ data/
         └─ presentation/
```

Also detected under `lib/src/features/`. The layer is the directory right after `features/<feature>/`; files directly in the feature folder (`features/cart/cart.dart`) belong to no layer. There is no rule between features: `features/cart/presentation` importing `features/product/data` is reported as `presentation` importing `data`, and importing `features/product/domain` is allowed.

### Monorepo with one package per layer

```
packages/
 ├─ my_app/                 # app, layer directories optional
 ├─ my_app_core/
 ├─ my_app_domain/
 ├─ my_app_data/
 └─ my_app_presentation/
```

A package whose name ends in `_core`, `_domain`, `_data`, `_presentation` or `_screens` is a layer package: its files belong to that layer, unless they sit in a layer directory (`my_app_data/lib/domain/` is `domain`). Packages sharing the prefix (`my_app`) form one project, so `my_app_presentation` importing `package:my_app_data/my_app_data.dart` is reported by `no_data_dependencies`, and `my_app_domain` importing `my_app_core` by `domain_only_depends_on_itself`. Packages with another prefix (`firebase_core`, `other_data`) stay outside the project's layers, and count as third-party for [`allow_third_party_packages_in_domain`](#allow-third-party-packages-in-domain).

The `plugins` section belongs to each package's own `analysis_options.yaml` (or one shared file it `include`s).

> A single-package app whose name ends in a layer suffix (for example `shop_core`) is treated as a layer package too: files outside layer directories, such as `lib/main.dart`, get that layer.

---

## Diagnostics

All codes are WARNING lints. They stay off until listed under `plugins.clean_arch_lint.diagnostics`.

Every rule checks `export` directives the same way as imports, so `export 'package:my_app/data/models/product_model.dart';` in `presentation` is reported too.

### 1. `no_data_dependencies`

**What it does:** Stops UI (`presentation`, `screens`) from depending on infrastructure (`data`).

**Typical violations:**

- `presentation/**` or `screens/**` importing `data`

**Why:** Presentation and screens should talk to domain/core contracts.

```dart
// ❌ presentation/pages/product_page.dart
import 'package:my_app/data/models/product_model.dart';
```

```dart
// ✅ presentation depends on a domain/core type
import 'package:my_app/domain/entities/product_entity.dart';
```

---

### 2. `no_screens_dependencies`

**What it does:** Stops `data` (and `core`) from importing `screens` or `presentation`.

**Why:** Infrastructure must not instantiate UI.

```dart
// ❌ data/repositories/product_repository_impl.dart
import 'package:my_app/presentation/pages/product_page.dart';
```

---

### 3. `domain_only_depends_on_itself`

**What it does:** Domain may import only other domain files.

**Allows:** `lib/domain/**`, `lib/src/domain/**`, and the pure Dart libraries `dart:core`, `dart:async`, `dart:collection`, `dart:convert`, `dart:math`, `dart:typed_data`.

**Blocks:** `data`, `core`, `presentation`, `screens`, `package:flutter/*`, other `dart:` libraries (`dart:ui`, `dart:io`, `dart:html`, `dart:ffi`, …), third-party packages (unless `allow_third_party_packages_in_domain` is enabled, see below).

```dart
// ❌ domain/usecases/get_product_use_case.dart
import 'package:my_app/data/models/product_model.dart';
import 'package:flutter/material.dart';
```

```dart
// ✅
import 'dart:async';
import 'package:my_app/domain/entities/product_entity.dart';
```

---

## Advanced configuration

### Make a diagnostic an error

```yaml
plugins:
  clean_arch_lint:
    version: ^3.1.0
    diagnostics:
      no_data_dependencies: error
      domain_only_depends_on_itself: true
      no_screens_dependencies: true
```

### Allow third-party packages in domain

Third-party packages are reported in `domain` by default. Enable `allow_third_party_packages_in_domain` to allow them:

```yaml
plugins:
  clean_arch_lint:
    version: ^3.1.0
    diagnostics:
      domain_only_depends_on_itself: true
      allow_third_party_packages_in_domain: true
```

```dart
// ✅ domain/entities/product_entity.dart, with the option enabled
import 'package:equatable/equatable.dart';
```

The option reports nothing by itself and has no effect unless `domain_only_depends_on_itself` is enabled. Flutter SDK packages (`flutter`, `flutter_test`, …), `dart:ui`, `dart:io` and other layers are still reported.

### Ignore a line or a file

```dart
// ignore: clean_arch_lint/no_data_dependencies
import '../data/models/product_model.dart';
```

```dart
// ignore_for_file: clean_arch_lint/domain_only_depends_on_itself
```

Use `ignore` only in documented exceptions.

---

## CI/CD

```yaml
name: Analyze

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1

      - name: Install dependencies
        run: dart pub get

      - name: Analyze
        run: dart analyze
```

`dart analyze` / `flutter analyze` load the plugin. Do **not** run `dart run custom_lint`.

---

## Troubleshooting

### Plugin not loading

1. Plugin is listed in the **root** `analysis_options.yaml` under `plugins:` (not under `analyzer.plugins`).
2. Lint diagnostics are explicitly `true` (or `error`).
3. Dart Analysis Server was restarted after the `plugins` change.
4. SDK is >= 3.13.

### "No issues" but the import is illegal

1. File lives under `lib/{layer}/`, `lib/src/{layer}/` or `lib/features/<feature>/{layer}/` (also under `lib/src/features/`), or in a layer package (`my_app_data`).
2. The matching diagnostic is enabled.
3. Relative and `package:` imports of the **same** package are both resolved. Other packages only have layers when they belong to the same project (`my_app_data` next to `my_app_presentation`). Pure Dart libraries (`dart:core`, `dart:async`, `dart:collection`, `dart:convert`, `dart:math`, `dart:typed_data`) are allowed in every layer; other `dart:` libraries are only reported in `domain`.
4. You are analyzing the package root, a single file, or several files — not a directory. `dart analyze lib` or `dart analyze lib/presentation` silently skips analyzer plugins (only built-in lints run), a Dart SDK limitation tracked in [dart-lang/sdk#62710](https://github.com/dart-lang/sdk/issues/62710). Run `dart analyze` (or `flutter analyze`) from the package root instead.

---

## Examples

See `example/`:

- Valid files under `core/`, `domain/`, `data/`, `presentation/`, `screens/`
- Violations in `bad_example_*.dart`

```bash
cd example
dart pub get
dart analyze
```
