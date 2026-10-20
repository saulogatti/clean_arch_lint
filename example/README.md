# clean_arch_lint Usage Example

This example enables the plugin via `analysis_options.yaml` and contains a small working feature (load and show a product) split across the layers, plus one intentional violation per layer and two suppressed with `// ignore`.

## Naming convention

Every class name ends with a suffix that belongs to exactly one layer, so the name alone tells where a type lives and which way it may depend:

| Layer | Suffixes | Example |
| --- | --- | --- |
| `domain` | `Entity`, `RepositoryContract`, `UseCase` | `ProductEntity` |
| `data` | `Model`, `DataSource`, `RepositoryImpl` | `ProductModel` |
| `presentation` | `ViewModel`, `Page` | `ProductPage` |
| `screens` | `Screen` | `HomeScreen` |
| `core` | `Util` | `PriceFormatterUtil` |

Seeing `ProductModel` imported in a `...UseCase`, or `...RepositoryImpl` in a `...Page`, is a violation you can spot before the analyzer reports it.

## Structure

```
lib/
 ├─ main.dart                                   # composition root (outside the layers)
 ├─ core/
 │   ├─ utils/price_formatter_util.dart          # PriceFormatterUtil
 │   └─ bad_example_screens.dart                 # ❌ core → screens
 ├─ domain/
 │   ├─ entities/product_entity.dart             # ProductEntity
 │   ├─ repositories/product_repository_contract.dart  # ProductRepositoryContract (uses dart:async)
 │   ├─ usecases/get_product_use_case.dart       # GetProductUseCase
 │   ├─ bad_example_data.dart                    # ❌ domain → data
 │   ├─ bad_example_flutter.dart                 # ❌ domain → Flutter
 │   ├─ bad_example_dart_io.dart                 # ❌ domain → dart:io
│   ├─ bad_example_third_party.dart             # ❌ domain → third-party package (meta)
 │   └─ ignored_example_dart_developer.dart      # 🔕 domain → dart:developer, ignore_for_file
 ├─ data/
 │   ├─ models/product_model.dart                # ProductModel (fromJson, toEntity)
 │   ├─ datasources/product_remote_data_source.dart  # ProductRemoteDataSource
 │   ├─ repositories/product_repository_impl.dart     # ProductRepositoryImpl
 │   └─ bad_example_presentation.dart            # ❌ data → presentation
 ├─ presentation/
 │   ├─ view_models/product_view_model.dart      # ProductViewModel
 │   ├─ pages/product_page.dart                  # ProductPage
 │   ├─ bad_example_data.dart                    # ❌ presentation → data
 │   └─ ignored_example_data.dart                # 🔕 presentation → data, ignore on one line
 └─ screens/
     ├─ home/home_screen.dart                    # HomeScreen
     └─ bad_example_data.dart                    # ❌ screens → data (relative import)
```

Flow: `HomeScreen` → `ProductViewModel` → `GetProductUseCase` → `ProductRepositoryContract`, implemented by `ProductRepositoryImpl`, which turns the `ProductModel` from `ProductRemoteDataSource` into a `ProductEntity`. Only `lib/main.dart` knows the `data` implementations and wires them in.

## How to see the diagnostics

1. Confirm `example/analysis_options.yaml` lists the plugin and enables:

   - `no_data_dependencies`
   - `domain_only_depends_on_itself`
   - `no_screens_dependencies`

2. From this directory (not a subdirectory, see the troubleshooting note in `USAGE.md`):

```bash
dart pub get
dart analyze
```

Restart the Dart Analysis Server after changing `plugins`.

## What should be reported

Exactly one warning per `bad_example_*.dart` file, and nothing else:

| File | Diagnostic |
| --- | --- |
| `core/bad_example_screens.dart` | `no_screens_dependencies` |
| `data/bad_example_presentation.dart` | `no_screens_dependencies` |
| `domain/bad_example_data.dart` | `domain_only_depends_on_itself` |
| `domain/bad_example_flutter.dart` | `domain_only_depends_on_itself` |
| `domain/bad_example_dart_io.dart` | `domain_only_depends_on_itself` |
| `domain/bad_example_third_party.dart` | `domain_only_depends_on_itself` |
| `presentation/bad_example_data.dart` | `no_data_dependencies` |
| `presentation/bad_example_export_data.dart` | `no_data_dependencies` |
| `screens/bad_example_data.dart` | `no_data_dependencies` |

Setting `allow_third_party_packages_in_domain: true` in `analysis_options.yaml` silences only `domain/bad_example_third_party.dart`.

## Suppressed violations

The `ignored_example_*.dart` files contain real violations silenced with an ignore comment, so they report nothing:

| File | Comment |
| --- | --- |
| `domain/ignored_example_dart_developer.dart` | `// ignore_for_file: clean_arch_lint/domain_only_depends_on_itself` |
| `presentation/ignored_example_data.dart` | `// ignore: clean_arch_lint/no_data_dependencies` (above the import) |

Remove the comment and the corresponding warning appears.
