import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/favourites/bloc/favourites_bloc.dart';
import '../features/products/product_detail_page.dart';
import 'product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailPage(id: product.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(url: product.thumbnail),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: BlocBuilder<FavouritesBloc, FavouritesState>(
                    builder: (context, state) => Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: .94),
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () => context.read<FavouritesBloc>().add(
                          FavouriteToggled(product),
                        ),
                        icon: Icon(
                          state.contains(product.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: state.contains(product.id)
                              ? Colors.redAccent
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFE6A23C),
                    ),
                    Text(product.rating.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImageFallback();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => const _ImageFallback(),
      errorWidget: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.image_outlined,
      size: 40,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
