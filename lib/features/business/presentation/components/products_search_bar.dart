import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/fudi_search_bar.dart';
import '../business_providers.dart';

class ProductsSearchBar extends ConsumerStatefulWidget {
  const ProductsSearchBar({super.key});

  @override
  ConsumerState<ProductsSearchBar> createState() => _ProductsSearchBarState();
}

class _ProductsSearchBarState extends ConsumerState<ProductsSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(productsSearchQueryProvider.notifier).update(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FudiSearchBar(
      controller: _controller,
      hintText: 'Buscar productos...',
      onChanged: _onSearchChanged,
    );
  }
}
