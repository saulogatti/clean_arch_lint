# Usage Guide - clean_arch_lint

How to use `clean_arch_lint` in a Flutter/Dart project.

## Installation

This package is an **analyzer plugin** (`analysis_server_plugin`), not `custom_lint`. Requires Dart SDK >= 3.13.

### 1. Enable the plugin

In the **root** `analysis_options.yaml` (plugins are not inherited from nested options files unless you `include` a file that already lists them):

```yaml
plugins:
  clean_arch_lint:
    version: ^1.3.0
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

Two folder layouts are detected automatically.

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

---

## Diagnostics

All codes are WARNING lints. They stay off until listed under `plugins.clean_arch_lint.diagnostics`.

### 1. `no_data_dependencies`

**What it does:** Stops UI from depending on infrastructure, and infrastructure from depending on UI.

**Typical violations:**

- `presentation/**` or `screens/**` importing `data`
- `data/**` or `core/**` importing `presentation` or `screens`

**Why:** Presentation and screens should talk to domain/core contracts. Data must not know about widgets.

```dart
// ❌ presentation/pages/product_page.dart
import 'package:my_app/data/models/product_model.dart';
```

```dart
// ✅ presentation depends on a domain/core type
import 'package:my_app/domain/entities/product.dart';
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

**Allows:** `lib/domain/**`, `lib/src/domain/**`, Dart SDK (`dart:async`, `dart:convert`, …).

**Blocks:** `data`, `core`, `presentation`, `screens`, `package:flutter/*`, `dart:ui`, third-party packages.

```dart
// ❌ domain/usecases/get_product.dart
import 'package:my_app/data/models/product_model.dart';
import 'package:flutter/material.dart';
```

```dart
// ✅
import 'dart:async';
import 'package:my_app/domain/entities/product.dart';
```

---

## Advanced configuration

### Make a diagnostic an error

```yaml
plugins:
  clean_arch_lint:
    version: ^1.3.0
    diagnostics:
      no_data_dependencies: error
      domain_only_depends_on_itself: true
      no_screens_dependencies: true
```

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

1. File lives under `lib/{layer}/` or `lib/src/{layer}/`.
2. The matching diagnostic is enabled.
3. Relative and `package:` imports of the **same** package are both resolved; `dart:` imports are ignored by the resolver (allowed).

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
