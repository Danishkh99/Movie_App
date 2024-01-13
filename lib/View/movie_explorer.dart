import 'package:flutter/material.dart';
import 'package:movie_app/View/fav_movies.dart';
import 'package:movie_app/View/MovieListWidget.dart';
import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/MovieService.dart';

class MovieExplorerApp extends StatefulWidget {
  const MovieExplorerApp({super.key});

  @override
  State<MovieExplorerApp> createState() => _MovieExplorerAppState();
}

class _MovieExplorerAppState extends State<MovieExplorerApp> {
  List<Movie> movies = [];

  Future<List<Movie>> fetchMovies() async {
    try {
      final List<Movie> fetchedMovies = await MovieService.fetchPopularMovies();

      movies = fetchedMovies;
    } catch (e) {
      print('Error fetching movies: $e');
    }
    return movies;
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const FavoriteMoviesScreen()));
                  },
                  child: const Text("Favorite Movies")),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder<dynamic>(
                future: fetchMovies(),
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
