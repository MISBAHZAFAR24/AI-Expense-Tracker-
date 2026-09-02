import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'income_provider.dart';
import 'add_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const IncomeScreen({super.key, this.onBack});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  void initState() {
    super.initState();
    // लोड इनकम डेटा फ्रॉम API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeProvider>().fetchIncomes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final incomeProvider = context.watch<IncomeProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF10B981),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: const Text("Income History", style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold,)),
      ),
      body: incomeProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : incomeProvider.incomes.isEmpty
              ? const Center(child: Text("No income records found."))
              : ListView.builder(
                  itemCount: incomeProvider.incomes.length,
                  itemBuilder: (context, index) {
                    final income = incomeProvider.incomes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(Icons.add, color: Colors.green),
                        ),
                        title: Text(income.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${income.category} • ${income.date.day}/${income.date.month}/${income.date.year}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "+₹${income.amount.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              onPressed: () {
                                if (income.id != null) {
                                  incomeProvider.deleteIncome(income.id!);
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
