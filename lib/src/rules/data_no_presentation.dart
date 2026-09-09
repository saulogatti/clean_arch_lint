import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/rules/no_import_visitor.dart';

/// Lint rule that prohibits the data layer from depending on presentation.
///
/// The data layer contains technical implementations and infrastructure (APIs,
/// database, external services). It should not have knowledge about
/// the UI or presentation components.
///
/// ## Severity
///
/// ERROR - Violates the separation of concerns of Clean Architecture
///
/// ## Dependency rule
///
/// ``
/// presentation → core ← data
/// ``
///
/// Data and presentation are parallel layers that depend on core,
/// but should not know about each other.
///
/// ## Violation example
///
/// ```dart
/// // ❌ Wrong - data/datasources/api_datasource.dart
/// import 'package:my_app/presentation/controllers/user_controller.dart';
///
/// class ApiDataSource {
///   void notifyUI(UserController controller) {
///     // Data layer should not know UI controllers
///   }
/// }
/// ```
///
/// ## Solution
///
/// ```dart
/// // ✅ Correct - data/datasources/api_datasource.dart
/// import 'package:my_app/core/entities/user.dart';
///
/// class ApiDataSource {
///   Future<User> fetchUser(String id) {
///     // Returns core entities, not UI components
///   }
/// }
///
/// // ✅ Correct - presentation/controllers/user_controller.dart
/// import 'package:my_app/core/usecases/get_user.dart';
///
/// class UserController {
///   final GetUser getUser; // Uses core usecase, not datasource
/// }
/// ```
class DataNoPresentation extends AnalysisRule {
  DataNoPresentation()
    : super(
        name: 'data_no_presentation',
        description: 'Prohibits the data layer from depending on presentation.',
      );
  static const _code = LintCode(
    'data_no_presentation',
    'Data should not depend on presentation.',
    correctionMessage: 'Depend only on Core (usecases/contracts) and inject implementations. Use dependency injection to inject the presentation layer.',
    severity: .WARNING,
  );
  @override
  DiagnosticCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = NoImportVisitor(
      rule: this,
      context: context,
      exportLayer: 'data',
      importLayer: 'presentation',
    );
    registry.addImportDirective(this, visitor);
  }
}
