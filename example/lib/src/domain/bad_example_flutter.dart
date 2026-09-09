import 'package:flutter/material.dart'; // ❌ WARNING: Domain cannot import Flutter

/// ❌ BAD EXAMPLE: Domain importing Flutter in /lib/src/domain/ structure
///
/// This file demonstrates a VIOLATION of the domain_only rule
/// when using the /lib/src/domain/ structure
class BadProductWidget extends StatelessWidget {
  const BadProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
