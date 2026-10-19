# Rules

Each diagnostic below is one rule in [lib/src/rules](lib/src/rules) and can be enabled or disabled on its own under `plugins.clean_arch_lint.diagnostics`.

## no_data_dependencies

### Description

`presentation` and `screens` must not import `data`.

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

Domain may import only other domain files and the pure Dart libraries (`dart:core`, `dart:async`, `dart:collection`, `dart:convert`, `dart:math`, `dart:typed_data`). Flutter, other `dart:` libraries (`dart:ui`, `dart:io`, …), other layers, and third-party packages are reported.

### Allowed

```dart
import 'dart:async';
import 'package:my_app/domain/entities/product_entity.dart';
```

### Reported

```dart
import 'package:flutter/material.dart';
import 'package:my_app/data/models/product_model.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import 'dart:ui';
```

----

Reminders:

- Domain is inward-only.
- Data and core must not know about UI (`presentation`, `screens`).
- Presentation and screens must not import data implementations; depend on domain/core and inject implementations.
- Flutter-in-core (`core_no_flutter`) is **not** a separate rule anymore.
