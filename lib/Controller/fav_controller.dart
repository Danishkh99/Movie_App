import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesController extends GetxController {
  final _favorites = <int>{}.obs;
  late SharedPreferences sharedPrefs;

  @override
  void onInit() {
    super.onInit();
    initSharedPreferences();
  }

  void initSharedPreferences() async {
    sharedPrefs = await SharedPreferences.getInstance();
    // Load existing favorites from Shared Preferences
    final savedFavorites = sharedPrefs.getStringList('favoriteMovies');
    if (savedFavorites != null) {
      _favorites.value = savedFavorites.map((id) => int.parse(id)).toSet();
    }
  }

  bool isFavorite(int movieId) => _favorites.contains(movieId);

  void toggleFavorite(int movieId) {
    if (isFavorite(movieId)) {
      _favorites.remove(movieId);
    } else {
      _favorites.add(movieId);
    }
    update(); // Notify UI
    // saveFavorites(); // Save to Shared Preferences
  }

  // void saveFavorites() async {
  //   // ignore: invalid_use_of_protected_member
  //   final favoritesIds = _favorites.value.map((id) => id.toString()).toList();
  //   await sharedPrefs.setStringList('favoriteMovies', favoritesIds);
  // }
}
