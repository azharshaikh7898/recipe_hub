import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/fitness_app/fitness_app_theme.dart';
import 'package:best_flutter_ui_templates/recipe_hub/models/recipe_model.dart';
import 'dart:io';
import 'package:best_flutter_ui_templates/fitness_app/training/training_screen.dart';
import 'package:best_flutter_ui_templates/recipe_hub/services/image_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final File imageFile;

  const RecipeDetailsScreen(
      {Key? key, required this.recipes, required this.imageFile})
      : super(key: key);

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.recipes.length, vsync: this);

    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        backgroundColor: FitnessAppTheme.background,
        elevation: 0,
        title: Text(
          'Recipe Results',
          style: TextStyle(
            color: FitnessAppTheme.darkerText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: widget.recipes.length > 1
            ? TabBar(
          controller: _tabController,
          indicatorColor: FitnessAppTheme.nearlyDarkBlue,
          labelColor: FitnessAppTheme.nearlyDarkBlue,
          unselectedLabelColor: FitnessAppTheme.grey,
          tabs: widget.recipes
              .map((recipe) => Tab(text: recipe.name))
              .toList(),
        )
            : null,
      ),
      body: TabBarView(
        controller: _tabController,
        children:
        widget.recipes.map((recipe) => _buildRecipeTab(recipe)).toList(),
      ),
    );
  }

  Widget _buildRecipeTab(Recipe recipe) {
    final Animation<double> animation =
    Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval((1 / widget.recipes.length) * 0.5, 1.0,
            curve: Curves.fastOutSlowIn),
      ),
    );

    return SingleChildScrollView(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: animation,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 30 * (1.0 - animation.value), 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image of food
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Recipe name and description
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: FitnessAppTheme.darkerText,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          recipe.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: FitnessAppTheme.darkerText,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Recipe metadata - simplified since we don't have these properties
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCard(Icons.restaurant_menu,
                                '${recipe.ingredients.length}', 'Ingredients'),
                            _buildInfoCard(Icons.list,
                                '${recipe.instructions.length}', 'Steps'),
                            _buildInfoCard(
                                Icons.access_time, 'Varies', 'Cooking Time'),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Ingredients section
                        Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: FitnessAppTheme.darkerText,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...recipe.ingredients
                            .map((ingredient) => Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.fiber_manual_record,
                                  size: 8, color: FitnessAppTheme.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                            .toList(),

                        SizedBox(height: 24),

                        // Instructions section
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: FitnessAppTheme.darkerText,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...List.generate(
                            recipe.instructions.length,
                                (index) => Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: FitnessAppTheme.nearlyDarkBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      recipe.instructions[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: FitnessAppTheme.darkerText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),

                        SizedBox(height: 16),
                        // Add to Library Button
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  // Save the image to local storage
                                  final savedImagePath = await ImageService.saveImageToLocal(widget.imageFile);
                                  print('Image saved to: $savedImagePath');
                                  
                                  // Add the recipe to library
                                  await TrainingScreen.addNewRecipe(
                                    recipe.name,
                                    savedImagePath,
                                    recipe.ingredients,
                                    recipe.instructions.join('\n'),
                                  );
                                  
                                  // Show success message
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Recipe added to your library!'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('Error adding recipe: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to add recipe: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Add to Library',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: FitnessAppTheme.grey.withOpacity(0.2),
            offset: Offset(1.1, 1.1),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: FitnessAppTheme.nearlyDarkBlue),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: FitnessAppTheme.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}