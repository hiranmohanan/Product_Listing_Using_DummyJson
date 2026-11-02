import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/strings.dart';
import '../features/products/products_page.dart';
import '../features/favourites/favourites_page.dart';
import '../features/settings/settings_page.dart';
import '../features/products/bloc/products_bloc.dart';
import 'bloc/shell_bloc.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => ShellBloc(), child: const _ShellView());
}

class _ShellView extends StatelessWidget {
  const _ShellView();

  @override
  Widget build(BuildContext context) => BlocBuilder<ShellBloc, ShellState>(
    builder: (context, state) => Scaffold(
      body: IndexedStack(
        index: state.index,
        children: const [ProductsPage(), FavouritesPage(), SettingsPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.index,
        onDestinationSelected: (value) {
          context.read<ShellBloc>().add(ShellTabSelected(value));
          if (value == 0 && context.read<ProductsBloc>().state.offline) {
            context.read<ProductsBloc>().add(ProductsRetryRequested());
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: tr(context, 'products'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: tr(context, 'favourites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: tr(context, 'settings'),
          ),
        ],
      ),
    ),
  );
}
