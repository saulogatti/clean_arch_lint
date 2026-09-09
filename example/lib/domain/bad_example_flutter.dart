// VIOLATION EXAMPLE: domain_only
// This file demonstrates the warning that will be reported
// when domain tries to import Flutter or a third-party package.

// ignore_for_file: unused_import

import 'package:flutter/material.dart';

// ⚠️ WARNING: Domain cannot import third-party packages
// import 'package:path/path.dart';

/// ⚠️ WARNING: Domain should only depend on itself.
class BadExampleFlutter {
  void someMethod() {
    // Attempting to use Flutter in domain
  }
}
