import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/domain/entities/country.dart';

import '../../widgets/app_text.dart';

class CountryItemView extends StatelessWidget {
  const CountryItemView({super.key, required this.data});

  final Country data;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO:
        },
        child: Column(
          spacing: 8.0,
          children: [
            const SizedBox(height: 12.0),
            Padding(
              padding: .symmetric(
                horizontal: 24.0,
              ),
              child: Card(
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  // TODO: Build reusable image widget.
                  child: CachedNetworkImage(
                    imageUrl: data.flags?.png ?? '-',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            AppText(
              textAlign: .center,
              text: data.name?.common ?? '--',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
