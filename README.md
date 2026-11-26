# Lawnly

Lawnly is a lawn care planner built with Flutter. It schedules mowing, watering, fertilizing and other treatments, using the weather forecast and your own routine. The app interface is in Polish.

## Features

- **Care calendar:** automatic plan with flexible fertilizing windows, plus your own tasks
- **Weather-aware advice:** suggests treatment days based on the forecast
- **Fertilizer programs:** ready-made schedules based on ICL, Mr. Green Grass and YaraMila products, with dose and total amount calculated for your lawn area
- **Custom plans:** set your own product, dose and interval
- **Multiple lawns:** each with its own settings, calendar and journal
- **Reminders:** local notifications, weather warnings and a heavy rain alert on program treatment days
- **Photo journal:** history of treatments, notes and a season summary
- **Guide:** lawn care tips and sprinkler calibration
- **AI assistant:** lawn questions and photo diagnosis, with offline quick answers

## Tech stack

- Flutter and Dart
- flutter_bloc, freezed, get_it, go_router
- Cloudflare Worker backend for the AI assistant (Google Gemini, with Workers AI as fallback)
- Weather data from [MET Norway](https://api.met.no); geocoding and past rainfall from [Open-Meteo](https://open-meteo.com)

## Getting started

This project uses [FVM](https://fvm.app) with Flutter 3.41.0. Generated `*.g.dart` and `*.freezed.dart` files are not committed, so run the code generator before the first build.

```sh
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter run
```

Run the tests:

```sh
fvm flutter test
```

## AI assistant

The backend lives in `worker/`. Point the app at your own deployment with:

```sh
fvm flutter run --dart-define=ASSISTANT_URL=https://your-worker.example.workers.dev
```

Pass an empty value (`--dart-define=ASSISTANT_URL=`) to turn the assistant off.

To deploy the worker, create your own KV namespace, put its id in `worker/wrangler.toml`, and set your Gemini API key as a secret:

```sh
cd worker
npm install
npx wrangler kv namespace create QUOTA
npx wrangler secret put GEMINI_API_KEY
npm run deploy
```

If you fork this project, change the MET Norway `User-Agent` in `lib/data/weather/forecast_repository.dart` to identify your own app.

## Disclaimer

Fertilizer programs are examples, and Lawnly is not affiliated with the manufacturers. Always check the product label before applying.
