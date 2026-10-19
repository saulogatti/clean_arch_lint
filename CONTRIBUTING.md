# Contributing to clean_arch_lint

Thank you for considering contributing to clean_arch_lint.

## How to Contribute

### Reporting Bugs

1. Check if the bug hasn't already been reported in [Issues](https://github.com/saulogatti/clean_arch_lint/issues)
2. Open a new issue including:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs. actual behavior
   - Dart/Flutter version
   - Code example that causes the problem

### Suggesting Improvements

1. Open an issue with the `enhancement` tag
2. Describe clearly:
   - The problem the improvement solves
   - The proposed solution
   - Usage examples

### Contributing Code

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/your-username/clean_arch_lint.git
   cd clean_arch_lint
   ```

3. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/my-feature
   ```

4. **Install dependencies**:
   ```bash
   dart pub get
   ```

5. **Make your changes** following the standards:
   - Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
   - Use descriptive names for variables and functions
   - Add comments when necessary
   - Keep lines within the project formatter width (100)

6. **Add tests** for your changes:
   ```bash
   dart test
   ```

7. **Commit your changes** using [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for adding/modifying tests
   - `refactor:` for refactorings

8. **Push** and open a Pull Request explaining what changed, why, and how to test.

## Project Structure

```
clean_arch_lint/
├── lib/
│   ├── main.dart                         # plugin + `plugin` entry point
│   └── src/
│       ├── lint_utils.dart               # LintCode + LintNames
│       ├── rules/
│       │   ├── architecture_import_rule.dart   # shared base + ImportDirective visitor
│       │   ├── domain_only_depends_on_itself_rule.dart
│       │   ├── no_data_dependencies_rule.dart
│       │   └── no_screens_dependencies_rule.dart
│       └── utils/
│           └── import_resolver.dart
├── example/                              # analysis_options + violations
├── test/
└── docs/                                 # generated dart doc (optional)
```

## Adding a diagnostic or rule

This plugin uses `analysis_server_plugin`. Do **not** use `custom_lint_builder` / `DartLintRule`.

Each user-facing diagnostic name is one rule class extending `ArchitectureImportRule`, and the rule's `name` must equal that diagnostic name: the analyzer only runs a rule when the diagnostic named after `rule.name` is enabled, so sharing one rule across names makes them depend on each other. Subclasses only implement `diagnosticCodeFor(currentLayer, importedLayer)`; the base class resolves the layers.

- New message variant of an existing diagnostic: add a `LintCodeArchitecture` with the same `LintNames` name and a unique `uniqueName` in `lint_utils.dart`, and list it in that rule's `diagnosticCodes`.
- New diagnostic name: add it to `LintNames`, its codes to `lint_utils.dart`, and a new `ArchitectureImportRule` subclass.

1. Register with `registry.registerLintRule(...)` in `CleanArchitectureLintPlugin.register` (`lib/clean_arch_lint.dart`) and export the class there.
2. Enable the diagnostic name in `example/analysis_options.yaml` under `plugins.clean_arch_lint.diagnostics`.
3. Add example files under `example/lib/{layer}/`.
4. Tests for any new `import_resolver` behavior.
5. Dartdoc on public APIs; update README.md, USAGE.md, RULES.md, CHANGELOG.md.

Reuse `layerOf`, `packageNameOf`, `importedUriOf`. Work with the analyzer's resolved URIs (`node.libraryImport`, `context.currentUnit?.unit.declaredFragment?.source.uri`), not file-system paths.

```dart
registry.registerLintRule(NoDataDependenciesRule());
registry.registerLintRule(NoScreensDependenciesRule());
registry.registerLintRule(DomainOnlyDependsOnItselfRule());
```

## Testing locally

```bash
dart test
```

```bash
cd example
dart pub get
dart analyze
```

## Code standards

### Documentation

- Use `///` for doc comments
- Document public APIs
- Include examples when appropriate

### Naming

- Classes: `UpperCamelCase`
- Functions/variables: `lowerCamelCase`
- Files: `snake_case.dart`

### Imports

1. `dart:`
2. `package:`
3. Relative
4. Alphabetical in each group

## Questions?

Open an issue with the `question` tag.
