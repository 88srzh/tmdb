// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:comics_db_app/domain/api_client/api_client_exception.dart';
import 'package:comics_db_app/domain/api_client/movie_and_tv_api_client.dart';
import 'package:comics_db_app/domain/entity/tv_details.dart';
import 'package:comics_db_app/domain/entity/tv_details_credits.dart';
import 'package:comics_db_app/domain/entity/tv_details_videos.dart';
import 'package:comics_db_app/domain/services/tv_service.dart';
import 'package:comics_db_app/ui/navigation/main_navigation.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_actor_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_created_by_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_network_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_people_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_recommendations_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_season_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_trailer_data.dart';
import 'package:comics_db_app/ui/widgets/tv_details/components/tv_details_videos_data.dart';

part 'tv_details_state.dart';

class TvDetailsCubit extends Cubit<TvDetailsCubitState> {
  late DateFormat _dateFormat;
  final data = TvDetailsData();
  final movieAndTvClient = MovieAndTvApiClient();
  final int tvId;
  final _tvService = TvService();

  TvDetailsCubit(this.tvId)
      : super(TvDetailsCubitState(
          posterPath: '',
          backdropPath: '',
          createdBy: [],
          episodeRunTime: [],
          firstAirDate: '',
          lastAirDate: '',
          genres: '',
          homepage: '',
          id: 0,
          inProduction: false,
          languages: [],
          airDateOfSeason: '',
          lastEpisodeToAir: LastEpisodeToAir(
            airDate: '',
            episodeNumber: 0,
            id: 0,
            name: '',
            overview: '',
            productionCode: '',
            seasonNumber: 0,
            stillPath: '',
            voteAverage: 0,
            voteCount: 0,
            episodeType: '',
          ),
          name: '',
          networks: [],
          numberOfEpisodes: 0,
          numberOfSeasons: 0,
          originalCountry: [],
          originalLanguage: '',
          originalName: '',
          overview: '',
          popularity: 0,
          productionCompanies: [],
          productionCountries: [],
          seasons: [],
          spokenLanguages: [],
          status: '',
          tagline: '',
          type: '',
          voteAverage: 0,
          voteCount: 0,
          localeTag: '',
          credits: TvDetailsCredits(cast: [], crew: []),
          videos: TvDetailsVideos(results: []),
          isFavorite: false,
          isWatchlist: false,
          actorsData: [],
          peopleData: [],
          recommendationsData: [],
          videosData: [],
          rating: '',
          keywords: '',
          lastEpisodeToAirName: '',
          lastEpisodeToAirType: '',
        )) {
    emit(TvDetailsCubitState(
      posterPath: state.posterPath,
      backdropPath: state.backdropPath,
      createdBy: state.createdBy,
      episodeRunTime: state.episodeRunTime,
      firstAirDate: state.firstAirDate,
      lastAirDate: state.lastAirDate,
      genres: state.genres,
      homepage: state.homepage,
      id: state.id,
      inProduction: state.inProduction,
      languages: state.languages,
      airDateOfSeason: state.airDateOfSeason,
      lastEpisodeToAir: state.lastEpisodeToAir,
      name: state.name,
      networks: state.networks,
      numberOfEpisodes: state.numberOfEpisodes,
      numberOfSeasons: state.numberOfSeasons,
      originalCountry: state.originalCountry,
      originalLanguage: state.originalLanguage,
      originalName: state.originalName,
      overview: state.overview,
      popularity: state.popularity,
      productionCompanies: state.productionCompanies,
      productionCountries: state.productionCountries,
      seasons: state.seasons,
      spokenLanguages: state.spokenLanguages,
      status: state.status,
      tagline: state.tagline,
      type: state.type,
      voteAverage: state.voteAverage,
      voteCount: state.voteCount,
      credits: state.credits,
      videos: state.videos,
      localeTag: state.localeTag,
      isFavorite: state.isFavorite,
      isWatchlist: state.isWatchlist,
      actorsData: state.actorsData,
      peopleData: state.peopleData,
      recommendationsData: state.recommendationsData,
      videosData: state.videosData,
      rating: state.rating,
      keywords: state.keywords,
      lastEpisodeToAirName: state.lastEpisodeToAirName,
      lastEpisodeToAirType: state.lastEpisodeToAirType,
    ));
  }

  // may be add to separate file
  String stringFromDate(DateTime? date) => date != null ? _dateFormat.format(date) : '';

  Future<void> loadTvDetails(BuildContext context) async {
    try {
      final details = await _tvService.loadTvDetails(tvId: tvId, locale: state.localeTag);
      updateData(details.details, details.isFavorite, details.isWatchlist);
    } on ApiClientException catch (e) {
      _handleApiClientException(e);
    } catch (e, stackTrace) {
      // Parsing errors used to be lost silently, leaving the screen empty.
      debugPrint('Failed to load TV show $tvId: $e\n$stackTrace');
    }
  }

  void _handleApiClientException(ApiClientException exception) {
    switch (exception.type) {
      case ApiClientExceptionType.sessionExpired:
        // _authService.logout();
        // MainNavigation.resetNavigation(context);
        break;
      case ApiClientExceptionType.other:
        // print('exception other');
        break;
      default:
      // print(exception);
    }
  }

  Future<void> setupTvDetailsLocale(BuildContext context, String localeTag) async {
    if (state.localeTag == localeTag) return;
    final newState = state.copyWith(localeTag: localeTag);
    emit(newState);
    _dateFormat = DateFormat.yMMMd(localeTag);
    updateData(null, false, false);
    await loadTvDetails(context);
  }

  void updateData(TVDetails? details, bool isFavorite, bool isWatchlist) {
    if (details == null) {
      return;
    }

    final String name = data.name = details.name;
    final String overview = data.overview = details.overview;
    final String? posterPath = data.posterPath = details.posterPath;
    final String? backdropPath = data.backdropPath = details.backdropPath;
    final String? tagline = data.tagline = details.tagline;
    final String firstAirDate = data.firstAirDate = makeFirstAirDate(details);
    final String? lastAirDate = data.lastAirDate = makeFullFirstAirDateOfSeason(details);
    final String? airDateOfSeason = data.airDateOfSeason = makeAirDateOfSeason(details);
    final String? rating = makeRating(details);
    final String genres = data.genres = makeGenres(details);
    final List<List<TvDetailsPeopleData>> peopleData = data.peopleData = makePeopleData(details);
    final List<TvDetailsVideosData>? videosData = data.videosData = makeTrailerKey(details);
    final List<List<TvDetailsCreatedByData>> createdByData = data.createdByData = makeCreatedByData(details);
    final bool isFavoriteData = data.favoriteData.isFavorite = isFavorite;
    final bool isWatchlistData = data.watchlistData.isWatchlist = isWatchlist;
    final String status = data.status = details.status;
    final String originalLanguage = data.originalLanguage = details.originalLanguage;
    final String type = data.type = details.type;
    final String keywords = data.keywords = makeKeywords(details);
    final String lastEpisodeToAirName = data.lastEpisodeToAirData.name = details.lastEpisodeToAir?.name ?? '';
    final String lastEpisodeToAitType = data.lastEpisodeToAirData.episodeType = details.lastEpisodeToAir?.episodeType ?? '';

    var actorsData = data.actorsData =
        details.credits.cast.map((e) => TvDetailsActorData(name: e.name, character: e.character, profilePath: e.profilePath, id: e.id)).toList();

    data.tvDetailsScoresData = TvDetailsScoresData(voteCount: details.voteCount, popularity: details.voteAverage, voteAverage: details.voteAverage);

    var recommendationsData = data.recommendationsData = details.recommendations.recommendationsList
        .map((e) => TvDetailsRecommendationsData(id: e.id, name: e.name, posterPath: e.posterPath, backdropPath: e.backdropPath))
        .toList();

    var networkData = data.networkData =
        details.networks.map((e) => TvDetailsNetworkData(name: e.name, id: e.id, logoPath: e.logoPath, originCountry: e.originCountry)).toList();

    var seasonData = data.seasonData = details.seasons
        .map((e) => TvsSeasonData(
            airDate: e.airDate,
            fullAirDate: e.airDate,
            episodeCount: e.episodeCount,
            id: e.id,
            name: e.name,
            overview: e.overview,
            posterPath: e.posterPath,
            seasonNumber: e.seasonNumber,
            voteAverage: e.voteAverage))
        .toList();

    final newState = state.copyWith(
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      name: name,
      tagline: tagline,
      firstAirDate: firstAirDate,
      voteCount: data.tvDetailsScoresData.voteCount,
      popularity: data.tvDetailsScoresData.popularity,
      voteAverage: data.tvDetailsScoresData.voteAverage,
      genres: genres,
      peopleData: peopleData,
      actorsData: actorsData,
      isFavorite: isFavoriteData,
      isWatchlist: isWatchlistData,
      recommendationsData: recommendationsData,
      videosData: videosData,
      createdBy: createdByData,
      rating: rating,
      networks: networkData,
      status: status,
      type: type,
      originalLanguage: originalLanguage,
      keywords: keywords,
      seasons: seasonData,
      lastEpisodeToAirName: lastEpisodeToAirName,
      lastEpisodeToAirType: lastEpisodeToAitType,
      lastAirDate: lastAirDate,
      airDateOfSeason: airDateOfSeason,
    );
    emit(newState);
  }

  List<TvDetailsVideosData>? makeTrailerKey(TVDetails details) {
    final videos = details.videos.results.where((video) => video.type == 'Trailer' && video.site == 'YouTube');
    if (videos.isNotEmpty) {
      String trailerKey = videos.first.key;
      var videosData = details.videos.results.map((e) => TvDetailsVideosData(key: trailerKey)).toList();
      return videosData;
    } else {
      return null;
    }
  }

  String makeGenres(TVDetails details) {
    var texts = <String>[];
    if (details.genres.isNotEmpty) {
      var genresNames = <String>[];
      for (var genr in details.genres) {
        genresNames.add(genr.name);
      }
      texts.add(genresNames.join(', '));
    }
    return texts.join(' ');
  }

  String makeKeywords(TVDetails details) {
    var texts = <String>[];
    final keywords = details.keywords.results ?? [];
    if (keywords.isNotEmpty) {
      var keywordsNames = <String>[];
      for (var keyword in keywords) {
        keywordsNames.add(keyword.name);
      }
      texts.add(keywordsNames.join(', '));
    }
    return texts.join(' ');
  }

  String? makeRating(TVDetails details) {
    var texts = <String>[];
    final contentRatings = details.contentRatings.results ?? [];
    if (contentRatings.isNotEmpty) {
      var ratings = <String>[];
      for (var rating in contentRatings) {
        ratings.add(rating.rating);
      }
      texts.add(ratings.first);
      return texts.join();
    } else {
      return null;
    }
  }

  List<List<TvDetailsPeopleData>> makePeopleData(TVDetails details) {
    var crew = details.credits.crew.map((e) => TvDetailsPeopleData(name: e.name)).toList();
    crew = crew.length > 4 ? crew.sublist(0, 4) : crew;
    var crewChunks = <List<TvDetailsPeopleData>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewChunks.add(crew.sublist(i, i + 2 > crew.length ? crew.length : i + 2));
    }
    return crewChunks;
  }

  List<List<TvDetailsCreatedByData>> makeCreatedByData(TVDetails details) {
    var creators = details.createdBy
        .map((e) => TvDetailsCreatedByData(id: e.id, createdId: e.creditId, name: e.name, gender: e.gender, profilePath: e.profilePath.toString()))
        .toList();
    creators = creators.length > 4 ? creators.sublist(0, 4) : creators;
    var creatorsChunks = <List<TvDetailsCreatedByData>>[];
    for (var i = 0; i < creators.length; i += 2) {
      // TODO may be change
      creatorsChunks.add(creators.sublist(i, i + 2 > creators.length ? creators.length : i + 2));
    }
    return creatorsChunks;
  }

  void toggleFavoriteTv(BuildContext context) {
    data.favoriteData = data.favoriteData.copyWith(isFavorite: !data.favoriteData.isFavorite);
    try {
      _tvService.updateFavoriteTvs(tvId: tvId, isFavorite: data.favoriteData.isFavorite);
      var newState = state.copyWith(isFavorite: data.favoriteData.isFavorite);
      emit(newState);
    } on ApiClientException catch (e) {
      _handleApiClientException(e);
    }
  }

  void toggleWatchlistTV(BuildContext context) {
    data.watchlistData = data.watchlistData.copyWith(isWatchlist: !data.watchlistData.isWatchlist);
    try {
      _tvService.updateWatchlistTV(tvId: tvId, isWatchlist: data.watchlistData.isWatchlist);
      var newState = state.copyWith(isWatchlist: data.watchlistData.isWatchlist);
      emit(newState);
    } on ApiClientException catch (e) {
      _handleApiClientException(e);
    }
  }

  String makeFirstAirDate(TVDetails details) {
    var texts = <String>[];
    final firstAirDate = details.firstAirDate;
    if (firstAirDate != null) {
      texts.add(DateFormat.y().format(firstAirDate));
    }
    return texts.join(' ');
  }

  String? makeAirDateOfSeason(TVDetails details) {
    if (details.seasons.isEmpty) return null;
    var texts = <String>[];
    final lastAirDate = details.seasons.first.airDate;
    if (lastAirDate != null) {
      texts.add(DateFormat.y().format(lastAirDate));
    }
    return texts.join(' ');
  }

  String? makeFullFirstAirDateOfSeason(TVDetails details) {
    var texts = <String>[];
    final lastAirDate = details.lastAirDate;
    if (lastAirDate != null) {
      texts.add(DateFormat.yMMMMd().format(lastAirDate));
    }
    return texts.join(' ');
  }

  void tapToSeeFullListOfSeasons(BuildContext context, int index) {
    Navigator.of(context).pushNamed(MainNavigationRouteNames.tvDetailsFullListOfSeasons, arguments: tvId);
  }

  void tapToSeeListOfEpisodes(BuildContext context, int index, int seasonNumber) {
    Navigator.of(context).pushNamed(MainNavigationRouteNames.tvDetailsListOfEpisodes, arguments: [tvId, seasonNumber]);
  }
}
