import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expensed_web_app/models/expense.dart';
import 'package:expensed_web_app/models/person.dart';

class SpendingByPerson extends StatefulWidget {
  final List<Expense> filteredExpenses;

  const SpendingByPerson({super.key, required this.filteredExpenses});

  @override
  _SpendingByPersonState createState() => _SpendingByPersonState();
}

class _SpendingByPersonState extends State<SpendingByPerson> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    // Calculate total amount paid by each person
    Map<Person, double> amountByPerson = {};
    for (var expense in widget.filteredExpenses) {
      Person person = expense.paidBy;
      double amount = expense.amount;
      amountByPerson[person] = (amountByPerson[person] ?? 0) + amount;
    }

    // Calculate total amount
    double totalAmount = amountByPerson.values.fold(0, (a, b) => a + b);

    // Prepare data for the pie chart
    List<PieChartSectionData> sections = amountByPerson.entries.map((entry) {
      Person person = entry.key;
      double amount = entry.value;
      double percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0;
      Color color = person.color;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: touchedIndex == amountByPerson.keys.toList().indexOf(person)
            ? '${person.name}\n\$${amount.toStringAsFixed(2)}'
            : '${percentage.toStringAsFixed(1)}%',
        radius: touchedIndex == amountByPerson.keys.toList().indexOf(person)
            ? 60
            : 50,
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
          Text('Spending by Person',
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: totalAmount > 0
                ? PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  )
                : Center(
                    child: Text('No data available',
                        style: Theme.of(context).textTheme.bodyMedium)),
          ),
        ],
      ),
    );
  }
}
