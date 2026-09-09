// import 'package:analyzer/analysis_rule/analysis_rule.dart';
// import 'package:analyzer/analysis_rule/rule_context.dart';
// import 'package:analyzer/analysis_rule/rule_state.dart';
// import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
// import 'package:analyzer/error/error.dart';
// import 'package:clean_arch_lint/src/rules/no_import_visitor.dart';

// /// Lint rule that discourages the presentation layer from depending on data.
// ///
// /// The presentation layer should depend only on core (usecases and contracts).
// /// Concrete implementations should be injected via dependency injection,
// /// respecting the dependency inversion principle.
// ///
// /// ## Severity
// ///
// /// WARNING (default) - Can be configured to ERROR via `analysis_options.yaml`
// ///
// /// ## Dependency rule
// ///
// /// ``
// /// presentation → core ← data
// /// ``
// ///
// /// Presentation should not know concrete implementations from the data layer.
// ///
// /// ## Configuration
// ///
// /// To transform into ERROR, add to `analysis_options.yaml`:
// ///
// /// ```yaml
// /// plugins:
// /// clean_arch_lint:
// ///   diagnostics:
// ///     presentation_no_data: error # enable to see the error, default is warning
// ///
// /// ```
// ///
// /// ## Violation example
// ///
// /// ```dart
// /// // ⚠️ Warning - presentation/controllers/user_controller.dart
// /// import 'package:my_app/data/repositories/user_repository_impl.dart';
// ///
// /// class UserController {
// ///   final UserRepositoryImpl repository; // Knows concrete implementation
// ///
// ///   UserController() : repository = UserRepositoryImpl(); // Direct coupling
// /// }
// /// ```
// ///
// /// ## Solution
// ///
// /// ```dart
// /// // ✅ Correct - presentation/controllers/user_controller.dart
// /// import 'package:my_app/core/contracts/user_repository.dart';
// /// import 'package:my_app/core/usecases/get_user.dart';
// ///
// /// class UserController {
// ///   final GetUser getUser; // Depends on core usecase
// ///
// ///   UserController(this.getUser); // Implementation injected
// /// }
// ///
// /// // ✅ Correct - main.dart (or DI container)
// /// import 'package:my_app/data/repositories/user_repository_impl.dart';
// ///
// /// void main() {
// ///   final repository = UserRepositoryImpl();
// ///   final getUser = GetUser(repository);
// ///   final controller = UserController(getUser); // Dependency injection
// /// }
// /// ```
// class PresentationNoData extends AnalysisRule {
//   /// Creates an instance of the [PresentationNoData] rule.
//   PresentationNoData()
//     : super(
//         name: 'presentation_no_data',
//         description: 'Warns when presentation directly depends on data.',
//         state: const RuleState.stable(),
//       );
//   static const _code = LintCode(
//     'presentation_no_data',
//     'Presentation should not depend directly on Data.',
//     correctionMessage: 'Depend only on Core (usecases/contracts) and inject implementations.',
//     severity: .WARNING,
//     uniqueName: 'presentation_no_data',
//   );
//   @override
//   DiagnosticCode get diagnosticCode => _code;

//   @override
//   void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
//     final visitor = NoImportVisitor(
//       rule: this,
//       context: context,
//       exportLayer: 'presentation',
//       importLayer: 'data',
//     );

//     registry.addImportDirective(this, visitor);
//   }
// }
