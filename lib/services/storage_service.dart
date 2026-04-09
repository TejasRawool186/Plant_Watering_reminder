import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/plant.dart';

class StorageService {
  static const String _fileName = 'plants_data.json';
  static String? _webMemoryStorage;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<Plant>> loadPlants() async {
    if (kIsWeb) {
      if (_webMemoryStorage == null || _webMemoryStorage!.isEmpty) return [];
      try {
        return Plant.decode(_webMemoryStorage!);
      } catch (e) {
        return [];
      }
    }

    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }
      return Plant.decode(contents);
    } catch (e) {
      debugPrint('Error loading plants: $e');
      return [];
    }
  }

  Future<void> savePlants(List<Plant> plants) async {
    final jsonString = Plant.encode(plants);
    
    if (kIsWeb) {
      _webMemoryStorage = jsonString;
      return;
    }

    try {
      final file = await _localFile;
      final jsonString = Plant.encode(plants);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving plants: $e');
    }
  }
}
