part of 'favourites_bloc.dart';

class FavouritesState {
  const FavouritesState([this.items = const []]);
  final List<Product> items;
  bool contains(int id) => items.any((item) => item.id == id);
}
