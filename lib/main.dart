import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------- AUTH DATA -------------------
String? registeredName;
String? registeredPassword;

/// ------------------- EXPENSE MODEL -------------------
class Expense {
  String title;
  double amount;
  String category;
  DateTime date;
  Expense(this.title, this.amount, this.category, this.date);
}

List<Expense> expenses = [];
double monthlyBudget = 30000;
double get dailyLimit => monthlyBudget / 30;

/// ------------------- THEME PROVIDER -------------------
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadThemePreference();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
}

/// ------------------- MAIN -------------------
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'PocketLog',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/register': (_) => const RegistrationScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

/// ------------------- SPLASH SCREEN -------------------
/// ------------------- SPLASH SCREEN -------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2)).then((_) {
        Navigator.of(context).pushReplacementNamed('/register');
      });
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Image.asset('assets/appLOGO.jpg', width: 500, height: 500),
            //Icon(Icons.account_balance_wallet, size: 100, color: Colors.teal),
            // Text('PocketLog', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // Removed as requested
          ],
        ),
      ),
    );
  }
}

/// ------------------- REGISTRATION SCREEN -------------------
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}
class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String password = '';
  int age = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Create Your Account", style: TextStyle(fontSize: 20)),
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                onSaved: (val) => age = int.tryParse(val!) ?? 0,
                validator: (val) => (int.tryParse(val!) == null) ? "Enter valid age" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => password = val!,
                validator: (val) => (val!.length < 4) ? "Minimum 4 characters" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Register"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    registeredName = name;
                    registeredPassword = password;
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------- LOGIN SCREEN -------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String inputName = '';
  String inputPassword = '';
  String? errorText;
  void showErrorAndRedirect() async {
    setState(() {
      errorText = "Invalid name or password";
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Login to Your Account", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                onSaved: (val) => inputName = val!.trim(),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => inputPassword = val!,
                validator: (val) => val!.isEmpty ? "Enter password" : null,
              ),
              if (errorText != null) ...[
                const SizedBox(height: 15),
                Text(errorText!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Login"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (inputName == registeredName && inputPassword == registeredPassword) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      showErrorAndRedirect();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------- HOME SCREEN -------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double categoryTotal(String category) {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.category == category &&
            e.date.year == now.year &&
            e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  void showCategoryTotal(String category) {
    double total = categoryTotal(category);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$category Total"),
        content: Text("₹${total.toStringAsFixed(2)} spent this month on $category."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    double totalSpent = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text("PocketLog")),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Total Spent This Month", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text("₹${totalSpent.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  categoryCard("Food", Icons.fastfood, Colors.orange),
                  categoryCard("Transport", Icons.directions_car, Colors.blue),
                  categoryCard("Entertainment", Icons.movie, Colors.purple),
                  categoryCard("Other", Icons.miscellaneous_services, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("All Expenses", style: TextStyle(fontSize: 18)),
            const Divider(),
            expenses.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No expenses yet. Tap + to add one."),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final exp = expenses[index];
                      return Card(
                        child: ListTile(
                          title: Text(exp.title),
                          subtitle: Text("${exp.category} - ${exp.date.toLocal()}".split(' ')[0]),
                          trailing: Text("₹${exp.amount.toStringAsFixed(2)}"),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          setState(() {}); // refresh after expense added
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget categoryCard(String category, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => showCategoryTotal(category),
      child: Card(
        color: color.withOpacity(0.2),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(category,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("₹${categoryTotal(category).toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------- DRAWER -------------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("PocketLog", style: TextStyle(color: Colors.white, fontSize: 22)),
          ),
          _drawerItem(context, Icons.home, "Home", const HomeScreen()),
          _drawerItem(context, Icons.add, "Add Expense", const AddExpenseScreen()),
          _drawerItem(context, Icons.list, "View Expenses", const ViewExpensesScreen()),
          _drawerItem(context, Icons.bar_chart, "Reports", const ReportsScreen()),
          _drawerItem(context, Icons.account_balance_wallet, "Budget Planner", const BudgetPlannerScreen()),
          _drawerItem(context, Icons.calendar_today, "Calendar View", const CalendarViewScreen()),
          _drawerItem(context, Icons.settings, "Settings", const SettingsScreen()),
          _drawerItem(context, Icons.info, "About", const AboutScreen()),
        ],
      ),
    );
  }
  ListTile _drawerItem(BuildContext ctx, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
    );
  }
}

/// ------------------- ADD EXPENSE -------------------
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}
class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double amount = 0;
  String category = 'Food';
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Title"),
                onSaved: (val) => title = val!,
                validator: (val) => val!.isEmpty ? "Enter a title" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                onSaved: (val) => amount = double.parse(val!),
                validator: (val) => val!.isEmpty ? "Enter amount" : null,
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: ["Food", "Transport", "Entertainment", "Other"]
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              ElevatedButton(
                child: const Text("Pick Date"),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => date = picked);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    expenses.add(Expense(title, amount, category, date));
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------- VIEW EXPENSES SCREEN -------------------
class ViewExpensesScreen extends StatelessWidget {
  const ViewExpensesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("View Expenses")),
        body: expenses.isEmpty
            ? const Center(child: Text("No expenses to show."))
            : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final e = expenses[index];
                  return Card(
                    child: ListTile(
                      title: Text(e.title),
                      subtitle: Text(e.category),
                      trailing: Text("₹${e.amount}"),
                    ),
                  );
                },
              ),
      );
}

/// ------------------- REPORTS SCREEN -------------------
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}
class _ReportsScreenState extends State<ReportsScreen> {
  String chartType = "Pie Chart";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: chartType,
            items: ["Pie Chart", "Bar Chart", "Line Chart"]
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (val) => setState(() => chartType = val!),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: expenses.isEmpty
                  ? const Center(child: Text("No data to show chart"))
                  : chartType == "Pie Chart"
                      ? PieChart(PieChartData(
                          sections: expenses
                              .map((e) => PieChartSectionData(
                                    title: e.category,
                                    value: e.amount,
                                    color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                  ))
                              .toList(),
                        ))
                      : chartType == "Bar Chart"
                          ? BarChart(BarChartData(
                              barGroups: expenses
                                  .asMap()
                                  .entries
                                  .map((e) => BarChartGroupData(
                                        x: e.key,
                                        barRods: [
                                          BarChartRodData(toY: e.value.amount, color: Colors.green)
                                        ],
                                      ))
                                  .toList(),
                            ))
                          : LineChart(LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: expenses
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                                      .toList(),
                                  isCurved: true,
                                  color: Colors.green,
                                )
                              ],
                            )),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------- BUDGET PLANNER SCREEN -------------------
class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});
  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}
class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final _controller = TextEditingController(text: monthlyBudget.toString());
  @override
  Widget build(BuildContext context) {
    double totalSpent = expenses.fold(0, (sum, e) => sum + e.amount);
    double progress = totalSpent / monthlyBudget;
    return Scaffold(
      appBar: AppBar(title: const Text("Budget Planner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Monthly Budget (₹)", style: TextStyle(fontSize: 18)),
            TextField(controller: _controller, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  monthlyBudget = double.tryParse(_controller.text) ?? monthlyBudget;
                });
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Budget Updated!")));
              },
              child: const Text("Save Budget"),
            ),
            const SizedBox(height: 20),
            const Text("Progress", style: TextStyle(fontSize: 18)),
            LinearProgressIndicator(value: progress, minHeight: 20),
            const SizedBox(height: 10),
            Text("₹${totalSpent.toStringAsFixed(2)} spent of ₹${monthlyBudget.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}

/// ------------------- CALENDAR VIEW SCREEN -------------------
class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});
  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}
class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Expense> getExpensesForDay(DateTime day) {
    return expenses.where((e) =>
        e.date.year == day.year && e.date.month == day.month && e.date.day == day.day).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar View")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                double total = getExpensesForDay(day).fold(0, (sum, e) => sum + e.amount);
                Color textColor = total > dailyLimit ? Colors.red : Colors.green;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${day.day}", style: TextStyle(color: textColor)),
                    Text("₹${total.toInt()}", style: TextStyle(fontSize: 10, color: textColor)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("Select a day to view expenses"))
                : ListView(
                    children: getExpensesForDay(_selectedDay!).map((e) {
                      return Card(
                        child: ListTile(
                          title: Text(e.title),
                          subtitle: Text(e.category),
                          trailing: Text("₹${e.amount}"),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// ------------------- SETTINGS SCREEN -------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Dark Theme'),
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------- ABOUT SCREEN -------------------
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PocketLog ~ Track Expenses Like A Pro!\nPocketLog is a comprehensive expense tracker app designed to help you manage your finances effectively by monitoring daily and monthly expenditures.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Features include:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "- Easy expense tracking with categorization (Food, Transport, Entertainment, Other)\n"
              "- Visual reports with pie, bar, and line charts\n"
              "- Monthly budget planning with progress indicator\n"
              "- Calendar view to check daily expenses\n"
              "- User authentication for personal expense management\n"
              "- Persistent dark and light theme toggle for user comfort",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),  // Added extra spacing before developers section
            const Text(
              "Get in touch with the developers:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                developerInfo(
                  imagePath: 'assets/harsh(appdev).jpg',
                  name: 'Harshvardhan SJ',
                  email: 'harshvardhanjaisingh@gmail.com',
                ),
                developerInfo(
                  imagePath: 'assets/prajwal(appdev).jpg',
                  name: 'Prajwal Vanagondi',
                  email: 'vprajwal2006@gmail.com',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget developerInfo({
    required String imagePath,
    required String name,
    required String email,
  }) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}