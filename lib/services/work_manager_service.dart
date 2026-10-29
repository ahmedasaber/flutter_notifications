import 'dart:developer';
import 'package:workmanager/workmanager.dart';

class WorkManagerService{
  final Workmanager workManager = Workmanager();
  void callbackDispatcher(){

  }

  // init work manager service
  void init() async{
    await workManager.initialize(callbackDispatcher);
    registerMyTask();
  }

  Future<void> registerMyTask() async{
    await workManager.registerOneOffTask('uniqueName', 'taskName');
  }

  //
  Future<void> cancelTask(String uniqueName) async{
    await workManager.cancelByUniqueName(uniqueName);
  }
}
