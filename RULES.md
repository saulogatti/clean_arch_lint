# Rules

## CoreNoFlutter

### Description

Core cannot depend on Flutter. If a file in the core layer imports Flutter,
it will be reported.

### Example

```dart
import 'package:flutter/material.dart';
```

## DomainOnly

### Description

Domain can only depend on itself and on the Dart SDK (except `dart:ui`).
Any import of `data`, `core`, `presentation`, Flutter, or a third-party
package is reported.

Other layers import Domain; Domain does not import them.

### Allowed

```dart
import 'dart:async';
import 'package:my_app/domain/entities/user.dart';
```

### Reported

```dart
import 'package:flutter/material.dart';
import 'package:my_app/data/models/user_model.dart';
import 'package:equatable/equatable.dart';
```

----

* Clean Architecture reminders:
    * Core must not import Flutter.
    * Data must not import presentation.
    * Presentation must not import data; depend on core/domain contracts and inject implementations.
    * Domain may only import itself and Dart SDK (`dart:ui` is forbidden). Other layers import Domain.
