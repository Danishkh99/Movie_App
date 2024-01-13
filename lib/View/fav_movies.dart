import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:movie_app/Controller/fav_controller.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  State<FavoriteMoviesScreen> createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  var sharedPrefs;
  var controller;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Explorer',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.pinkAccent, Colors.blueAccent])),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<dynamic>(
                future: getFavoriteMovies(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final movies = snapshot.data!;
                    return ListView.builder(
                      itemCount: movies.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Obx(() => controller.isFavorite(movies[index].id)
                            ? Card(
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            "${ApiConfig.imageBaseUrl}${movies[index].posterPath}",
                                        width: 60,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.7,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              movies[index].title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(movies[index].overview,
                                                style: const TextStyle(
                                                    fontSize: 10))
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (controller
                                              .isFavorite(movies[index].id)) {
                                            removeFromFavorites(movies[index]);

                                            controller.toggleFavorite(
                                                movies[index].id);
                                          }
                                          // movies.removeAt(index);
                                          // sharedPrefs.setString(
                                          //     'favoriteMovies',
                                          //     jsonEncode(movies
                                          //         .map(
                                          //             (movie) => movie.toJson())
                                          //         .toList()));
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container());
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching movies'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text("No Favorite movies yet"));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
