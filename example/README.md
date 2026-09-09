# clean_arch_lint Usage Example

This example enables the plugin via `analysis_options.yaml` and contains both valid layer files and intentional violations.

## Structure

```
lib/
 ├─ core/
 │   ├─ app_exemple.dart          # violation: core → data
 │   └─ entities/product.dart
 ├─ domain/
 │   ├─ bad_example_data.dart     # violation: domain → data
 │   ├─ bad_example_flutter.dart  # violation: domain → Flutter
 │   ├─ entities/product.dart
 │   └─ usecases/get_product.dart
 ├─ data/
 │   ├─ bad_example_in_data.dart  # violation: data → presentation
 │   └─ models/product_model.dart
 ├─ presentation/
 │   ├─ bad_example_data.dart     # violation: presentation → data
 │   └─ pages/product_page.dart
 └─ screens/
     └─ home/home_screen.dart    # violation: screens → data
```

## How to see the diagnostics

1. Confirm `example/analysis_options.yaml` lists the plugin and enables:

   - `no_data_dependencies`
   - `domain_only_depends_on_itself`
   - `no_screens_dependencies`

2. From this directory:

```bash
dart pub get
dart analyze
```

Restart the Dart Analysis Server after changing `plugins`.

## What should be reported

| File | Diagnostic |
| --- | --- |
| `domain/bad_example_data.dart` | `domain_only_depends_on_itself` |
| `domain/bad_example_flutter.dart` | `domain_only_depends_on_itself` |
| `data/bad_example_in_data.dart` | `no_data_dependencies` / `no_screens_dependencies` |
| `presentation/bad_example_data.dart` | `no_data_dependencies` |
| `screens/home/home_screen.dart` | `no_data_dependencies` |
| `core/app_exemple.dart` | leftover from the old core→data rule; not a dedicated check anymore |

Allowed examples: `domain/entities`, `domain/usecases`, `core/entities`, `data/models` (imports core), `presentation/pages` (imports core + Flutter).
