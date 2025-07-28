import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/dio_api_client.dart';
import '../storage/local_storage_service.dart';
import '../storage/shared_preferences_service.dart';

/// Global instance of the dependency injection container
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Initialize external dependencies first
  await _initExternalDependencies();

  // Core dependencies
  _initCoreServices();

  // Feature dependencies will be added later
  // _initAuthDependencies();
  // _initShiftDependencies();
  // _initProfileDependencies();
}

/// Initialize external dependencies that need async setup
Future<void> _initExternalDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

/// Initialize core services
void _initCoreServices() {
  // Dio HTTP client
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.defaultTimeout,
        sendTimeout: AppConfig.defaultTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          logPrint: (object) {
            if (AppConfig.isDebug) {
              print(object);
            }
          },
        ),
      );
    }

    return dio;
  });

  // Local storage service
  getIt.registerLazySingleton<LocalStorageService>(
    () => SharedPreferencesService(getIt<SharedPreferences>()),
  );

  // API Client
  getIt.registerLazySingleton<ApiClient>(
    () => DioApiClient(getIt<Dio>(), getIt<LocalStorageService>()),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
