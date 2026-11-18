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
  String _selectedType = "monthly";
  int _touchedPieIndex = -1;

  final List<Color> _chartColors = const [
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReportData(_selectedType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportProvider = context.watch<ReportProvider>();
    final data = reportProvider.reportData;
    final isLoading = reportProvider.isLoading;

    final summary = data?['summary'];
    final categoryAnalysis = data?['categoryAnalysis'] as List? ?? [];

    final income = (summary?['totalIncome'] ?? 0).toDouble();
    final expense = (summary?['totalExpense'] ?? 0).toDouble();
    final hasData = summary != null && (income > 0 || expense > 0);

    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
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
          "Financial Analytics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedType,
                dropdownColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF047857),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                items: ["daily", "weekly", "monthly", "yearly"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() => _selectedType = newValue);
                    reportProvider.fetchReportData(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : !hasData
              ? _buildEmptyState(textColor)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(income, expense, cardBg, isDark),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Expense Breakdown", Icons.donut_small, textColor),
                      const SizedBox(height: 12),
                      _buildPieChartCard(categoryAnalysis, expense, cardBg, textColor, isDark),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Income vs Expense Comparison", Icons.bar_chart, textColor),
                      const SizedBox(height: 12),
                      _buildBarChartCard(income, expense, cardBg, isDark),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Category Details", Icons.list_alt, textColor),
                      const SizedBox(height: 12),
                      ...categoryAnalysis.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cat = entry.value;
                        final catName = cat['_id'] ?? "General";
                        final catAmount = (cat['amount'] ?? 0).toDouble();
                        final color = _chartColors[index % _chartColors.length];
                        final percent = expense > 0 ? (catAmount / expense * 100) : 0.0;
                        return _buildCategoryCard(catName, catAmount, percent, color, cardBg, textColor);
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_outlined, size: 70, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 16),
          Text(
            "No Transactions Found",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add some income or expense records to view charts.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense, Color cardBg, bool isDark) {
    final balance = income - expense;
    return Row(
      children: [
        Expanded(child: _buildMetricCard("Income", income, const Color(0xFF10B981), Icons.arrow_downward_rounded, cardBg, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildMetricCard("Expense", expense, const Color(0xFFEF4444), Icons.arrow_upward_rounded, cardBg, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildMetricCard("Balance", balance, balance >= 0 ? const Color(0xFF3B82F6) : Colors.orange, Icons.account_balance_wallet_rounded, cardBg, isDark)),
      ],
    );
  }

  Widget _buildMetricCard(String title, double amount, Color color, IconData icon, Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              "₹${amount.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(List breakdown, double totalExpense, Color cardBg, Color textColor, bool isDark) {
    if (breakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text("No category data available", style: TextStyle(color: textColor))),
      );
    }

    final sections = breakdown.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedPieIndex;
      final amount = (data['amount'] ?? 0).toDouble();
      final percentage = totalExpense > 0 ? (amount / totalExpense * 100) : 0.0;
      final radius = isTouched ? 65.0 : 55.0;

      return PieChartSectionData(
        value: amount,
        color: _chartColors[index % _chartColors.length],
        radius: radius,
        showTitle: true,
        title: percentage >= 5 ? "${percentage.toStringAsFixed(0)}%" : "",
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    sections: sections,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Total Spent", style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        "₹${totalExpense.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: breakdown.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final catName = data['_id'] ?? "Other";
              final color = _chartColors[index % _chartColors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(catName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.grey.shade300 : const Color(0xFF475569))),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(double income, double expense, Color cardBg, bool isDark) {
    final maxVal = (income > expense ? income : expense);
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.25;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text("Income", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 13)),
                          );
                        } else if (value == 1) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text("Expense", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444), fontSize: 13)),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF34D399), Color(0xFF059669)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 38,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: expense,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF87171), Color(0xFFDC2626)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 38,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFF059669), size: 10),
                  const SizedBox(width: 4),
                  Text("Income: ₹${income.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFFDC2626), size: 10),
                  const SizedBox(width: 4),
                  Text("Expense: ₹${expense.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, double amount, double percentage, Color color, Color cardBg, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: Colors.white10) : null,
        boxShadow: Theme.of(context).brightness == Brightness.dark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 38,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                const SizedBox(height: 2),
                const Text("Percentage of expense", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${amount.toStringAsFixed(2)}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
              ),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
