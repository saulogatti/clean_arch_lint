---
name: Bug report
about: A diagnostic is missing, wrong, or the plugin does not load
title: ''
labels: 'bug'
assignees: ''

---

**Describe the bug**
What happened, and what you expected (a diagnostic that should fire and does not, a false positive, the plugin not loading, ...).

**Import that triggers it**
The file path (from `lib/`) and the `import` or `export` directive:

```dart
// lib/presentation/pages/product_page.dart
import 'package:my_app/data/models/product_model.dart';
```

**Configuration**
The `plugins` section of your `analysis_options.yaml`:

```yaml
plugins:
  clean_arch_lint:
    version: ^3.2.0
    diagnostics:
      no_data_dependencies: true
```

**How you ran the analysis**
IDE, or the exact command and the directory it ran from (`dart analyze` from the package root; `dart analyze lib` skips analyzer plugins).

**Versions**
- clean_arch_lint:
- Dart SDK (`dart --version`):
- Flutter (`flutter --version`), if used:

**Project layout**
Single package, `lib/src/`, feature-first, or monorepo (package names), and whether it is a pub workspace.

**Additional context**
Anything else that helps reproduce it.
