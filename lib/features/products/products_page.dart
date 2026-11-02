import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/product_card.dart';
import '../../core/strings.dart';
import '../scanner/scanner_page.dart';
import 'bloc/products_bloc.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr(context, 'products')),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(tr(context, 'scan')),
          onPressed: () async {
            final id = await Navigator.of(
              context,
            ).push<int>(MaterialPageRoute(builder: (_) => const ScannerPage()));
            if (!context.mounted || id == null) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductDetailPage(id: id)),
            );
          },
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            onChanged: (value) => context.read<ProductsBloc>().add(
              ProductsSearchInputChanged(value),
            ),
            decoration: InputDecoration(
              hintText: tr(context, 'search'),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) => Column(
              children: [
                if (state.offline)
                  MaterialBanner(
                    content: Text(tr(context, 'offline')),
                    leading: const Icon(Icons.wifi_off),
                    actions: [
                      TextButton(
                        onPressed: () => context.read<ProductsBloc>().add(
                          ProductsRetryRequested(),
                        ),
                        child: Text(tr(context, 'retry')),
                      ),
                    ],
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<ProductsBloc>();
                      bloc.add(ProductsRefreshed());
                      await bloc.stream.firstWhere(
                        (s) => !s.loading && !s.loadingMore,
                      );
                    },
                    child: state.items.isEmpty
                        ? ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * .25,
                              ),
                              if (state.loading)
                                const Center(child: CircularProgressIndicator())
                              else
                                Center(
                                  child: Text(
                                    tr(
                                      context,
                                      state.error.isNotEmpty
                                          ? state.error
                                          : 'noProducts',
                                    ),
                                  ),
                                ),
                              if (!state.loading)
                                Center(
                                  child: TextButton(
                                    onPressed: () => context
                                        .read<ProductsBloc>()
                                        .add(ProductsRetryRequested()),
                                    child: Text(tr(context, 'retry')),
                                  ),
                                ),
                            ],
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification.metrics.extentAfter < 400) {
                                context.read<ProductsBloc>().add(
                                  ProductsNextPageRequested(),
                                );
                              }
                              return false;
                            },
                            child: CustomScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(12),
                                  sliver: SliverLayoutBuilder(
                                    builder: (context, constraints) =>
                                        SliverGrid.builder(
                                          itemCount: state.items.length,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    constraints
                                                            .crossAxisExtent <
                                                        600
                                                    ? 2
                                                    : 3,
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                                childAspectRatio:
                                                    constraints
                                                            .crossAxisExtent <
                                                        600
                                                    ? .72
                                                    : .9,
                                              ),
                                          itemBuilder: (context, index) =>
                                              ProductCard(
                                                product: state.items[index],
                                              ),
                                        ),
                                  ),
                                ),
                                if (state.loadingMore)
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                if (state.error.isNotEmpty)
                                  SliverToBoxAdapter(
                                    child: Center(
                                      child: TextButton(
                                        onPressed: () => context
                                            .read<ProductsBloc>()
                                            .add(ProductsNextPageRequested()),
                                        child: Text(tr(context, 'retry')),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
