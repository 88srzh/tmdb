<h1 align="center">The Movie Database Mobile</h1>

[//]: # '<h4 align="center">'
[//]: # '<a name="install">Install</a>'
[//]: # "·"
[//]: # '<a href="">Docs</a>'
[//]: # "</h4>"

<p align="center">
    <img src="https://img.shields.io/github/last-commit/88srzh/tmdb?color=%237DC2E8&logo=GitHub" />
    <img src="https://img.shields.io/github/repo-size/88srzh/tmdb?color=%23F097A1&logo=Github" />
    <img src="https://img.shields.io/github/license/88srzh/tmdb?color=%23C9A8EF" />

[//]: # "number of lines doesn't work, try when it will be fix"
[//]: # '<img src="https://img.shields.io/tokei/lines/githubtp/88srzh/tmdb?color=%23EED49F">'

</p>

<p align="center">The Movie Database Mobile (TMDBM) is a popular database for movies and TV shows.</p>

## 🌟 Preview

<p>
<img src="https://raw.githubusercontent.com/88srzh/tmdb/main/images/readme/People_screen_light_theme.png" alt="popular people" width="200">
<img src="https://raw.githubusercontent.com/88srzh/tmdb/main/images/readme/Movie_list_screen_light_theme.png" alt="all movies" width="200">
<img src="https://raw.githubusercontent.com/88srzh/tmdb/main/images/readme/Screenshot_135.png" alt="movie details" width="200">
<img src="https://raw.githubusercontent.com/88srzh/tmdb/main/images/readme/Screenshot_134_edit.png" alt="movies list" width="200">
</p>

[//]: # "## ✨ Features"

## ⚡ Requirements

- Account on the https://www.themoviedb.org/

> Or you can use guest login.

## 🛠️ Installation

#### Clone the repository

```shell
git clone --depth 5 https://github.com/88srzh/tmdb
```

#### Add your TMDb API key

Get an API key (v3) at https://www.themoviedb.org/settings/api, then:

```shell
cp secrets.example.json secrets.json
# put your key into secrets.json as the TMDB_API_KEY value
```

`secrets.json` is git-ignored. Pass it on every run and build:

```shell
flutter run --dart-define-from-file=secrets.json
flutter build apk --dart-define-from-file=secrets.json
```
