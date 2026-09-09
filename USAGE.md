# Usage Guide - clean_arch_lint

This guide shows how to use `clean_arch_lint` in your Flutter/Dart projects.

## Installation

### 1. Add dependencies to your project

In your Flutter app's `pubspec.yaml` file:

```yaml
dev_dependencies:
  custom_lint: ^0.8.1
  clean_arch_lint:
    path: ../clean_arch_lint  # Adjust the path as needed
    # Or, when published:
    # clean_arch_lint: ^1.0.0
```

### 2. Configure the analyzer

In your `analysis_options.yaml` file:

```yaml
analyzer:
  plugins:
    - custom_lint
```

### 3. Run the lint

```bash
# Single execution
dart run custom_lint

# Watch mode (re-executes when saving files)
dart run custom_lint --watch
```

---

## Layer Structure

The lint supports two folder structures:

### Structure 1: Direct (recommended for simple projects)
```
lib/
 ├─ core/          # Pure business logic
 │   ├─ entities/
 │   └─ usecases/
 ├─ domain/        # Innermost layer (only itself + Dart SDK)
 │   ├─ entities/
 │   └─ usecases/
 ├─ data/          # Technical implementations
 │   ├─ models/
 │   ├─ datasources/
 │   └─ repositories/
 └─ presentation/  # User interface
     ├─ pages/
     ├─ widgets/
     └─ controllers/
```

### Structure 2: With `src/` (common in larger projects)
```
lib/
 └─ src/
     ├─ core/          # Pure business logic
     │   ├─ entities/
     │   └─ usecases/
     ├─ domain/        # Innermost layer (only itself + Dart SDK)
     │   ├─ entities/
     │   └─ usecases/
     ├─ data/          # Technical implementations
     │   ├─ models/
     │   ├─ datasources/
     │   └─ repositories/
     └─ presentation/  # User interface
         ├─ pages/
         ├─ widgets/
         └─ controllers/
```

**Note:** The lint automatically detects which structure you're using. Both are fully supported!

---

## Lint Rules

### 1. core_no_flutter (ERROR)

**What it does:** Prohibits Flutter imports in the `core` layer.

**Blocks:**
- `package:flutter/*`
- `package:flutter_test/*`
- `dart:ui`

**Why:** The core should be completely independent of UI, allowing:
- Pure unit tests (without depending on Flutter)
- Logic reusability on other platforms
- Clear separation of concerns

**Violation example:**
```dart
// ❌ Wrong - core/entities/user.dart
import 'package:flutter/material.dart';

class User {
  final Color favoriteColor;  // Color is from Flutter!
}
```

**Solution:**
```dart
// ✅ Correct - core/entities/user.dart
class User {
  final int favoriteColorValue;  // Use int (0xFFRRGGBB)
}
```

---

### 2. core_no_data_or_presentation (ERROR)

**What it does:** Prohibits `core` from importing `data` or `presentation`.

**Why:** The core is the innermost layer. Dependencies should point **inward**, never outward.

**Violation example:**
```dart
// ❌ Wrong - core/usecases/get_user.dart
import '../../data/repositories/user_repository_impl.dart';

class GetUser {
  final UserRepositoryImpl repository;  // Imports implementation!
}
```

**Solution:**
```dart
// ✅ Correct - core/usecases/get_user.dart
abstract class UserRepository {
  Future<User?> getUser(String id);
}

class GetUser {
  final UserRepository repository;  // Uses abstraction!

  const GetUser(this.repository);

  Future<User?> call(String id) => repository.getUser(id);
}
```

---

### 3. data_no_presentation (ERROR)

**What it does:** Prohibits the `data` layer from importing `presentation`.

**Why:** Data is infrastructure, should not know about the UI.

**Violation example:**
```dart
// ❌ Wrong - data/repositories/user_repository_impl.dart
import '../../presentation/controllers/user_controller.dart';

class UserRepositoryImpl {
  void notifyUI() {
    UserController.instance.update();  // Coupling with UI!
  }
}
```

**Solution:**
```dart
// ✅ Correct - Use callbacks or streams
class UserRepositoryImpl {
  final void Function()? onDataChanged;

  UserRepositoryImpl({this.onDataChanged});

  void notifyListeners() {
    onDataChanged?.call();
  }
}
```

---

### 4. presentation_no_data (WARNING)

**What it does:** Discourages `presentation` from directly importing `data`.

**Severity:** WARNING (configurable to ERROR)

**Why:** The UI should depend only on abstractions (core). Implementations should be injected via DI.

**Violation example:**
```dart
// ⚠️ WARNING - presentation/pages/user_page.dart
import '../../data/repositories/user_repository_impl.dart';

class UserPage {
  final repository = UserRepositoryImpl();  // Directly instantiates!
}
```

**Solution:**
```dart
// ✅ Correct
import '../../core/usecases/get_user.dart';

class UserPage {
  final GetUser getUser;  // Receives abstraction!

  const UserPage({required this.getUser});
}

// In DI file (e.g., lib/core/di/injection.dart):
void setupDependencies() {
  getIt.registerFactory<GetUser>(
    () => GetUser(UserRepositoryImpl()),
  );
}
```

---

### 5. domain_only (WARNING)

**What it does:** Requires the `domain` layer to import only other domain files.

**Severity:** WARNING (configurable to ERROR)

**Allows:**
- `lib/domain/**` and `lib/src/domain/**`
- Dart SDK (`dart:async`, `dart:convert`, `dart:core`, ...) except `dart:ui`

**Blocks:**
- other layers (`data`, `core`, `presentation`)
- Flutter (`package:flutter/*`, `package:flutter_test/*`, `dart:ui`)
- third-party packages

**Why:** Domain is the innermost layer. Other layers import domain; domain must not know UI, infrastructure, or external libraries.

**Violation example:**
```dart
// ⚠️ WARNING - domain/usecases/get_user.dart
import 'package:my_app/data/repositories/user_repository_impl.dart';
import 'package:flutter/material.dart';

class GetUser {
  final UserRepositoryImpl repository;  // Data implementation in domain!
}
```

**Solution:**
```dart
// ✅ Correct - domain/usecases/get_user.dart
import 'dart:async';
import 'package:my_app/domain/entities/user.dart';
import 'package:my_app/domain/contracts/user_repository.dart';

class GetUser {
  final UserRepository repository;  // Domain contract only

  GetUser(this.repository);

  Future<User?> call(String id) => repository.getUser(id);
}
```

---

## Advanced Configuration

### Make presentation_no_data an ERROR

In `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - presentation_no_data:
        severity: error
```

### Ignore specific files

If you need to ignore a rule in a specific file:

```dart
// ignore_for_file: core_no_flutter
import 'package:flutter/material.dart';
```

Or ignore just one line:

```dart
// ignore: core_no_data_or_presentation
import '../data/models/user_model.dart';
```

**Attention:** Use `ignore` only in exceptional and documented cases!

---

## Correct Dependency Flow

```
┌─────────────┐
│Presentation │  ← User interacts
└──────┬──────┘
       │ depends on
       ↓
┌─────────────┐
│    Core     │  ← Usecases and Entities
└──────┬──────┘
       ↑ implements
       │
┌─────────────┐
│    Data     │  ← Repositories, APIs, DB
└─────────────┘
```

**Golden rule:** Dependencies always point inward (toward the core).

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1

      - name: Install dependencies
        run: dart pub get

      - name: Run custom lint
        run: dart run custom_lint
```

---

## Troubleshooting

### "Plugin custom_lint not found"

Run:
```bash
dart pub get
```

### "No lint issues found" but there are violations

1. Check if `analysis_options.yaml` is configured
2. Make sure files are in `lib/core/`, `lib/domain/`, `lib/data/` or `lib/presentation/` (or the `lib/src/{layer}/` variants)
3. Run `dart run custom_lint --watch` to see in real-time

### Lint not detecting relative imports

The lint supports both package and relative imports:
- `package:my_app/data/models/user.dart`
- `../data/models/user.dart`

If an import is not being detected, check if the path is correct.

---

## Best Practices

1. **Run lint frequently** - Preferably in watch mode
2. **Configure in CI** - Don't let violations reach main
3. **Educate the team** - Explain the why behind the rules
4. **Use DI** - Dependency injection is essential for Clean Architecture
5. **Abstract in core** - Every business rule should be in core

---

## Practical Examples

See the `example/` directory for complete examples of:
- ✅ Correct structure
- ❌ Violations of each rule
- 🔧 How to fix each type of error

Run:
```bash
cd example
dart run clean_archt_lint_example.dart
```

---

## Support

Problems or questions? Open an issue in the repository:
https://github.com/saulogatti/clean_arch_lint/issues
