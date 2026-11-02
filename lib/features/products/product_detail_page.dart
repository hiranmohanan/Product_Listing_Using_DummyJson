import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/product_card.dart';
import '../../core/product_repository.dart';
import '../../core/strings.dart';
import '../favourites/bloc/favourites_bloc.dart';
import 'detail_bloc/detail_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        DetailBloc(context.read<ProductRepository>(), id)..add(DetailStarted()),
    child: const _DetailView(),
  );
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) => BlocBuilder<DetailBloc, DetailState>(
    builder: (context, state) {
      final product = state.product;
      return Scaffold(
        appBar: AppBar(
          title: Text(tr(context, 'products')),
          actions: [
            if (product != null)
              BlocBuilder<FavouritesBloc, FavouritesState>(
                builder: (context, favourites) => IconButton(
                  tooltip: tr(context, 'favourites'),
                  onPressed: () => context.read<FavouritesBloc>().add(
                    FavouriteToggled(product),
                  ),
                  icon: Icon(
                    favourites.contains(product.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favourites.contains(product.id)
                        ? Colors.redAccent
                        : null,
                  ),
                ),
              ),
          ],
        ),
        body: state.loading && product == null
            ? const Center(child: CircularProgressIndicator())
            : product == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr(
                        context,
                        state.error.isEmpty ? 'loadError' : state.error,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<DetailBloc>().add(DetailRetried()),
                      child: Text(tr(context, 'retry')),
                    ),
                  ],
                ),
              )
            : ListView(
                children: [
                  if (state.offline)
                    MaterialBanner(
                      content: Text(tr(context, 'offline')),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              context.read<DetailBloc>().add(DetailRetried()),
                          child: Text(tr(context, 'retry')),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 310,
                    child: PageView(
                      children:
                          (product.images.isEmpty
                                  ? [product.thumbnail]
                                  : product.images)
                              .map((url) => ProductImage(url: url))
                              .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFE6A23C),
                            ),
                            Text(product.rating.toStringAsFixed(1)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Chip(label: Text(product.category)),
                        if (product.brand != null &&
                            product.brand!.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('${tr(context, 'brand')}: ${product.brand!}'),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          tr(context, 'description'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      );
    },
  );
}
