import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return Future.value(true);
  });
}

void initializeWorkManager() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask("taskCheck", "CheckIncompleteTasks", frequency: Duration(hours: 1));
}
