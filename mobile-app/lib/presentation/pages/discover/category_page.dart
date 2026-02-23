import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  final String categoryId;
  const CategoryPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryId)),
      body: const Center(child: Text('Category')),
    );
  }
}
