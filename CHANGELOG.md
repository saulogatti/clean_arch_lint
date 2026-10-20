## 3.0.0

- **Features:**
  - `allow_third_party_packages_in_domain`: when enabled, `domain_only_depends_on_itself` allows
    third-party packages in `domain` (`AllowThirdPartyPackagesInDomainRule`). It reports nothing
    by itself. Flutter SDK packages, `dart:ui`, `dart:io` and other layers stay reported. Off by
    default, so third-party packages are still reported unless the option is enabled.
- **Breaking changes:**
  - `no_data_dependencies` now covers only `presentation`/`screens` importing `data`.
    `data`/`core` importing `screens` or `presentation` is reported under
    `no_screens_dependencies`, which previously never fired. Projects that enabled only
    `no_data_dependencies` must also enable `no_screens_dependencies` to keep that check.
  - `domain_only_depends_on_itself` allows only pure Dart libraries (`dart:core`, `dart:async`,
    `dart:collection`, `dart:convert`, `dart:math`, `dart:typed_data`). `dart:ui`, `dart:io`,
    `dart:html`, `dart:ffi` and other SDK libraries are now reported in `domain` (previously every
    `dart:` import was allowed, despite the docs saying `dart:ui` was reported).
- **Fixes:**
  - Each diagnostic can be enabled or disabled independently. Previously one `MultiAnalysisRule`
    named `no_screens_dependencies` served all three, and the analyzer only runs a rule when the
    diagnostic matching its name is enabled, so turning off `no_screens_dependencies` silenced
    every check. `NoDataDependenciesRule`, `NoScreensDependenciesRule` and
    `DomainOnlyDependsOnItselfRule` are now registered separately on top of a shared
    `ArchitectureImportRule`.
  - Layers are detected from the analyzer's resolved library URIs
    (`ImportDirective.libraryImport` / `LibraryFragment.source.uri`) instead of file-system
    paths. Relative and `package:` imports resolve identically, and imports from other packages
    are no longer mistaken for the project's own layers.
- **Removed:**
  - `ResolvedImport` and the path helpers `resolveImport`, `isInLayer`, `importsFromLayer`,
    `normalizePath`, `extractPackageName`, `extractProjectRoot` (replaced by `layerOf`,
    `packageNameOf`, `importedUriOf`, `isPureDartLibrary`).
  - Unused `noPresentationDependenciesCode`, `isFlutterImport`, debug `LoggerUtil` and the `path`
    dependency.
- **Messages:** diagnostic messages rewritten. `domain_only_depends_on_itself` no longer says
  only data and presentation are forbidden, and every correction message now suggests a fix
  instead of repeating the problem.
- **Tests:** rule tests with `analyzer_testing` for all three diagnostics (replacing placeholder
  tests).
- **Docs:** troubleshooting note — `dart analyze <directory>` skips analyzer plugins
  (dart-lang/sdk#62710); analyze the package root.

## 2.0.1

- **Fix:** missing main file


## 2.0.0

- **Breaking changes:**
  - Removed `CoreNoFlutter`, `CoreNoDataOrPresentation`, `DataNoPresentation`, `PresentationNoData`, `DomainOnly`
  - Removed `NoImportVisitor` / `OnlyImportVisitor`; one import visitor covers all layers
  - Diagnostics: `no_data_dependencies`, `no_screens_dependencies`, `domain_only_depends_on_itself`
  - Enable via the top-level `plugins` section in `analysis_options.yaml`
  - Run `dart analyze` / `flutter analyze` (not `dart run custom_lint`)
  - Lint diagnostics are off until listed under `plugins.clean_arch_lint.diagnostics`
  - Added `screens` as a first-class layer alongside `core`, `domain`, `data`, `presentation`
  - Documentation (README, USAGE, RULES, CONTRIBUTING, library dartdoc) updated to the simplified plugin
- **New features:**
  - New lint rule to warn when screens depend on data
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
