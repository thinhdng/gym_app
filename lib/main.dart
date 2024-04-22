// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api
//authors: Anthony Robbins and Thinh Nguyen

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:final_project/weightloggingpage.dart';

void main() async {
  runApp(const MyApp());
}

// MainApp Class
// Includes title, AD0N1S Fitness which has 0 and 1 as a nod to binary.
// The ThemeData uses a primarySwatch instead of primaryColor to be more
// specific to the MaterialApp use.
// Defined a home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AD0N1S Fitness',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }

  void loadData() async {
    //data loading to be finished here
    SharedPreferences load = await SharedPreferences.getInstance();
    String? dataString = load.getString('userdata');
    Iterable decoder = jsonDecode(dataString!);
    chartData = List<DateAndWeight>.from(decoder.map((item)=> DateAndWeight.fromJson(item)));
  }
}

// Homescreen state stuff
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages for Nutrition and Fitness
  final List<Widget> _pages = [
    const NutritionPage(),
    const FitnessPage(),
    const WeightLoggingPage()
  ];

  // App Bar Stuff
  // Controls page navigation, titles, and icons.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AD0N1S Fitness'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Fitness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight),
            label: 'Weight Tracker',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Start Nutrition Page Stuff
class NutritionInformationTab extends StatelessWidget {
  const NutritionInformationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Suggestions:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
              '- Eat a balanced diet with a variety of fruits and vegetables.'),
          const Text(
              '- Stay hydrated and drink plenty of water throughout the day.'),
          const Text('- Include lean proteins and healthy fats in your meals.'),
          const SizedBox(height: 16.0),
          Text(
            'Foods to Avoid:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text('- Limit processed foods and added sugars.'),
          const Text('- Limit intake of sugary beverages and snacks.'),
          const Text('- Minimize consumption of fried and high-fat foods.'),
          const SizedBox(height: 16.0),
          Text(
            'Types of Diet:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextButton(
              onPressed: () {
                launchUrl(Uri.parse(
                    'https://www.healthline.com/nutrition/9-weight-loss-diets-reviewed#TOC_TITLE_HDR_2'));
              },
              child: const Text(
                  'Click here for more information on the 9 most popular diet')),
          Text(
            'Explore More:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse(
                  'https://www.muscleandfitness.com/nutrition/gain-mass/10-nutrition-rules-follow-if-you-want-build-muscle/'));
            },
            child: const Text('Click here for nutrition rules to build muscle'),
          ),
        ],
      ),
    );
  }
}

class NutritionLogTab extends StatefulWidget {
  const NutritionLogTab({super.key});

  @override
  _NutritionLogTabState createState() => _NutritionLogTabState();
}

class _NutritionLogTabState extends State<NutritionLogTab> {
  late DateTime selectedDate = DateTime.now();
  TextEditingController breakfastController = TextEditingController();
  TextEditingController lunchController = TextEditingController();
  TextEditingController dinnerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null && pickedDate != selectedDate) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            child: Text(
              '${selectedDate.toLocal()}'.split(' ')[0],
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Log Your Meals:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          _buildMealInput('Breakfast', breakfastController),
          const SizedBox(height: 8.0),
          _buildMealInput('Lunch', lunchController),
          const SizedBox(height: 8.0),
          _buildMealInput('Dinner', dinnerController),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Handle saving the logged meals for the selected date
              _saveLoggedMeals();
            },
            child: const Text('Save Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealInput(String mealType, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$mealType:',
          style: const TextStyle(fontSize: 16),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $mealType here...',
          ),
        ),
      ],
    );
  }

  void _saveLoggedMeals() {
    // Still have to implement saving the logged meals to a specific date
  }
}

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Information'),
            Tab(text: 'Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Nutrition Information Tab
          NutritionInformationTab(),

          // Nutrition Log Tab
          NutritionLogTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Start Fitness Page Stuff
class FitnessInformationTab extends StatelessWidget {
  const FitnessInformationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Lifting Benefits:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text('- Builds muscle strength and endurance.'),
          const Text('- Boosts metabolism and aids in weight management.'),
          const Text(
              '- Improves bone density and reduces the risk of osteoporosis.'),
          const SizedBox(height: 16.0),
          Text(
            'Explore More:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse(
                  'https://www.healthline.com/health/fitness/how-to-gain-muscle'));
            },
            child: const Text('Click here for nutrition rules to build muscle'),
          )
        ],
      ),
    );
  }
}

class FitnessWorkoutsTab extends StatefulWidget {
  const FitnessWorkoutsTab({super.key});

  @override
  _FitnessWorkoutsTabState createState() => _FitnessWorkoutsTabState();
}

class _FitnessWorkoutsTabState extends State<FitnessWorkoutsTab> {
  Map<String, List<bool>> workoutChecklist = {
    'Chest/Tri': List.generate(5, (index) => false),
    'Back/Biceps': List.generate(5, (index) => false),
    'Legs/Shoulders': List.generate(5, (index) => false),
  };

  final Map<String, List<String>> workoutCategories = {
    'Chest/Tri': [
      '30 Push-Ups',
      '3 x 12 Bench Press',
      '3 x 12 Skull-Crushers',
      '3 x 15 Drop-Set Tricep Pull-Down',
      '3 x 12 Drop-Set Pec Fly'
    ],
    'Back/Biceps': [
      '2 x 10 Pull-Ups',
      '3 x 15 Deadlift',
      '3 x 15 Drop-Set Bicep Curl',
      '3 x 15 Lat Pull-Down',
      '3 x 15 Drop-Set Preacher Curl'
    ],
    'Legs/Shoulders': [
      '4 x 12 Traditional Squat',
      '3 x 12 Shoulder Press',
      'Max Drop-Set Hack Squat',
      '3 x 12 Lateral Shoulder Raise',
      'Drop-Set Hamstring Curls'
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a calendar or schedule display here
          const SizedBox(height: 16.0),
          Text(
            'Workout Checklist:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (var day in workoutChecklist.keys)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                for (var exercise in workoutCategories[day]!)
                  CheckboxListTile(
                    title: Text(exercise),
                    value: workoutChecklist[day]![
                        workoutCategories[day]!.indexOf(exercise)],
                    onChanged: (value) {
                      setState(() {
                        workoutChecklist[day]![
                            workoutCategories[day]!.indexOf(exercise)] = value!;
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class FitnessPage extends StatefulWidget {
  const FitnessPage({super.key});

  @override
  _FitnessPageState createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Information'),
            Tab(text: 'Workouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Fitness Information Tab
          FitnessInformationTab(),

          // Fitness Workouts Tab
          FitnessWorkoutsTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
