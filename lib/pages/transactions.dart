import 'package:expensed_web_app/components/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class Transactions extends StatefulWidget {
  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final List<Map<String, dynamic>> testData = [
    {
      'dateTime': DateTime.now().subtract(Duration(days: 0, hours: 2)),
      'shopName': "Grocery Store",
      'category': 'Groceries',
      'amount': 85.50,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 1, hours: 5)),
      'shopName': "Restaurant",
      'category': 'Food',
      'amount': 45.00,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 1, hours: 10)),
      'shopName': "Gas Station",
      'category': 'Transportation',
      'amount': 30.25,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 2, hours: 3)),
      'shopName': "Cinema",
      'category': 'Entertainment',
      'amount': 25.00,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 3, hours: 7)),
      'shopName': "Online Store",
      'category': 'Shopping',
      'amount': 120.99,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 4, hours: 1)),
      'shopName': "Pharmacy",
      'category': 'Health',
      'amount': 35.75,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 5, hours: 9)),
      'shopName': "Bookstore",
      'category': 'Education',
      'amount': 50.50,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 6, hours: 4)),
      'shopName': "Coffee Shop",
      'category': 'Food',
      'amount': 15.25,
      'paidBy': 'John'
    },
  ];
  Map<String, double> expensesByCategory = {};
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final Color color1 = Theme.of(context).colorScheme.surface;
    final Color color2 = Theme.of(context).colorScheme.surfaceVariant;

    // Group expenses by date
    Map<String, List<Map<String, dynamic>>> groupedExpenses = {};
    for (var expense in testData) {
      String date = DateFormat('yyyy-MM-dd').format(expense['dateTime']);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    // Sort dates in descending order
    List<String> sortedDates = groupedExpenses.keys.toList()..sort((a, b) => b.compareTo(a));

    // Calculate total expenses by category
    for (var expense in testData) {
      String category = expense['category'];
      double amount = expense['amount'];
      expensesByCategory[category] = (expensesByCategory[category] ?? 0) + amount;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: _buildTransactionList(groupedExpenses, sortedDates),
            ),
          ),
          Container(
            width: 400, // Fixed width for the right column
            child: SingleChildScrollView(
              child: _buildRightColumn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(Map<String, List<Map<String, dynamic>>> groupedExpenses, List<String> sortedDates) {
    int expenseIndex = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedFilter,
                items: ['All', 'Income', 'Expense'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String date = sortedDates[index];
              List<Map<String, dynamic>> expenses = groupedExpenses[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      DateFormat('MMMM d, yyyy').format(DateTime.parse(date)),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...expenses.map((expense) {
                    Color backgroundColor = expenseIndex % 2 == 0 ? Colors.white : Color(0xFFF7F9FC);
                    expenseIndex++;
                    return Expense(
                      backgroundColor: backgroundColor,
                      dateTime: expense['dateTime'],
                      shopName: expense['shopName'],
                      category: expense['category'],
                      amount: expense['amount'],
                      paidBy: expense['paidBy'],
                    );
                  }).toList(),
                  SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        Container(
          height: 400, // Fixed height for Spending by Person
          child: _buildSpendingLimits(),
        ),
        Container(
          height: 1,
          color: Colors.grey[300],
        ),
        Container(
          height: 450, // Increased height for Expense Last Week
          child: _buildExpenseLastWeek(),
        ),
      ],
    );
  }

  Widget _buildSpendingLimits() {
    // Calculate total amount paid by each person
    Map<String, double> amountByPerson = {};
    for (var expense in testData) {
      String paidBy = expense['paidBy'];
      double amount = expense['amount'];
      amountByPerson[paidBy] = (amountByPerson[paidBy] ?? 0) + amount;
    }

    // Calculate total amount
    double totalAmount = amountByPerson.values.reduce((a, b) => a + b);

    // Prepare data for the pie chart
    List<PieChartSectionData> sections = amountByPerson.entries.map((entry) {
      String person = entry.key;
      double amount = entry.value;
      double percentage = (amount / totalAmount) * 100;
      Color color = Colors.primaries[amountByPerson.keys.toList().indexOf(person) % Colors.primaries.length];

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by Person', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 0,
              ),
            ),
          ),
          SizedBox(height: 20),
          ...amountByPerson.entries.map((entry) {
            String person = entry.key;
            double amount = entry.value;
            Color color = Colors.primaries[amountByPerson.keys.toList().indexOf(person) % Colors.primaries.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: color,
                  ),
                  SizedBox(width: 8),
                  Text(person),
                  Spacer(),
                  Text('\$${amount.toStringAsFixed(2)}'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExpenseLastWeek() {
    // Get the last 7 days
    final now = DateTime.now();
    final lastSevenDays = List.generate(7, (index) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index)));

    // Group expenses by day and category
    Map<DateTime, Map<String, double>> expensesByDayAndCategory = {};
    Set<String> categories = {};

    for (var day in lastSevenDays) {
      expensesByDayAndCategory[day] = {};
    }

    double maxDailyTotal = 0;  // Track the maximum daily total

    for (var expense in testData) {
      DateTime date = DateTime(expense['dateTime'].year, expense['dateTime'].month, expense['dateTime'].day);
      String category = expense['category'];
      double amount = expense['amount'];

      if (lastSevenDays.contains(date)) {
        expensesByDayAndCategory[date]!.putIfAbsent(category, () => 0);
        expensesByDayAndCategory[date]![category] = (expensesByDayAndCategory[date]![category] ?? 0) + amount;
        categories.add(category);

        // Update maxDailyTotal if necessary
        double dailyTotal = expensesByDayAndCategory[date]!.values.reduce((a, b) => a + b);
        if (dailyTotal > maxDailyTotal) {
          maxDailyTotal = dailyTotal;
        }
      }
    }

    List<String> sortedCategories = categories.toList()..sort();

    // Calculate maxY (maximum amount rounded to the nearest 50 above)
    double maxY = maxDailyTotal == 0 ? 100 : (maxDailyTotal / 50).ceil() * 50.0;

    // Prepare data for the stacked bar chart
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < lastSevenDays.length; i++) {
      DateTime date = lastSevenDays[i];
      List<BarChartRodStackItem> stackItems = [];
      double totalHeight = 0;

      for (int j = 0; j < sortedCategories.length; j++) {
        String category = sortedCategories[j];
        double amount = expensesByDayAndCategory[date]![category] ?? 0;
        if (amount > 0) {
          stackItems.add(
            BarChartRodStackItem(
              totalHeight,
              totalHeight + amount,
              Colors.primaries[j % Colors.primaries.length],
            ),
          );
          totalHeight += amount;
        }
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalHeight,
              width: 32,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              rodStackItems: stackItems,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate total weekly amount for each category
    Map<String, double> weeklyTotalByCategory = {};
    for (var day in lastSevenDays) {
      for (var category in sortedCategories) {
        double amount = expensesByDayAndCategory[day]![category] ?? 0;
        weeklyTotalByCategory[category] = (weeklyTotalByCategory[category] ?? 0) + amount;
      }
    }

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Last Week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Container(
            height: 200, // Set the graph height to 200px
            child: barGroups.isEmpty
                ? Center(child: Text('No data available for the last 7 days'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toInt()}',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < lastSevenDays.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('E d').format(lastSevenDays[index]),
                                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                  ),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false), // Hide grid lines
                      borderData: FlBorderData(show: false), // Hide border
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            DateTime date = lastSevenDays[groupIndex];
                            Map<String, double> dayExpenses = expensesByDayAndCategory[date]!;
                            
                            double totalAmount = dayExpenses.values.fold(0, (sum, amount) => sum + amount);
                            
                            return BarTooltipItem(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.w500),
                            );
                          },
                        ),
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              return;
                            }
                          });
                        },
                      ),
                      groupsSpace: 12,
                    ),
                  ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sortedCategories.asMap().entries.map((entry) {
                  int index = entry.key;
                  String category = entry.value;
                  Color color = Colors.primaries[index % Colors.primaries.length];
                  double totalAmount = weeklyTotalByCategory[category] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$category (\$${totalAmount.toStringAsFixed(2)})',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
