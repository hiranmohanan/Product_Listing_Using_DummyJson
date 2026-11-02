import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/local_store.dart';
import '../../../core/product.dart';

part 'favourites_event.dart';
part 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  FavouritesBloc(this.store) : super(const FavouritesState()) {
    on<FavouritesLoaded>((event, emit) async {
      final items = await store.readFavourites();
      emit(FavouritesState(items));
    });
    on<FavouriteToggled>((event, emit) async {
      final items = [...state.items];
      final index = items.indexWhere((item) => item.id == event.product.id);
      if (index >= 0) {
        items.removeAt(index);
      } else {
        items.insert(0, event.product);
      }
      emit(FavouritesState(items));
      await store.saveFavourites(items);
    });
  }
  final LocalStore store;
}
