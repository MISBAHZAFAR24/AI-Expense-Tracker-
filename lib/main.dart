import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_expense_screen.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'add_income_screen.dart';
import 'income_provider.dart';
import 'reports_screen.dart';
import 'expense_provider.dart';
import 'dashboard_provider.dart';
import 'report_provider.dart';
import 'login_screen.dart';
import 'splash_screen.dart';
import 'profile_screen.dart';
import 'ai_advisor_screen.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => IncomeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyDashboardPage extends StatefulWidget {
  const MyDashboardPage({super.key});

  @override
  State<MyDashboardPage> createState() => _MyDashboardPageState();
}

class _MyDashboardPageState extends State<MyDashboardPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardView(),
      ExpenseScreen(onBack: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
      IncomeScreen(onBack: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
      ReportsScreen(onBack: () {
        setState(() {
          _selectedIndex = 0;
        });
      }),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Expenses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Income",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// Separate Widget for the Dashboard content
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool showHistory = false;

  @override
  void initState() {
    super.initState();
    // Load data from API on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
      context.read<IncomeProvider>().fetchIncomes();
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final data = dashboardProvider.dashboardData;
    final isLoading = dashboardProvider.isLoading;

    final totalBalance = (data?['balance'] ?? 0).toDouble();
    final totalIncome = (data?['totalIncome'] ?? 0).toDouble();
    final totalExpense = (data?['totalExpense'] ?? 0).toDouble();
    final recentTransactions = data?['recentTransactions'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFF10B981),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet,color:Colors.white),
            const SizedBox(width: 8),
            Text(
              "AI Expense Tracker",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DashboardProvider>().fetchDashboardData();
          await context.read<ExpenseProvider>().fetchExpenses();
          await context.read<IncomeProvider>().fetchIncomes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Balance",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₹${totalBalance.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const IncomeScreen()),
                            ),
                            child: _buildStat("Income",
                                " ₹${totalIncome.toStringAsFixed(2)}",
                                Colors.green),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ExpenseScreen()),
                            ),
                            child: _buildStat(
                                "Expense",
                                "₹${totalExpense.toStringAsFixed(2)}",
                                Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (recentTransactions.isNotEmpty)
                      InkWell(
                        onTap: () {
                          setState(() {
                            showHistory = !showHistory;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                showHistory ? "See Less" : "See All",
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                showHistory ? Icons.expand_less : Icons.expand_more,
                                color: const Color(0xFF10B981),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 8),
                recentTransactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text("No transactions yet"),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: showHistory ? recentTransactions.length : 0,
                        itemBuilder: (context, index) {
                          final tx = recentTransactions[index];
                          final isExpense = tx['type'] == 'expense';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (isExpense ? Colors.red : Colors.green)
                                    .withOpacity(0.1),
                                child: Icon(
                                  isExpense ? Icons.trending_down : Icons.trending_up,
                                  color: isExpense ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Text(
                                tx['title'] ?? "No Title",
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(tx['category'] ?? "General"),
                              trailing: Text(
                                "${isExpense ? '-' : '+'}₹${(tx['amount'] ?? 0).toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: isExpense ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 24),
                // Actions Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    _buildActionCard(
                      context,
                      Icons.add_circle,
                      "Add Expense",
                      const Color(0xFF10B981),
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddExpenseScreen()),
                        );
                        if (mounted) {
                          context.read<DashboardProvider>().fetchDashboardData();
                          context.read<ExpenseProvider>().fetchExpenses();
                        }
                      },
                    ),
                    _buildActionCard(
                      context,
                      Icons.account_balance_wallet,
                      "Add Income",
                      const Color(0xFF10B981),
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddIncomeScreen()),
                        );
                        if (mounted) {
                          context.read<DashboardProvider>().fetchDashboardData();
                          context.read<IncomeProvider>().fetchIncomes();
                        }
                      },
                    ),
                    _buildActionCard(
                      context,
                      Icons.bar_chart,
                      "Reports",
                      const Color(0xFF10B981),
                      () {
                        // Navigate to Reports tab
                        if (context.findAncestorStateOfType<_MyDashboardPageState>() != null) {
                          context.findAncestorStateOfType<_MyDashboardPageState>()!.setState(() {
                            context.findAncestorStateOfType<_MyDashboardPageState>()!._selectedIndex = 3;
                          });
                        } else {
                          // Fallback if not inside MyDashboardPage (though it should be)
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                        }
                      },
                    ),
                    _buildActionCard(
                      context,
                      Icons.smart_toy,
                      "AI Advisor",
                      const Color(0xFF10B981),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AiAdvisorScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 5,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}
