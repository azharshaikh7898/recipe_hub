import 'package:best_flutter_ui_templates/fitness_app/ui_view/title_view.dart';
import 'package:best_flutter_ui_templates/fitness_app/ui_view/workout_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:best_flutter_ui_templates/recipe_hub/services/image_service.dart';

import '../fitness_app_theme.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  static List<Map<String, dynamic>> libraryRecipes = [];

  static void Function()? refreshLibraryCallback;

  // Save the current library to shared preferences
  static Future<void> saveLibraryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the list to a format that can be safely serialized
    final List<Map<String, dynamic>> serializableRecipes = libraryRecipes.map((recipe) {
      return {
        'title': recipe['title'] as String,
        'image': recipe['image'] as String,
        'ingredients': (recipe['ingredients'] as List<dynamic>).map((item) => item.toString()).toList(),
        'steps': recipe['steps'] as String,
      };
    }).toList();
    final recipesJson = jsonEncode(serializableRecipes);
    await prefs.setString('libraryRecipes', recipesJson);
  }

  // Load the library from shared preferences
  static Future<void> loadLibraryFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getString('libraryRecipes');
    if (recipesJson != null) {
      try {
      final List<dynamic> decoded = jsonDecode(recipesJson);
        libraryRecipes = decoded.map((e) {
          final Map<String, dynamic> recipe = Map<String, dynamic>.from(e);
          // Check if image file exists
          final imagePath = recipe['image'] as String;
          if (!imagePath.startsWith('assets/')) {
            final file = File(imagePath);
            if (!file.existsSync()) {
              // If image doesn't exist, use a placeholder
              recipe['image'] = 'assets/fitness_app/placeholder.png';
            }
          }
          return {
            'title': recipe['title'] as String,
            'image': recipe['image'] as String,
            'ingredients': (recipe['ingredients'] as List<dynamic>).map((item) => item.toString()).toList(),
            'steps': recipe['steps'] as String,
          };
        }).toList();
      } catch (e) {
        print('Error loading recipes: $e');
        libraryRecipes = []; // Reset to empty list if there's an error
      }
    }
  }

  static Future<void> addNewRecipe(
      String title, String imagePath, List<String> ingredients, String steps) async {
    try {
      // Create a new recipe map with proper types
      final newRecipe = {
      'title': title,
      'image': imagePath,
      'ingredients': ingredients,
      'steps': steps,
      };
      
      // Add to the list
      libraryRecipes.add(newRecipe);
      
      // Save to preferences
    await saveLibraryToPrefs();
      
      // Notify UI to update
    if (refreshLibraryCallback != null) {
      refreshLibraryCallback!();
      }
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow;
    }
  }

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Load recipes from storage before building the list
    TrainingScreen.loadLibraryFromPrefs().then((_) {
      if (mounted) {
      setState(() {});
      }
    });

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    addAllListData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });

    // Set the callback for refreshing the library
    TrainingScreen.refreshLibraryCallback = () {
      if (mounted) setState(() {});
    };

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void addAllListData() {
    const int count = 5;

    listViews.clear();

    listViews.add(
      TitleView(
        titleTxt: 'Saved Recipes',
        subTxt: 'Add New',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // Create a new list for recipes to ensure proper type safety
    final List<Map<String, dynamic>> safeRecipes = TrainingScreen.libraryRecipes.map((recipe) {
      return {
        'title': recipe['title'] as String,
        'image': recipe['image'] as String,
        'ingredients': (recipe['ingredients'] as List<dynamic>).map((item) => item.toString()).toList(),
        'steps': recipe['steps'] as String,
      };
    }).toList();

    listViews.add(
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: safeRecipes.length,
        itemBuilder: (context, index) {
          return RecipeCard(
            title: safeRecipes[index]['title'],
            imagePath: safeRecipes[index]['image'],
            ingredients: List<String>.from(safeRecipes[index]['ingredients']),
            steps: safeRecipes[index]['steps'],
            onDelete: () async {
              TrainingScreen.libraryRecipes.removeAt(index);
              await TrainingScreen.saveLibraryToPrefs();
              if (TrainingScreen.refreshLibraryCallback != null) {
                TrainingScreen.refreshLibraryCallback!();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Recipe deleted from your library!'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LibraryRecipeDetailScreen(
                    title: safeRecipes[index]['title'],
                    imagePath: safeRecipes[index]['image'],
                    ingredients: List<String>.from(safeRecipes[index]['ingredients']),
                    steps: safeRecipes[index]['steps'],
                    showDelete: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    listViews.add(
      TitleView(
        titleTxt: 'Popular Recipes',
        subTxt: 'See All',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / count) * 3, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    // Popular Recipes Section
    final List<Map<String, dynamic>> popularRecipes = [
      {
        'title': 'Classic Margherita Pizza',
        'image': 'assets/fitness_app/pizza.png',
        'description': 'A traditional Italian pizza with fresh tomatoes, mozzarella, basil, and extra virgin olive oil.',
        'ingredients': [
          'Pizza dough',
          'San Marzano tomatoes',
          'Fresh mozzarella',
          'Fresh basil leaves',
          'Extra virgin olive oil',
          'Salt and pepper'
        ],
        'cookingTime': '30 mins',
        'difficulty': 'Medium'
      },
      {
        'title': 'Chicken Tikka Masala',
        'image': 'assets/fitness_app/chicken_tikka.png',
        'description': 'A rich and creamy curry dish with tender chicken pieces marinated in yogurt and spices.',
        'ingredients': [
          'Chicken breast',
          'Yogurt',
          'Garam masala',
          'Turmeric',
          'Cumin',
          'Coriander',
          'Heavy cream',
          'Tomato sauce'
        ],
        'cookingTime': '45 mins',
        'difficulty': 'Medium'
      },
      {
        'title': 'Chocolate Lava Cake',
        'image': 'assets/fitness_app/lava_cake.png',
        'description': 'A decadent dessert with a warm, flowing chocolate center and a soft cake exterior.',
        'ingredients': [
          'Dark chocolate',
          'Butter',
          'Eggs',
          'Sugar',
          'Flour',
          'Vanilla extract',
          'Salt'
        ],
        'cookingTime': '20 mins',
        'difficulty': 'Easy'
      },
      {
        'title': 'Beef Bourguignon',
        'image': 'assets/fitness_app/beef_bourguignon.png',
        'description': 'A classic French stew made with beef braised in red wine, mushrooms, and pearl onions.',
        'ingredients': [
          'Beef chuck',
          'Red wine',
          'Beef broth',
          'Carrots',
          'Onions',
          'Mushrooms',
          'Bacon',
          'Garlic',
          'Thyme'
        ],
        'cookingTime': '3 hours',
        'difficulty': 'Hard'
      }
    ];

    listViews.add(
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: popularRecipes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Navigate to recipe details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LibraryRecipeDetailScreen(
                      title: popularRecipes[index]['title'],
                      imagePath: popularRecipes[index]['image'],
                      ingredients: List<String>.from(popularRecipes[index]['ingredients']),
                      steps: popularRecipes[index]['description'],
                      showDelete: false,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        popularRecipes[index]['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          popularRecipes[index]['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              popularRecipes[index]['cookingTime'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.star, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              popularRecipes[index]['difficulty'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
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

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    addAllListData();

    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Library',
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    DateFormat('d MMMM').format(DateTime.now()),
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

class RecipeCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<String> ingredients;
  final String steps;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const RecipeCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  Future<File?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    if (!widget.imagePath.startsWith('assets/')) {
      _imageFuture = ImageService.getImageFromLocal(widget.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'recipe_${widget.title}',
      child: Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
          onTap: widget.onTap,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: widget.imagePath.startsWith('assets/')
                      ? Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : FutureBuilder<File?>(
                          future: _imageFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.file(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            }
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                  style: TextStyle(
                    fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${widget.ingredients.length} ingredients',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class LibraryRecipeDetailScreen extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<String> ingredients;
  final String steps;
  final bool showDelete;

  const LibraryRecipeDetailScreen({
    required this.title,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    print('LibraryRecipeDetailScreen imagePath: ' + imagePath);
    if (imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        imagePath,
        fit: BoxFit.cover,
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
        );
      } else {
        print('File does not exist: ' + imagePath);
        imageWidget = Image.asset(
          'assets/fitness_app/placeholder.png',
          fit: BoxFit.cover,
        );
      }
    }
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: imageWidget,
            ),
            backgroundColor: FitnessAppTheme.nearlyDarkBlue,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: FitnessAppTheme.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(Icons.restaurant_menu, '${ingredients.length}', 'Ingredients'),
                      _buildInfoCard(Icons.list, steps.split('\n').length.toString(), 'Steps'),
                      _buildInfoCard(Icons.access_time, 'Varies', 'Cooking Time'),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.fiber_manual_record, size: 8, color: FitnessAppTheme.grey),
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
                  )),
                  SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...steps.split('\n').asMap().entries.map((entry) {
                    int idx = entry.key;
                    String step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                '${idx + 1}',
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
                              step,
                              style: TextStyle(
                                fontSize: 16,
                                color: FitnessAppTheme.darkerText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 30),
                  if (showDelete)
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete, color: Colors.white),
                      label: Text('Delete Recipe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // Find the recipe index by title and imagePath (unique enough for this context)
                        int index = TrainingScreen.libraryRecipes.indexWhere((recipe) =>
                          recipe['title'] == title && recipe['image'] == imagePath);
                        if (index != -1) {
                          TrainingScreen.libraryRecipes.removeAt(index);
                          await TrainingScreen.saveLibraryToPrefs();
                          if (TrainingScreen.refreshLibraryCallback != null) {
                            TrainingScreen.refreshLibraryCallback!();
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Recipe deleted from your library!'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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