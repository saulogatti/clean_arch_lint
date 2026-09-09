import 'package:flutter/material.dart'; // ❌ domain_only_depends_on_itself

/// ❌ BAD EXAMPLE: Domain importing Flutter.
///
/// Violation of `domain_only_depends_on_itself`.
class BadProductWidget extends StatelessWidget {
  const BadProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
