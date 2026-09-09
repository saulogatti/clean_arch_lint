// ignore: unused_import -- allowed by domain_only; Future is also exported by dart:core
import 'dart:async';

import '../entities/user.dart';

/// Contract to fetch a user.
///
/// Domain layer - may import Dart SDK and other domain types only.
abstract class GetUser {
  Future<User?> call(String userId);
}
