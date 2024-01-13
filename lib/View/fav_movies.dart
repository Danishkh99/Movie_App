import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/View/MovieListWidget.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  State<FavoriteMoviesScreen> createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  var sharedPrefs;
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
                        return MovieCard(movie: movies[index]);
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
            ],
          ),
        ),
      ),
    );
  }
}
