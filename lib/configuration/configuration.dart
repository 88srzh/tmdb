class Configuration {
  // TODO: надо бы убрать static
  static const host = 'https://api.themoviedb.org/3';
  static const imageUrl = 'https://image.tmdb.org/t/p/w500';
  // Задаётся через --dart-define-from-file=secrets.json, см. README
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');
}
