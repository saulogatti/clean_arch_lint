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
│       │   └── no_screens_dependencies_rule.dart
│       └── utils/
│           ├── import_resolver.dart
│           └── resolved_import.dart
├── example/                              # analysis_options + violations
├── test/
└── docs/                                 # generated dart doc (optional)
```

## Adding a diagnostic or rule

This plugin uses `analysis_server_plugin`. Do **not** use `custom_lint_builder` / `DartLintRule`.

Prefer extending the existing [NoScreensDependenciesRule](lib/src/rules/no_screens_dependencies_rule.dart) (`MultiAnalysisRule`) so each file still has a single `ImportDirective` processor. Add a `LintCodeArchitecture` in `lint_utils.dart` and list it in `diagnosticCodes`.

Only add a new `AnalysisRule` / `MultiAnalysisRule` when the check cannot live in that visitor.

1. Register with `registry.registerLintRule(...)` in `lib/main.dart`.
2. Enable the diagnostic name in `example/analysis_options.yaml` under `plugins.clean_arch_lint.diagnostics`.
3. Add example files under `example/lib/{layer}/`.
4. Tests for any new `import_resolver` behavior.
5. Dartdoc on public APIs; update README.md, USAGE.md, RULES.md, CHANGELOG.md.

Reuse `isInLayer`, `importsFromLayer`, `resolveImport`. Use the full file path (`context.currentUnit?.file.path`), not `shortName`.

```dart
registry.registerLintRule(NoScreensDependenciesRule());
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
