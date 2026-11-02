import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/api_service.dart';
import '../core/auth_repository.dart';
import '../core/local_store.dart';
import '../core/product_repository.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/login_page.dart';
import '../features/products/bloc/products_bloc.dart';
import '../features/favourites/bloc/favourites_bloc.dart';
import '../features/settings/bloc/locale_bloc.dart';
import '../features/settings/theme_bloc/theme_bloc.dart';
import 'shell.dart';

class CatalogueApp extends StatelessWidget {
  const CatalogueApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    final store = LocalStore();
    final auth = AuthRepository(api);
    final products = ProductRepository(api, store);
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: products)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(auth)..add(AuthStarted())),
          BlocProvider(create: (_) => ProductsBloc(products)),
          BlocProvider(
            create: (_) => FavouritesBloc(store)..add(FavouritesLoaded()),
          ),
          BlocProvider(create: (_) => LocaleBloc(store)..add(LocaleLoaded())),
          BlocProvider(create: (_) => ThemeBloc(store)..add(ThemeLoaded())),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, appearance) =>
              BlocBuilder<LocaleBloc, LocaleState>(
                builder: (context, locale) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Catalogue',
                  locale: Locale(locale.language),
                  supportedLocales: const [Locale('en'), Locale('ar')],
                  localizationsDelegates: GlobalMaterialLocalizations.delegates,
                  theme: _catalogueTheme(Brightness.light),
                  darkTheme: _catalogueTheme(Brightness.dark),
                  themeMode: appearance.darkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: BlocListener<AuthBloc, AuthState>(
                    listenWhen: (previous, current) =>
                        previous.status != current.status,
                    listener: (context, state) {
                      if (state.status == AuthStatus.authenticated) {
                        context.read<ProductsBloc>().add(ProductsStarted());
                      }
                    },
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => switch (state.status) {
                        AuthStatus.checking => const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        ),
                        AuthStatus.authenticated => const AppShell(),
                        _ => const LoginPage(),
                      },
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

ThemeData _catalogueTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF086F75),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xFFF7F9F8)
        : scheme.surface,
    cardTheme: CardThemeData(
      color: brightness == Brightness.light
          ? Colors.white
          : scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
