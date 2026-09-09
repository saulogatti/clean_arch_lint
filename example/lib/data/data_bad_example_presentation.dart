// VIOLATION EXAMPLE: data_no_presentation
// This file demonstrates the error that will be reported
// when data tries to import presentation.

// ❌ ERROR: Data cannot depend on Presentation
import '../presentation/pages/user_page.dart';

/// This is a commented example to not break the build.
/// Uncomment the import above to see the lint in action.
class DataBadExamplePresentation {
  final UserPage userPage;
  DataBadExamplePresentation(this.userPage);
  void someMethod() {
    // Attempting to use presentation in data
  }
}
