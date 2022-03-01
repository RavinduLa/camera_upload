import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ApplicationState extends ChangeNotifier{
  ApplicationState(){
    init();
  }

  Future<void> init()  async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print('firebase app initialized');
    notifyListeners();
  }
}