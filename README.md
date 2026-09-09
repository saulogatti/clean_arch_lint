# clean_arch_lint

Custom lint for **Flutter Clean Architecture**, focused on **enforcing layers** using static analysis (AST) with `custom_lint`.

This package acts as an **architecture guardian**: if a layer depends on something it shouldn't, the error shows up immediately.

---

## 🎯 Objective

Ensure the structure below is automatically respected:

```
lib/
 ├─ core/
 ├─ domain/
 ├─ data/
 └─ presentation/
```

No PR discussions. No "it was unintentional". The lint solves it.

---

## 🧱 Layer Concepts

### core

Pure layer, without Flutter and without infrastructure.

Contains:

- entities
- usecases
- contracts (interfaces)
- business rules

### domain

Innermost layer. Other layers import domain; domain imports only itself (plus Dart SDK, except `dart:ui`).

Contains:

- entities
- usecases
- contracts (interfaces)

### data

Technical implementations.

Contains:

- datasources
- models / DTOs
- mappers
- repository implementations (`Impl`)

### presentation

User interface.

Contains:

- widgets
- pages
- bloc / cubit
- viewmodels / controllers

---

## 🚨 Lint Rules

### 1️⃣ core\_no\_flutter (ERROR)

❌ Prohibits Flutter imports in `core`.

Blocks:

- `package:flutter/*`
- `dart:ui`
- `package:flutter_test/*`

Reason: Core must be completely independent of UI.

---

### 2️⃣ core\_no\_data\_or\_presentation (ERROR)

❌ Prohibits `core` from depending on `data` or `presentation`.

Clean Architecture golden rule:

> Dependencies always point inward.

---

### 3️⃣ data\_no\_presentation (ERROR)

❌ `data` cannot import anything from `presentation`.

Reason:

- Avoids coupling infrastructure with UI
- Ensures testability

---

### 4️⃣ presentation\_no\_data (WARNING configurable)

⚠️ By default, `presentation` **should not depend directly on `data`**.

✔️ Usecases and contracts should come from `core`.

This rule can be configured to **ERROR**.

---

### 5️⃣ domain\_only (WARNING configurable)

⚠️ By default, `domain` **must only depend on itself**.

Allows:

- other files in `lib/domain/` or `lib/src/domain/`
- Dart SDK (`dart:async`, `dart:convert`, `dart:core`, ...) except `dart:ui`

Blocks:

- `data`, `core`, `presentation`
- `package:flutter/*`, `package:flutter_test/*`, `dart:ui`
- third-party packages (`package:equatable`, ...)

This rule can be configured to **ERROR**.

---

## 📦 Installation

### 1) Add dependencies to your Flutter app

```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  clean_arch_lint:
    path: ../clean_arch_lint
    # Or, when published:
    # clean_arch_lint: ^1.0.0
```

> Adjust the `path` according to your repository structure.

---

### 2) Enable the plugin in `analysis_options.yaml`

```yaml
analyzer:
  plugins:
    - custom_lint
```

---

## ▶️ How to Run

```bash
# Single execution
dart run custom_lint

# Watch mode (re-executes when saving files)
dart run custom_lint --watch
```

In VSCode / Android Studio:

- Errors appear automatically in the editor
- Works in real-time as you type

---

## ⚙️ Configuration

### Make `presentation_no_data` an ERROR

```yaml
custom_lint:
  rules:
    - presentation_no_data:
        severity: error
```

---

### Ignore specific paths (example)

```yaml
custom_lint:
  rules:
    - core_no_flutter:
        ignore:
          - lib/core/di/**
```

Useful for very specific cases like DI bootstrap.

---

## ✅ Examples

### Allowed import

```dart
import 'package:my_app/core/usecases/get_user.dart';
```

### Prohibited import (core → flutter)

```dart
import 'package:flutter/material.dart'; // ❌ error
```

### Prohibited import (presentation → data)

```dart
import 'package:my_app/data/user_repository_impl.dart'; // ⚠️ or ❌
```

---

## 🧠 Recommended Best Practices

- Interfaces always in `core`
- Implementations always in `data`
- UI depends only on abstractions
- Dependency injection resolves the rest

---

## ❌ What This Lint Does NOT Do

- Does not generate code
- Does not automatically fix
- Does not replace code review

It only points out the error before it becomes technical debt.

---

## 🧩 Technical Stack

- Dart SDK >= 3.0
- analyzer
- custom\_lint\_builder
- path

No `build_runner`. No `source_gen`.

---

## 🏁 Quick Summary

| Layer        | Can depend on                                      |
| ------------ | -------------------------------------------------- |
| domain       | domain + Dart SDK (except `dart:ui`)               |
| core         | core only (no Flutter)                             |
| data         | core, data                                         |
| presentation | core, presentation                                 |

If it goes beyond that, the lint alerts.

---

## 📁 Supported Structures

The lint automatically supports two folder structures:

### Structure 1: Direct (simple projects)
```
lib/
 ├─ core/
 ├─ domain/
 ├─ data/
 └─ presentation/
```

### Structure 2: With `src/` (larger projects)
```
lib/
 └─ src/
     ├─ core/
     ├─ domain/
     ├─ data/
     └─ presentation/
```

**No additional configuration needed** - the lint automatically detects which structure you're using!

---

Clean architecture is not an opinion. It's a contract.
