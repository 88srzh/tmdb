// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Project imports:
import 'package:comics_db_app/core/dark_theme_colors.dart';
import 'package:comics_db_app/domain/api_client/image_downloader.dart';
import 'package:comics_db_app/domain/blocs/theme/theme_bloc.dart';
import 'package:comics_db_app/generated/l10n.dart';
import 'package:comics_db_app/resources/resources.dart';
import 'package:comics_db_app/ui/components/custom_cast_list_text_widget.dart';
import 'package:comics_db_app/ui/components/custom_movie_list_box_decoration_widgets.dart';
import 'package:comics_db_app/ui/widgets/tv_details/tv_details_cubit.dart';

class TvDetailsSeasonsWidget extends StatelessWidget {
  final String currentSeason;

  const TvDetailsSeasonsWidget({super.key, required this.currentSeason});

  @override
  Widget build(BuildContext context) {
    var cubit = context.watch<TvDetailsCubit>();
    if (cubit.state.seasons.isEmpty) return const SizedBox.shrink();
    final lastSeason = cubit.state.seasons.last;
    final String? posterPath = lastSeason.posterPath;
    final String lastSeasonName = lastSeason.name;
    final double voteAverage = (lastSeason.voteAverage ?? 0) * 10;
    final String? airDateByYear = cubit.state.airDateOfSeason;
    final String? lastAirDate = cubit.state.lastAirDate;
    final int episodeCount = lastSeason.episodeCount;
    final int seasonNumber = lastSeason.seasonNumber;
    final String lastEpisodeToAirName = cubit.state.lastEpisodeToAirName;
    final String lastEpisodeToAirType = cubit.state.lastEpisodeToAirType;
    final String name = cubit.state.name;
    final int id = cubit.state.id;

    Color textColor = context.read<ThemeBloc>().isDarkTheme ? Colors.white : DarkThemeColors.kPrimaryColor;
    Color reverseTextColor = context.read<ThemeBloc>().isDarkTheme ? DarkThemeColors.kPrimaryColor : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currentSeason, style: Theme.of(context).textTheme.titleMedium),
          Container(
            decoration: context.read<ThemeBloc>().isDarkTheme ? customMovieListBoxDecorationForDarkTheme : customMovieListBoxDecorationForLightTheme,
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                posterPath != null ? Image.network(ImageDownloader.imageUrl(posterPath), width: 95.0) : Image.asset(AppImages.noImageAvailable),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [Text(lastSeasonName, style: Theme.of(context).textTheme.displaySmall)],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Column(
                            children: [
                              // may be delete picture
                              Container(
                                decoration: BoxDecoration(
                                  color: textColor,
                                  border: Border.all(
                                    color: context.read<ThemeBloc>().isDarkTheme ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                                  ),
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Row(
                                    children: [
                                      Icon(MdiIcons.star, size: 12, color: reverseTextColor),
                                      Text(
                                        '${voteAverage.toStringAsFixed(0)}%',
                                        style: TextStyle(color: reverseTextColor, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                '$airDateByYear • $episodeCount ${S.of(context).episodes}',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      CustomCastListTextWidget(text: 'Сезон 1 сериала "$name", вышел $lastAirDate.', maxLines: 3),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Icon(MdiIcons.calendar, size: 14, color: context.read<ThemeBloc>().isDarkTheme ? Colors.white : DarkThemeColors.kPrimaryColor),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Stack(
                              children: [
                                Text(
                                  lastEpisodeToAirName,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomCastListTextWidget(text: '(${seasonNumber}x$episodeCount, $lastAirDate)', maxLines: 1),
                          const SizedBox(width: 5.0),
                          Container(
                            decoration: BoxDecoration(
                              color: textColor,
                              border: Border.all(
                                color: context.read<ThemeBloc>().isDarkTheme ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                lastEpisodeToAirType.isEmpty
                                    ? S.of(context).season
                                    : '${S.of(context).season} ${lastEpisodeToAirType[0].toUpperCase()}${lastEpisodeToAirType.substring(1)}',
                                style: TextStyle(color: reverseTextColor, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: InkWell(
              onTap: () => cubit.tapToSeeFullListOfSeasons(context, id),
              // onTap: () => Navigator.of(context).pushNamed(MainNavigationRouteNames.tvDetailsFullListOfSeasons),
              child: Text('Смотреть все сезоны', style: Theme.of(context).textTheme.displayMedium),
            ),
          ),
        ],
      ),
    );
  }
}
