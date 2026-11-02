part of 'favourites_bloc.dart';

sealed class FavouritesEvent {}

class FavouritesLoaded extends FavouritesEvent {}

class FavouriteToggled extends FavouritesEvent {
  FavouriteToggled(this.product);
  final Product product;
}
