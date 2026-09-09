/// User entity.
///
/// Domain layer - pure business type with no external dependencies.
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});
}
