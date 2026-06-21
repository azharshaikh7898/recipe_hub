import 'package:best_flutter_ui_templates/fitness_app/models/tabIcon_data.dart';
import 'package:best_flutter_ui_templates/fitness_app/training/training_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
import 'my_diary/my_diary_screen.dart';
import 'package:best_flutter_ui_templates/fitness_app/ui_view/user_info.dart';
import 'package:best_flutter_ui_templates/fitness_app/gemini_chat/gemini_chat_screen.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    tabIconsList.forEach((tab) => tab.isSelected = false);
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _screens = [
      MyDiaryScreen(animationController: animationController),
      TrainingScreen(animationController: animationController),
      GeminiChatScreen(),
      UserPage(),
    ];
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
                children: <Widget>[
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
                  bottomBar(),
                ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(child: SizedBox()),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {},
          changeIndex: (int index) {
                setState(() {
              _currentIndex = index;
              for (int i = 0; i < tabIconsList.length; i++) {
                tabIconsList[i].isSelected = i == index;
              }
              });
          },
        ),
      ],
    );
  }
}
