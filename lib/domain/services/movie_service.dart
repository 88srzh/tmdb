// Project imports:
import 'package:comics_db_app/domain/api_client/account_api_client.dart';
import 'package:comics_db_app/domain/api_client/api_client_exception.dart';
import 'package:comics_db_app/domain/api_client/movie_and_tv_api_client.dart';
import 'package:comics_db_app/domain/data_providers/session_data_provider.dart';
import 'package:comics_db_app/domain/local_entity/movie_details_local.dart';

class MovieService {
  final _movieAndTvApiClient = MovieAndTvApiClient();
  final _sessionDataProvider = SessionDataProvider();
  final _accountApiClient = AccountApiClient();

  Future<MovieDetailsLocal> loadMovieDetails({required int movieId, required String locale}) async {
    final movieDetails = await _movieAndTvApiClient.movieDetails(movieId, locale);
    final sessionId = await _sessionDataProvider.getSessionId();
    var isFavorite = false;
    var isWatchlist = false;
    if (sessionId != null) {
      // Account state is optional: an expired session must not hide the movie details.
      try {
        isFavorite = await _movieAndTvApiClient.isFavoriteMovie(movieId, sessionId);
        isWatchlist = await _movieAndTvApiClient.isWatchlistMovie(movieId, sessionId);
      } on ApiClientException {
        isFavorite = false;
        isWatchlist = false;
      }
    }
    return MovieDetailsLocal(details: movieDetails, isFavorite: isFavorite, isWatchlist: isWatchlist);
  }

  Future<void> updateFavoriteMovie({required int movieId, required bool isFavorite}) async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();

    if (sessionId == null || accountId == null) return;
    await _accountApiClient.markAsFavorite(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: MediaType.movie,
      mediaId: movieId,
      isFavorite: isFavorite,
    );
  }

  Future<void> updateWatchlistMovie({required int movieId, required bool isWatchlist}) async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();

    if (sessionId == null || accountId == null) return;
    await _accountApiClient.markAsWatchlist(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: MediaType.movie,
      mediaId: movieId,
      isWatchlist: isWatchlist,
    );
  }
}
