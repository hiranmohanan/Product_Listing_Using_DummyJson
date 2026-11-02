import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/product_card.dart';
import '../../core/strings.dart';
import 'bloc/favourites_bloc.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, 'favourites'))),
    body: BlocBuilder<FavouritesBloc, FavouritesState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 52,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(tr(context, 'noFavourites')),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth < 600 ? 2 : 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: constraints.maxWidth < 600 ? .72 : .9,
            ),
            itemBuilder: (context, index) =>
                ProductCard(product: state.items[index]),
          ),
        );
      },
    ),
  );
}
