import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';
import 'package:flutter_clean_riverpod/presentation/features/widgets/app_text.dart';

class CountryItemView extends StatelessWidget {
  const CountryItemView({super.key, required this.data});

  final Country data;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        spacing: 8.0,
        children: [
          const SizedBox(height: 12.0),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            child: Card(
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: CachedNetworkImage(
                  imageUrl: data.flags?.png ?? '-',
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          AppText(
            textAlign: TextAlign.center,
            text: data.name?.common ?? '--',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
