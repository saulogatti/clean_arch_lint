/// ❌ BAD EXAMPLE: Core importing Screens.
///
/// Violation of `no_screens_dependencies`: core is shared code and must not
/// know about UI.
library;

import 'package:clean_archt_lint_example/screens/home/home_screen.dart'; // ❌ no_screens_dependencies

Type badCoreDependency() => HomeScreen;
