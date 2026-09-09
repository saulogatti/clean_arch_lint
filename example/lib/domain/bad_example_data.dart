// VIOLATION EXAMPLE: domain_only
// This file demonstrates the warning that will be reported
// when domain tries to import data.

// ignore_for_file: unused_import

import 'package:clean_archt_lint_example/data/models/user_model.dart';

/// ⚠️ WARNING: Domain should only depend on itself.
class BadExampleData {
  void someMethod() {
    // Attempting to use data in domain
  }
}
