import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static Future<String> saveImageToLocal(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = File(path.join(directory.path, fileName));
    
    await imageFile.copy(savedImage.path);
    return savedImage.path;
  }

  static Future<File?> getImageFromLocal(String imagePath) async {
    try {
      return File(imagePath);
    } catch (e) {
      return null;
    }
  }
} 