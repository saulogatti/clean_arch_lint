import 'package:clean_arch_lint_example/data/datasources/product_remote_data_source.dart';
import 'package:clean_arch_lint_example/data/repositories/product_repository_impl.dart';
import 'package:clean_arch_lint_example/domain/usecases/get_product_use_case.dart';
import 'package:clean_arch_lint_example/presentation/view_models/product_view_model.dart';
import 'package:clean_arch_lint_example/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

/// Composition root: wires `data` implementations into the domain contracts.
///
/// `lib/main.dart` is outside every layer directory, so it may import all of
/// them. This is the only place that knows [ProductRepositoryImpl].
void main() {
  final repository = ProductRepositoryImpl(ProductRemoteDataSource());
  final viewModel = ProductViewModel(GetProductUseCase(repository));
  runApp(MyApp(viewModel: viewModel));
}

/// Root widget: opens [HomeScreen] with the [ProductViewModel] built in
/// [main].
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.viewModel});

  final ProductViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen(viewModel: viewModel));
  }
}
