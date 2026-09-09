# Rules

Architecture checks live in one class: [NoScreensDependenciesRule](lib/src/rules/no_screens_dependencies_rule.dart). Users enable **diagnostic names**, not the old per-layer rule classes.

## no_data_dependencies

### Description

`presentation` and `screens` must not import `data`. The same code is also used when `data` or `core` import those UI layers.

### Example

```dart
import 'package:my_app/data/models/product_model.dart';
```

## no_screens_dependencies

### Description

`data` (and `core`) must not import `screens` or `presentation`.

### Example

```dart
import 'package:my_app/presentation/pages/product_page.dart';
import 'package:my_app/screens/home/home_screen.dart';
```

## domain_only_depends_on_itself

### Description

Domain may import only other domain files and the Dart SDK. Flutter, `dart:ui`, other layers, and third-party packages are reported.

### Allowed

```dart
import 'dart:async';
import 'package:my_app/domain/entities/product.dart';
```

### Reported

```dart
import 'package:flutter/material.dart';
import 'package:my_app/data/models/product_model.dart';
import 'package:equatable/equatable.dart';
```

----

Reminders:

- Domain is inward-only.
- Data and core must not know about UI (`presentation`, `screens`).
- Presentation and screens must not import data implementations; depend on domain/core and inject implementations.
- Flutter-in-core (`core_no_flutter`) is **not** a separate rule anymore.
