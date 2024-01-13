import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Controller/fav_controller.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class MovieCard extends StatefulWidget {
  final Movie movie; // Your movie data model

  const MovieCard({required this.movie});

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  var sharedPrefs;
  var controller = Get.put(FavoritesController());

  void saveFavoriteMovies(List<Movie> favorites) async {
    final favoritesJson =
        jsonEncode(favorites.map((movie) => movie.toJson()).toList());
    await sharedPrefs.setString('favoriteMovies', favoritesJson);
  }

  void removeFromFavorites(Movie movieToRemove) async {
    final favorites = await getFavoriteMovies();
    favorites.removeWhere((movie) =>
        movie.id ==
        movieToRemove.id); // Assuming you have a unique ID for each movie
    saveFavoriteMovies(favorites);
  }

  Future<List<Movie>> getFavoriteMovies() async {
    sharedPrefs = await SharedPreferences.getInstance();

    final favoritesJson = sharedPrefs.getString('favoriteMovies');
    if (favoritesJson == null) {
      return [];
    } else {
      final List<dynamic> decodedFavorites = jsonDecode(favoritesJson);
      return decodedFavorites
          .map((movieData) => Movie.fromJson(movieData))
          .toList();
    }
  }

  @override
  void initState() {
    controller = Get.put(FavoritesController());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CachedNetworkImage(
              imageUrl: "${ApiConfig.imageBaseUrl}${widget.movie.posterPath}",
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.movie.overview,
                      style: const TextStyle(fontSize: 10))
                ],
              ),
            ),
            Obx(
              () => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () async {
                          if (controller.isFavorite(widget.movie.id)) {
                            removeFromFavorites(widget.movie);
                          } else {
                            final favorites = await getFavoriteMovies();
                            favorites.add(widget.movie);
                            saveFavoriteMovies(favorites);
                          }
                          controller.toggleFavorite(widget.movie.id);
                        },
                        child: controller.isFavorite(widget.movie.id)
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.pink,
                              )
                            : const Icon(Icons.favorite_border)),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Release Date",
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      widget.movie.releaseDate,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
