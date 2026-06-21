import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recipe {
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  Recipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
  });
}

class RecipeGenerator {
  // Get API endpoint URL from SharedPreferences
  Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('backend_url') ?? 'https://amenities-whom-petroleum-update.trycloudflare.com';

  }

  Future<List<Recipe>> generateRecipesFromImage(File imageFile) async {
    try {
      final apiUrl = await getApiUrl();
      // Create multipart request
      print(apiUrl);
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/predict'));
      // Add the image file to the request
      var imageStream = http.ByteStream(imageFile.openRead());
      var imageLength = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'file',
        imageStream,
        imageLength,
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      // Send the request and get the response
      var response = await http.Response.fromStream(await request.send());
      // Check if the request was successful
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        // Handle the response
        if (jsonResponse['status'] == 'success') {
          String title = jsonResponse['title'] ?? 'Unknown Recipe';
          List<dynamic> ingredientsList = jsonResponse['ingredients'] ?? [];
          List<dynamic> instructionsList = jsonResponse['instructions'] ?? [];
          // Convert dynamic lists to String lists
          List<String> ingredients = List<String>.from(ingredientsList);
          List<String> instructions = List<String>.from(instructionsList);
          // Return the Recipe object
          return [
            Recipe(
              name: title,
              description:
              "Recipe for $title with ${ingredients.length} ingredients",
              ingredients: ingredients,
              instructions: instructions,
            ),
          ];
        } else {
          throw Exception('API response failure: ${jsonResponse['status']}');
        }
      } else {
        throw Exception(
            'Request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating recipe: $e');
      // Return a default recipe in case of error
      return [
        Recipe(
          name: "Error Detecting Recipe",
          description:
          "There was an error processing your image. Please try again.",
          ingredients: ["Unable to detect ingredients"],
          instructions: ["Please try again with a clearer image of food"],
        ),
      ];
    }
  }
}