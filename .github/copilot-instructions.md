# clean_arch_lint - AI Agent Instructions

## Project Overview

This is a **custom_lint plugin** for enforcing Clean Architecture layer boundaries in Flutter/Dart projects through static analysis. It prevents architectural violations at compile time by analyzing the AST (Abstract Syntax Tree).

## Architecture

### Core Concept: Layer Enforcement

The plugin enforces a 3-layer architecture with dependency rules:

```
lib/
 ├─ core/          → Pure business logic (no UI, no infrastructure)
 ├─ domain/        → Innermost layer (only itself + Dart SDK, except dart:ui)
 ├─ data/          → Technical implementations (repos, APIs, DB)
 └─ presentation/  → User interface (widgets, pages, controllers)
```

**Dependency Flow**: `presentation` → `core` / `domain` ← `data`
**Rule**: Dependencies always point inward, never outward.

### Key Components

1. **Plugin Entry** ([lib/main.dart](../lib/main.dart))
   - Registers all lint rules via `Plugin.register`
   - Calls `registry.registerWarningRule(...)` for each rule

2. **Lint Rules** ([lib/src/rules/](../lib/src/rules/))
   - Each rule extends `AnalysisRule` from `package:analyzer`
   - Uses Analyzer's AST API to inspect imports
   - Reports violations via `rule.reportAtNode(node)`

3. **Import Resolver** ([lib/src/utils/import_resolver.dart](../lib/src/utils/import_resolver.dart))
   - Shared utilities for analyzing import directives
   - Handles both package imports (`package:my_app/...`) and relative imports (`../data/...`)
   - Key functions: `isInLayer()`, `importsFromLayer()`, `isFlutterImport()`

## The Rules

| Rule | Severity | What It Blocks |
|------|----------|----------------|
| `core_no_flutter` | WARNING | Flutter/UI imports in `core/` |
| `core_no_data_or_presentation` | — | Not registered (orphaned file) |
| `data_no_presentation` | WARNING | `data/` importing `presentation/` |
| `presentation_no_data` | WARNING* | `presentation/` importing `data/` directly |
| `domain_only` | WARNING* | `domain/` importing anything except itself and Dart SDK (no `dart:ui`) |

*Configurable to ERROR via `analysis_options.yaml`

## Development Workflows

### Testing Your Changes

```bash
# Run unit tests
dart test

# Test with the example project
cd example
dart pub get
dart run custom_lint

# Watch mode for real-time testing
dart run custom_lint --watch
```

### Adding a New Rule

1. Create `lib/src/rules/my_new_rule.dart` extending `AnalysisRule`
2. Reuse `NoImportVisitor` (blocklist) or `OnlyImportVisitor` (allowlist) when they fit
3. Register in `lib/main.dart` → `registerWarningRule(MyRule())`
4. Add tests in `test/` and examples in `example/lib/`
5. Update README.md and USAGE.md with rule documentation

### Key Pattern: Rule Implementation

```dart
class MyRule extends AnalysisRule {
  MyRule() : super(name: 'my_rule', description: 'Warns when ...');

  static const _code = LintCode(
    'my_rule',
    'What went wrong',
    correctionMessage: 'How to fix it',
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

## Project-Specific Conventions

### Import Order (Enforced by analysis_options.yaml)
1. `dart:` imports
2. `package:` imports
3. Relative imports
4. Alphabetical within each group

### Path Handling
- Always use `/` separators (normalized via `normalizePath()`)
- Supports Windows, macOS, Linux through `package:path`
- Layer detection via pattern: `/lib/{layer_name}/`

### Error Messages
- `problemMessage`: What the user did wrong
- `correctionMessage`: How to fix it (actionable advice)
- Keep messages concise but clear

## Important Files

- [USAGE.md](../USAGE.md) - User-facing documentation with examples
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Full contributor guide
- [example/](../example/) - Demonstrates all violations and correct patterns
- `.github/instructions/dartcode.instructions.md` - Dart coding standards

## Common Gotchas

1. **Import Resolution**: The resolver needs to handle both package URIs and relative paths. Use `resolveImport()` from `import_resolver.dart`.

2. **Layer Detection**: Files must be in `lib/{layer}/` structure. Don't hardcode assumptions about depth.

3. **Third-Party Packages**: `NoImportVisitor` only reports the target layer (other `package:` imports are ignored). `OnlyImportVisitor` reports every non-layer import, including third-party packages and Flutter.

4. **Testing**: Always test both the positive case (violation detected) and negative case (correct code passes).

## Dependencies

- `analyzer` ^14.3.0 - Dart's static analysis engine
- `analysis_server_plugin` ^0.3.22 - Plugin registration (`Plugin`, `PluginRegistry`)
- `path` ^1.9.0 - Cross-platform path manipulation

No code generation (`build_runner`) or annotations needed.

## When Making Changes

1. Check existing rules in `lib/src/rules/` for patterns
2. Reuse utilities from `import_resolver.dart` - don't duplicate logic
3. Add comprehensive tests covering edge cases
4. Update documentation (README, USAGE) in sync with code
5. Run `dart run custom_lint` in example/ to verify behavior
6. Follow Conventional Commits for commit messages
7. **Document your code** before finishing:
   - Add `///` doc comments to all public APIs
   - Include code examples in comments when helpful
   - Explain the "why" behind non-obvious decisions
   - Update [CHANGELOG.md](../CHANGELOG.md) with your changes

## Questions to Ask Yourself

- Does this preserve the unidirectional dependency flow?
- Are error messages actionable for developers?
- Does it handle both package and relative imports?
- Are there edge cases in path resolution (Windows, nested structures)?
- Is the severity appropriate (ERROR vs WARNING)?
