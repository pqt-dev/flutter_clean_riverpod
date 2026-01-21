import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/features/widgets/not_found_data_view.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotFoundDataView(),
    );
  }
}
