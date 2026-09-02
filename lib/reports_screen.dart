import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'report_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ReportsScreen({super.key, this.onBack});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedType = "monthly"; // Backend: daily, weekly, monthly, yearly

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReportData(_selectedType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final data = reportProvider.reportData;
    final isLoading = reportProvider.isLoading;

    // Backend Response Structure: { summary: {...}, categoryAnalysis: [...] }
    final summary = data?['summary'];
    final categoryAnalysis = data?['categoryAnalysis'] as List? ?? [];
    
    final hasData = summary != null && 
                   ((summary['totalIncome'] ?? 0) > 0 || (summary['totalExpense'] ?? 0) > 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: const Text(
          "Financial Reports",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedType,
            dropdownColor: const Color(0xFF10B981),
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            items: ["daily", "weekly", "monthly", "yearly"].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase(), style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => _selectedType = newValue);
                reportProvider.fetchReportData(newValue);
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : !hasData
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(
                        (summary['totalIncome'] ?? 0).toDouble(),
                        (summary['totalExpense'] ?? 0).toDouble(),
                      ),
                      const SizedBox(height: 24),
                      const Text("Expense Distribution",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildPieChart(categoryAnalysis),
                      const SizedBox(height: 24),
                      const Text("Income vs Expense",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildBarChart(
                        (summary['totalIncome'] ?? 0).toDouble(),
                        (summary['totalExpense'] ?? 0).toDouble(),
                      ),
                      const SizedBox(height: 24),
                      const Text("Category Breakdown",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...categoryAnalysis.map((cat) => 
                        _buildCategoryTile(cat['_id'] ?? "Unknown", (cat['amount'] ?? 0).toDouble())),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("No data available for this period",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    return Column(
      children: [
        _buildSummaryCard("Total Income", income, Colors.green, Icons.arrow_downward),
        const SizedBox(height: 8),
        _buildSummaryCard("Total Expense", expense, Colors.red, Icons.arrow_upward),
        const SizedBox(height: 8),
        _buildSummaryCard("Net Balance", income - expense, Colors.blue, Icons.account_balance_wallet),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text("₹${amount.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ),
    );
  }

  Widget _buildPieChart(List breakdown) {
    if (breakdown.isEmpty) return const SizedBox(height: 100, child: Center(child: Text("No expense data")));

    final sections = breakdown.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return PieChartSectionData(
        value: (data['amount'] ?? 0).toDouble(),
        title: data['_id'] ?? "",
        radius: 60,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        color: Colors.primaries[index % Colors.primaries.length],
      );
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 40)),
    );
  }

  Widget _buildBarChart(double income, double expense) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: income, color: Colors.green, width: 40, borderRadius: BorderRadius.circular(5))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: expense, color: Colors.red, width: 40, borderRadius: BorderRadius.circular(5))]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String category, double amount) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ListTile(
        title: Text(category),
        trailing: Text("₹${amount.toStringAsFixed(2)}", 
          style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
