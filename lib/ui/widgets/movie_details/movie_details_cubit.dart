// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:comics_db_app/domain/api_client/api_client_exception.dart';
import 'package:comics_db_app/domain/api_client/movie_and_tv_api_client.dart';
import 'package:comics_db_app/domain/entity/movie_details.dart';
import 'package:comics_db_app/domain/services/movie_service.dart';
import 'package:comics_db_app/ui/navigation/main_navigation.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/actor_data.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/external_ids_data.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/movie_details_all_videos_data.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/movie_details_data.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/movie_details_reviews_data.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/movie_details_videos_data.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/movie_people_data.dart';
import 'package:comics_db_app/ui/widgets/movie_details/components/recommendations_data.dart';

part 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsCubitState> {
  late DateFormat _dateFormat;
  final data = MovieDetailsData();
  final movieAndTvApiClient = MovieAndTvApiClient();
  final int movieId;
  final _movieService = MovieService();

  // TODO may be delete isLoading, because it's unnecessary
  final bool isLoading = true;

  MovieDetailsCubit(this.movieId)
      // TODO should fix
      : super(MovieDetailsCubitState(
          id: 0,
          posterPath: '',
          backdropPath: '',
          overview: '',
          localeTag: '',
          title: '',
          tagline: '',
          voteAverage: 0,
          voteCount: 0,
          popularity: 0,
          releaseDate: '',
          runtime: '',
          genres: '',
          peopleData: [],
          actorsData: [],
          isLoading: false,
          isFavorite: false,
          isWatchlist: false,
          recommendations: [],
          videos: [],
          allVideos: [],
          externalIds: MovieDetailsExternalIdsData(),
          facebookId: '',
          imdbId: '',
          wikidataId: '',
          instagramId: '',
          twitterId: '',
          homepage: '',
          reviews: [],
          originalLanguage: '',
          budget: 0,
          revenue: 0,
          status: '',
          keywords: '',
          // similar: [],
          // collection: [],
        )) {
    emit(MovieDetailsCubitState(
      id: state.id,
      posterPath: state.posterPath,
      backdropPath: state.backdropPath,
      overview: state.overview,
      localeTag: state.localeTag,
      title: state.title,
      tagline: state.tagline,
      voteAverage: state.voteAverage,
      voteCount: state.voteCount,
      popularity: state.popularity,
      releaseDate: state.releaseDate,
      runtime: state.runtime,
      genres: state.genres,
      peopleData: state.peopleData,
      actorsData: state.actorsData,
      isLoading: state.isLoading,
      isFavorite: state.isFavorite,
      isWatchlist: state.isWatchlist,
      recommendations: state.recommendations,
      videos: state.videos,
      allVideos: state.allVideos,
      externalIds: state.externalIds,
      facebookId: state.facebookId,
      imdbId: state.imdbId,
      wikidataId: state.wikidataId,
      instagramId: state.instagramId,
      twitterId: state.twitterId,
      homepage: state.homepage,
      reviews: state.reviews,
      originalLanguage: state.originalLanguage,
      budget: state.budget,
      revenue: state.revenue,
      status: state.status,
      keywords: state.keywords,
      // similar: state.similar,
      // collection: state.collection,
    ));
  }

  Future<void> loadMovieDetails(BuildContext context) async {
    try {
      final details = await _movieService.loadMovieDetails(movieId: movieId, locale: state.localeTag);
      updateData(details.details, details.isFavorite, details.isWatchlist);
    } on ApiClientException catch (e) {
      _handleApiClientException(e);
    } catch (e, stackTrace) {
      // Parsing errors used to be lost silently, leaving the screen empty.
      debugPrint('Failed to load movie $movieId: $e\n$stackTrace');
    }
  }

  void _handleApiClientException(ApiClientException exception) {
    switch (exception.type) {
      case ApiClientExceptionType.sessionExpired:
        // _authService.logout();
        // MainNavigation.resetNavigation();
        break;
      case ApiClientExceptionType.other:
        // print('exception other');
        break;
      default:
      // print(exception);
    }
  }

  Future<void> setupMovieDetailsLocale(BuildContext context, String localeTag) async {
    if (state.localeTag == localeTag) return;
    final newState = state.copyWith(localeTag: localeTag);
    emit(newState);
    // final locale = Localizations.localeOf(context).toLanguageTag();
    // if (_locale == locale) return;
    // _locale = locale;
    _dateFormat = DateFormat.yMMMd(localeTag);
    // if (!_localeStorage.updateLocale(locale)) return;
    updateData(null, false, false);
    await loadMovieDetails(context);
  }

  void updateData(MovieDetails? details, bool isFavorite, bool isWatchlist) {
    // TODO may be i need await somewhere here
    data.isLoading = details == null;
    if (details == null) {
      return;
    }
    final int id = data.id = details.id;
    final String overview = data.overview = details.overview ?? 'Loading description...';
    final String title = data.title = details.title;
    final String tagline = data.tagline = details.tagline ?? 'Loading tagline..';
    final double voteAverage = data.voteAverage = details.voteAverage;
    final int voteCount = data.voteCount = details.voteCount;
    final double popularity = data.popularity = details.popularity;
    final String releaseDate = data.releaseDate = makeReleaseDate(details);
    final String runtime = data.runtime = makeSummary(details);
    final String genres = data.genres = makeGenres(details);
    final List<List<MovieDetailsMoviePeopleData>> peopleData = data.peopleData = makePeopleData(details);
    final String? posterPath = data.posterPath = details.posterPath;
    final String? backdropPath = data.backdropPath = details.backdropPath;
    final List<MovieDetailsVideosData>? videosData = data.videosData = makeTrailerKey(details);
    final String originalLanguage = data.originalLanguage = details.originalLanguage;
    final int budget = data.budget = details.budget;
    final int revenue = data.revenue = details.revenue;
    final String status = data.status = details.status;
    final String? homepage = data.homepage = details.homepage;
    final String? facebookId = data.facebookId = details.externalIds.facebookId;
    final bool isFavoriteData = data.favoriteData.isFavorite = isFavorite;
    final bool isWatchlistData = data.watchlistData.isWatchlist = isWatchlist;
    final bool isLoading = data.isLoading;
    final String keywordString = makeKeywords(details);

    // if (details.belongsToCollection != null) {
    //   data.collectionData = details.belongsToCollection!.map((e) => BelongsToCollectionData(id: e.id, name: e.name, posterPath: e.posterPath, backdropPath: e.backdropPath)).toList();
    // }

    final List<MovieDetailsMovieActorData> actorsData =
        data.actorsData = details.credits.cast.map((e) => MovieDetailsMovieActorData(name: e.name, character: e.character, profilePath: e.profilePath, id: e.id)).toList();

    // data.similarData = details.similar.similar.map((e) => MovieDetailsSimilarData(id: e.id, title: e.title, posterPath: e.posterPath, genreIds: e.genreIds)).toList();

    final List<MovieDetailsRecommendationsData> recommendations = data.recommendationsData =
        details.recommendations.recommendationsResults.map((e) => MovieDetailsRecommendationsData(id: e.id, title: e.title, posterPath: e.posterPath, backdropPath: e.backdropPath)).toList();

    final List<MovieDetailsAllVideosData> allVideos = data.allVideosData = details.videos.results
        .map((e) => MovieDetailsAllVideosData(name: e.name, key: e.key, site: e.site, size: e.size, type: e.type, official: e.official, publishedAt: e.publishedAt, id: e.id))
        .toList();

    final List<MovieDetailsReviewsData> reviews = data.reviewsData = details.reviews.result
        .map((e) => MovieDetailsReviewsData(
            author: e.author,
            // authorDetails:
            //     e.authorDetails.map((e) => AuthorDetailsData(name: e.name, username: e.username, avatarPath: e.avatarPath, rating: e.rating)).toList(),
            content: e.content,
            createdAt: makeCreatedAtReviews(details),
            id: e.id,
            updatedAt: e.updatedAt.toString(),
            url: e.url))
        .toList();

    // var similar = data.similarData;
    // var collection = data.collectionData;

    final newState = state.copyWith(
      id: id,
      backdropPath: backdropPath,
      posterPath: posterPath,
      overview: overview,
      title: title,
      tagline: tagline,
      voteAverage: voteAverage,
      voteCount: voteCount,
      popularity: popularity,
      releaseDate: releaseDate,
      runtime: runtime,
      genres: genres,
      peopleData: peopleData,
      actorsData: actorsData,
      isLoading: isLoading,
      isFavorite: isFavoriteData,
      isWatchlist: isWatchlistData,
      recommendations: recommendations,
      videos: videosData,
      allVideos: allVideos,
      externalIds: MovieDetailsExternalIdsData(),
      facebookId: facebookId,
      homepage: homepage,
      reviews: reviews,
      originalLanguage: originalLanguage,
      budget: budget,
      revenue: revenue,
      status: status,
      keywords: keywordString,

      // similar: similar,
      // collection: collection,
    );
    emit(newState);
  }

  List<MovieDetailsVideosData>? makeTrailerKey(MovieDetails details) {
    final videos = details.videos.results.where((video) => video.type == "Trailer" && video.site == 'YouTube');
    if (videos.isNotEmpty) {
      String trailerKey = videos.first.key;
      var videosData = details.videos.results.map((e) => MovieDetailsVideosData(key: trailerKey)).toList();
      return videosData;
    } else {
      return null;
    }
  }

  String makeReleaseDate(MovieDetails details) {
    var texts = <String>[];
    final releaseDate = details.releaseDate;
    if (releaseDate != null) {
      texts.add(_dateFormat.format(releaseDate));
    }
    return texts.join(' ');
  }

  String makeCreatedAtReviews(MovieDetails details) {
    var texts = <String>[];
    final createdAt = details.reviews.result.first.createdAt;
    texts.add(_dateFormat.format(createdAt));
    return texts.join(' ');
  }

  String makeSummary(MovieDetails details) {
    var texts = <String>[];
    if (details.productionCountries.isNotEmpty) {
      texts.add('(${details.productionCountries.first.iso})');
    }
    final runtime = details.runtime ?? 0;
    final duration = Duration(minutes: runtime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    texts.add('${hours}h ${minutes}min');
    return texts.join(' ');
  }

  String makeGenres(MovieDetails details) {
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

  String makeKeywords(MovieDetails details) {
    var texts = <String>[];
    if (details.keywords.keywords.isNotEmpty) {
      var keywordsNames = <String>[];
      for (var keyword in details.keywords.keywords) {
        keywordsNames.add(keyword.name);
      }
      texts.add(keywordsNames.join(', '));
    }
    return texts.join(', ');
  }

  List<List<MovieDetailsMoviePeopleData>> makePeopleData(MovieDetails details) {
    var crew = details.credits.crew.map((e) => MovieDetailsMoviePeopleData(name: e.name, job: e.job)).toList();
    crew = crew.length > 4 ? crew.sublist(0, 4) : crew;
    var crewChunks = <List<MovieDetailsMoviePeopleData>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewChunks.add(crew.sublist(i, i + 2 > crew.length ? crew.length : i + 2));
    }
    return crewChunks;
  }

  void toggleFavoriteMovie(BuildContext context) {
    data.favoriteData = data.favoriteData.copyWith(isFavorite: !data.favoriteData.isFavorite);
    try {
      _movieService.updateFavoriteMovie(movieId: movieId, isFavorite: data.favoriteData.isFavorite);
      var newState = state.copyWith(isFavorite: data.favoriteData.isFavorite);
      emit(newState);
    } on ApiClientException catch (e) {
      _handleApiClientException(e);
    }
  }

  void toggleWatchlistMovie(BuildContext context) {
    data.watchlistData = data.watchlistData.copyWith(isWatchlist: !data.watchlistData.isWatchlist);
    try {
      _movieService.updateWatchlistMovie(movieId: movieId, isWatchlist: data.watchlistData.isWatchlist);
      var newState = state.copyWith(isWatchlist: data.watchlistData.isWatchlist);
      emit(newState);
    } on ApiClientException catch (e) {
      _handleApiClientException(e);
    }
  }

  void tapToSeeFullCastAndCrewList(BuildContext context, int index) {
    final id = state.id;
    Navigator.of(context).pushNamed(MainNavigationRouteNames.movieDetailsFullCastAndCrewList, arguments: id);
  }

  void tapToSeeFullListOfReviews(BuildContext context, int index) {
    final id = state.id;
    Navigator.of(context).pushNamed(MainNavigationRouteNames.movieDetailsFullReviewsList, arguments: id);
  }
}
