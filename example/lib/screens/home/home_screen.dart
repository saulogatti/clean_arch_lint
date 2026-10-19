import 'package:clean_archt_lint_example/presentation/pages/product_page.dart';
import 'package:clean_archt_lint_example/presentation/view_models/product_view_model.dart';
import 'package:flutter/material.dart';

/// ✅ Screen: route-level widget that composes presentation pieces. It gets
/// the [ProductViewModel] ready-made, so it never touches `data`.
///
/// Suffix `Screen` → lives in `screens`.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final ProductViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load('1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clean Arch Lint Example')),
      body: Center(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final product = widget.viewModel.product;
            if (widget.viewModel.isLoading) {
              return const CircularProgressIndicator();
            }
            if (product == null) return const Text('Product not found');
            return ProductPage(product: product);
          },
        ),
      ),
    );
  }
}
