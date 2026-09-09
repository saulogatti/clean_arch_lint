# Contributing to clean_arch_lint

Thank you for considering contributing to clean_arch_lint! 🎉

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
   - Keep lines up to 80 characters when possible

6. **Add tests** for your changes:
   ```bash
   dart test
   ```

7. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add new feature X"
   ```

   Use [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for adding/modifying tests
   - `refactor:` for refactorings

8. **Push to your fork**:
   ```bash
   git push origin feature/my-feature
   ```

9. **Open a Pull Request** explaining:
   - What was changed
   - Why it was changed
   - How to test the changes

## Project Structure

```
clean_arch_lint/
├── lib/
│   ├── main.dart                    # Plugin entry point
│   └── src/
│       ├── rules/                   # Lint rules
│       │   ├── core_no_flutter.dart
│       │   ├── data_no_presentation.dart
│       │   ├── domain_only.dart
│       │   ├── presentation_no_data.dart
│       │   ├── no_import_visitor.dart   # Blocklist: layer A must not import layer B
│       │   └── only_import_visitor.dart # Allowlist: layer may only import itself
│       └── utils/
│           └── import_resolver.dart # Import resolution utilities
├── example/                         # Usage example
├── test/                           # Tests
└── docs/                           # Additional documentation
```

## Adding a New Lint Rule

Rules extend `AnalysisRule` from `package:analyzer` and register a visitor on
`ImportDirective`. Do **not** use `custom_lint_builder` / `DartLintRule`.

1. **Choose the visitor**
   - **Blocklist** (`NoImportVisitor`): files in layer A must not import layer B.
     Used by `presentation_no_data` and `data_no_presentation`.
   - **Allowlist** (`OnlyImportVisitor`): files in layer A may only import that
     layer plus Dart SDK (except `dart:ui`). Used by `domain_only`.
   - Write a dedicated visitor only when neither fit (see `core_no_flutter`).

2. **Create the rule file** in `lib/src/rules/`:

   ```dart
   class MyRule extends AnalysisRule {
     MyRule()
       : super(name: 'my_rule', description: 'Warns when ...');

     static const _code = LintCode(
       'my_rule',
       'Problem description',
       correctionMessage: 'How to fix',
       severity: .WARNING,
     );

     @override
     DiagnosticCode get diagnosticCode => _code;

     @override
     void registerNodeProcessors(
       RuleVisitorRegistry registry,
       RuleContext context,
     ) {
       final visitor = NoImportVisitor(
         rule: this,
         context: context,
         exportLayer: 'presentation',
         importLayer: 'data',
       );
       registry.addImportDirective(this, visitor);
     }
   }
   ```

   Report violations with `rule.reportAtNode(node)`. Reuse
   `isInLayer()`, `importsFromLayer()`, `resolveImport()`, and
   `isFlutterImport()` from `import_resolver.dart`.

3. **Register** in `lib/main.dart`:

   ```dart
   registry.registerWarningRule(MyRule());
   ```

   Also export the rule from `lib/main.dart`.

4. **Add tests** in `test/` for any new `import_resolver` behavior, and
   example files in `example/lib/` (and `example/lib/src/` when the layer
   supports both folder layouts).

5. **Document** in README.md, USAGE.md, and CHANGELOG.md. Add `///` dartdoc
   on the rule class (severity, examples, `analysis_options.yaml` config).

## Testing Locally

### Test the main package:
```bash
dart test
```

### Test with the example:
```bash
cd example
dart pub get
dart run custom_lint
```

### Test with a real project:
```bash
# In your test project
dart pub get
dart run custom_lint
```

## Code Standards

### Documentation

- Use `///` for doc comments
- Document all public APIs
- Include examples when appropriate

### Naming

- Classes: `UpperCamelCase`
- Functions/variables: `lowerCamelCase`
- Constants: `lowerCamelCase` (preferred) or `SCREAMING_CAPS`
- Files: `snake_case.dart`

### Imports

1. Imports `dart:`
2. Imports `package:`
3. Relative imports
4. Alphabetical ordering in each group

Example:
```dart
import 'dart:async';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/error/error.dart';

import '../utils/import_resolver.dart';
```

## Code of Conduct

- Be respectful and professional
- Accept constructive feedback
- Focus on what's best for the project
- Be patient with new contributors

## Questions?

Open an issue with the `question` tag or contact us through the repository.

Thank you for contributing! 🚀
