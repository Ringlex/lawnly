import 'package:lawnly/core/l10n/language_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:lawnly/core/constants/app_const.dart';
import 'package:lawnly/data/assistant/assistant_client.dart';
import 'package:lawnly/data/assistant/install_id_store.dart';
import 'package:lawnly/domain/assistant/assistant_service.dart';
import 'package:http/http.dart' as http;
import 'package:lawnly/data/journal/journal_entry.dart';
import 'package:lawnly/data/journal/journal_repository.dart';
import 'package:lawnly/data/journal/photo_store.dart';
import 'package:lawnly/data/lawn/lawn_directory.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/lawn/lawn_scoped_storage_adapter.dart';
import 'package:lawnly/domain/lawn/lawn_service.dart';
import 'package:lawnly/data/lawn/lawn_repository.dart';
import 'package:lawnly/data/local/adapter/shared_preferences_adapter.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';
import 'package:lawnly/data/local/single_value_store.dart';
import 'package:lawnly/data/location/location_repository.dart';
import 'package:lawnly/data/notifications/local_notification_gateway.dart';
import 'package:lawnly/data/notifications/notification_prefs.dart';
import 'package:lawnly/domain/notifications/notification_scheduler.dart';
import 'package:lawnly/data/plan/care_plan.dart';
import 'package:lawnly/data/plan/plan_repository.dart';
import 'package:lawnly/data/weather/forecast_repository.dart';
import 'package:lawnly/domain/plan/care_calendar.dart';
import 'package:lawnly/domain/plan/care_planner.dart';
import 'package:lawnly/domain/plan/care_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final photoStore = await PhotoStore.create();
  final notificationGateway = LocalNotificationGateway();
  await notificationGateway.initialize();

  final storage = SharedPreferencesAdapter(sharedPreferences: sharedPreferences);
  final language = await LanguageController.load(storage);
  final lawnDirectory = await LawnDirectory.load(storage);
  final lawnStorage = LawnScopedStorageAdapter(adapter: storage, lawns: lawnDirectory);

  getIt
    ..registerSingleton<StorageAdapter>(storage)
    ..registerSingleton(language)
    ..registerSingleton(lawnDirectory)
    ..registerSingleton<http.Client>(http.Client())
    ..registerSingleton(
      LawnRepository(
        store: SingleValueStore<LawnProfile>(
          adapter: lawnStorage,
          key: LawnDirectory.profileKey,
          fromJson: LawnProfile.fromJson,
        ),
      ),
    )
    ..registerSingleton(
      PlanRepository(
        store: SingleValueStore<CarePlan>(
          adapter: lawnStorage,
          key: 'care_plan',
          fromJson: CarePlan.fromJson,
        ),
      ),
    )
    ..registerSingleton(
      JournalRepository(
        store: SingleValueStore<Journal>(
          adapter: lawnStorage,
          key: 'journal',
          fromJson: Journal.fromJson,
        ),
      ),
    )
    ..registerSingleton(photoStore)
    ..registerSingleton(LocationRepository(client: getIt()))
    ..registerSingleton<ForecastRepository>(MetNoForecastRepository(client: getIt()))
    ..registerSingleton(const CarePlanner())
    ..registerSingleton(CareCalendar(planner: getIt()))
    ..registerSingleton(InstallIdStore(preferences: sharedPreferences))
    ..registerSingleton(
      CareService(
        lawnRepository: getIt(),
        planRepository: getIt(),
        forecastRepository: getIt(),
        journalRepository: getIt(),
        photoStore: getIt(),
      ),
      dispose: (service) => service.dispose(),
    )
    ..registerSingleton(NotificationPrefsRepository(adapter: getIt()))
    ..registerSingleton<NotificationGateway>(notificationGateway)
    ..registerSingleton(NotificationStateRepository(adapter: getIt()))
    ..registerSingleton(NotificationScheduler(gateway: getIt(), prefs: getIt(), state: getIt()))
    ..registerSingleton(LawnService(directory: getIt(), notifications: getIt()))
    ..registerSingleton(
      AssistantService(
        client: AppConfig.assistantUrl.isEmpty
            ? null
            : AssistantClient(baseUrl: AppConfig.assistantUrl, client: getIt()),
        installIds: getIt(),
        careService: getIt(),
      ),
    );
}
