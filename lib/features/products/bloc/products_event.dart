part of 'products_bloc.dart';

sealed class ProductsEvent {}

class ProductsStarted extends ProductsEvent {}

class ProductsRefreshed extends ProductsEvent {}

class ProductsNextPageRequested extends ProductsEvent {}

class ProductsRetryRequested extends ProductsEvent {}

class ProductsSearchInputChanged extends ProductsEvent {
  ProductsSearchInputChanged(this.value);
  final String value;
}

class ProductsQueryChanged extends ProductsEvent {
  ProductsQueryChanged(this.query);
  final String query;
}
