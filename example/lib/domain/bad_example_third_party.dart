import 'package:meta/meta.dart'; // ❌ domain_only_depends_on_itself

/// ❌ BAD EXAMPLE: Domain importing a third-party package.
///
/// Violation of `domain_only_depends_on_itself` while
/// `allow_third_party_packages_in_domain` is off (the default). Enable it in
/// `analysis_options.yaml` to allow third-party packages in domain.
@immutable
class BadProductTagEntity {
  const BadProductTagEntity(this.label);

  final String label;
}
