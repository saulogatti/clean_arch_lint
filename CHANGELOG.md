## Unreleased

- **Breaking: one `MultiAnalysisRule` instead of five rule classes**
  - Removed `CoreNoFlutter`, `CoreNoDataOrPresentation`, `DataNoPresentation`, `PresentationNoData`, `DomainOnly`
  - Removed `NoImportVisitor` / `OnlyImportVisitor`; one import visitor covers all layers
  - Diagnostics: `no_data_dependencies`, `no_screens_dependencies`, `domain_only_depends_on_itself`
- **Breaking: `analysis_server_plugin` replaces `custom_lint`**
  - Enable via the top-level `plugins` section in `analysis_options.yaml`
  - Run `dart analyze` / `flutter analyze` (not `dart run custom_lint`)
  - Lint diagnostics are off until listed under `plugins.clean_arch_lint.diagnostics`
- Added `screens` as a first-class layer alongside `core`, `domain`, `data`, `presentation`
- Documentation (README, USAGE, RULES, CONTRIBUTING, library dartdoc) updated to the simplified plugin

## 1.3.0
- **Feature: DomainOnly rule**
  - New lint rule to warn when domain depends on anything other than itself
  - Allows Dart SDK imports except `dart:ui`; blocks other layers, Flutter, and third-party packages
  - Added `OnlyImportVisitor` (allowlist) alongside the existing `NoImportVisitor` (blocklist)
  - Added example files for `/lib/domain/` and `/lib/src/domain/`
  - Updated documentation (README, USAGE, RULES) to reflect the new rule

## 1.2.0
- **Feature: PresentationNoData rule**
  - New lint rule to warn when presentation directly depends on data
  - Can be configured to ERROR via `analysis_options.yaml`
  - Added comprehensive tests for the rule
  - Added example files demonstrating the rule
  - Updated documentation (README and USAGE) to reflect the new rule

## 1.1.0

- **Feature: Flexible folder structure support**
  - Now supports both `/lib/{layer}/` and `/lib/src/{layer}/` patterns
  - Automatic detection - no configuration needed
  - Updated `isInLayer()` and `importsFromLayer()` functions to check both patterns
  - Added comprehensive tests for both folder structures
  - Added example files demonstrating both patterns
  - Updated documentation (README and USAGE) to reflect new capability

## 1.0.1

- **Documentation improvements** following Dart Effective Documentation guidelines:
  - Added comprehensive doc comments to all public APIs
  - Enhanced library-level documentation with usage examples
  - Improved documentation for all utility functions in `import_resolver.dart`
  - Added detailed examples for each lint rule showing violations and solutions
  - Documented parameters, return values, and edge cases
  - Added code examples using markdown code blocks with syntax highlighting
  - Improved readability with proper formatting and structure
- All documentation now follows Dart conventions:
  - Uses `///` for doc comments
  - Starts with summary sentences
  - Uses third-person verbs for functions
  - Uses noun phrases for properties
  - Includes practical code examples
  - Uses `[]` for identifier references

## 1.0.0

- Initial release of clean_arch_lint
- Implements custom lint rules for Flutter Clean Architecture
- **Rules:**
  - `core_no_flutter`: Prevents Flutter/UI imports in core layer (ERROR)
  - `core_no_data_or_presentation`: Prevents core from depending on data/presentation layers (ERROR)
  - `data_no_presentation`: Prevents data layer from depending on presentation layer (ERROR)
  - `presentation_no_data`: Warns when presentation depends directly on data layer (WARNING, configurable to ERROR)
- Utility functions for import resolution and path normalization
- Comprehensive example project demonstrating correct architecture
- Full documentation and usage guide
