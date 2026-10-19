// ignore_for_file: clean_arch_lint/domain_only_depends_on_itself

import 'dart:developer';

/// 🔕 IGNORED EXAMPLE: Domain importing a non-pure SDK library, suppressed for
/// the whole file.
///
/// `dart:developer` is not one of the pure Dart libraries, so the import would
/// be reported. `// ignore_for_file:` at the top silences
/// `domain_only_depends_on_itself` in every directive of this file.
void traceDomainEvent(String name) => log(name, name: 'domain');
