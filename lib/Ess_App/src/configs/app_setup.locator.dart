import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
// Add import for your AuthService

import '../services/local/auth_service.dart';
import '../services/local/connectivity_service.dart';
import '../services/local/keyboard_service.dart';
import '../services/remote/api_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  Environment? environmentFilter,
}) async {

  // Register Stacked Services
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => BottomSheetService());

  // Register your custom services here
  locator.registerLazySingleton(() => AuthService()); // Add this line
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => ConnectivityService());
  locator.registerLazySingleton(() => KeyboardService());

  // Add other custom services as needed
  // locator.registerLazySingleton(() => YourOtherService());
}