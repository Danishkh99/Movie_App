import 'dart:convert';

import 'package:movie_app/model/Movie.dart';
import 'package:movie_app/model/api_config.dart';
import 'package:http/http.dart' as http;

class MovieService {
  static Future<List<Movie>> fetchPopularMovies() async {
    //fetching upcoming movies
    final response = await http.get(Uri.parse(
      '${ApiConfig.baseUrl}/movie/upcoming?api_key=${ApiConfig.apiKey}',
    ));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      List<Movie> movies = results.map((json) => Movie.fromJson(json)).toList();

      return movies;
    } else {
      throw Exception('Failed to fetch movies');
    }
  }
}
