// Project imports:
import 'package:comics_db_app/domain/api_client/account_api_client.dart';
import 'package:comics_db_app/domain/api_client/api_client_exception.dart';
import 'package:comics_db_app/domain/api_client/movie_and_tv_api_client.dart';
import 'package:comics_db_app/domain/data_providers/session_data_provider.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_local.dart';

class TvService {
  final _tvApiClient = MovieAndTvApiClient();
  final _sessionDataProvider = SessionDataProvider();
  final _accountApiClient = AccountApiClient();

  Future<TvDetailsLocal> loadTvDetails({required int tvId, required String locale}) async {
    final tvDetails = await _tvApiClient.tvDetails(tvId, locale);
    final sessionId = await _sessionDataProvider.getSessionId();
    var isFavorite = false;
    var isWatchlist = false;
    if (sessionId != null) {
      // Account state is optional: an expired session must not hide the TV show details.
      try {
        isFavorite = await _tvApiClient.isFavoriteTv(tvId, sessionId);
        isWatchlist = await _tvApiClient.isFavoriteTv(tvId, sessionId);
      } on ApiClientException {
        isFavorite = false;
        isWatchlist = false;
      }
    }
    return TvDetailsLocal(details: tvDetails, isFavorite: isFavorite, isWatchlist: isWatchlist);
  }
  
  // Future<TvSeasonLocal> loadTvSeasonDetails({required int tvId, required String locale, required int seasonNumber}) async {
  //   final seasonDetails = await _tvApiClient.tvSeasonsDetails(tvId, locale, seasonNumber);
  //   return TvSeasonLocal(seasons: seasonDetails);
  // }

  Future<void> updateFavoriteTvs({required int tvId, required bool isFavorite}) async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();

    if (sessionId == null || accountId == null) return;
    await _accountApiClient.markAsFavorite(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: MediaType.tv,
      mediaId: tvId,
      isFavorite: isFavorite,
    );
  }

  Future<void> updateWatchlistTV({required int tvId, required bool isWatchlist}) async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();

    if (sessionId == null || accountId == null) return;
    // TODO watch may be i can disable duplicate with media type for other methods
    await _accountApiClient.markAsWatchlist(
      accountId: accountId,
      sessionId: sessionId,
      mediaType: MediaType.tv,
      mediaId: tvId,
      isWatchlist: isWatchlist,
    );
  }
}
