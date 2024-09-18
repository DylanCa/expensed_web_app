import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/components/transaction_list.dart';
import 'package:expensed_web_app/components/spending_by_person.dart';
import 'package:expensed_web_app/components/expense_last_week.dart';

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
      'dateTime': DateTime.now().subtract(Duration(days: 13, hours: 3)),
      'shopName': "Supermarket",
      'category': 'Groceries',
      'amount': 72.30,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 12, hours: 7)),
      'shopName': "Gas Station",
      'category': 'Transportation',
      'amount': 45.00,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 11, hours: 5)),
      'shopName': "Cinema",
      'category': 'Entertainment',
      'amount': 30.50,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 10, hours: 2)),
      'shopName': "Pharmacy",
      'category': 'Health',
      'amount': 25.80,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 9, hours: 6)),
      'shopName': "Bookstore",
      'category': 'Education',
      'amount': 40.20,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 8, hours: 4)),
      'shopName': "Restaurant",
      'category': 'Food',
      'amount': 55.00,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 7, hours: 8)),
      'shopName': "Clothing Store",
      'category': 'Shopping',
      'amount': 120.00,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 0, hours: 1)),
      'shopName': "Coffee Shop",
      'category': 'Food',
      'amount': 5.50,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 13, hours: 14)),
      'shopName': "Electronics Store",
      'category': 'Shopping',
      'amount': 299.99,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 12, hours: 10)),
      'shopName': "Gym",
      'category': 'Health',
      'amount': 50.00,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 11, hours: 18)),
      'shopName': "Online Course",
      'category': 'Education',
      'amount': 79.99,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 10, hours: 9)),
      'shopName': "Grocery Store",
      'category': 'Groceries',
      'amount': 65.75,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 9, hours: 20)),
      'shopName': "Movie Theater",
      'category': 'Entertainment',
      'amount': 25.00,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 8, hours: 12)),
      'shopName': "Gas Station",
      'category': 'Transportation',
      'amount': 40.00,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 7, hours: 15)),
      'shopName': "Restaurant",
      'category': 'Food',
      'amount': 85.50,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 6, hours: 11)),
      'shopName': "Pharmacy",
      'category': 'Health',
      'amount': 32.40,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 5, hours: 17)),
      'shopName': "Clothing Store",
      'category': 'Shopping',
      'amount': 129.99,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 4, hours: 13)),
      'shopName': "Bookstore",
      'category': 'Education',
      'amount': 45.50,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 3, hours: 19)),
      'shopName': "Supermarket",
      'category': 'Groceries',
      'amount': 78.25,
      'paidBy': 'Alice'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 2, hours: 10)),
      'shopName': "Coffee Shop",
      'category': 'Food',
      'amount': 12.75,
      'paidBy': 'Bob'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(days: 1, hours: 16)),
      'shopName': "Public Transport",
      'category': 'Transportation',
      'amount': 15.00,
      'paidBy': 'John'
    },
    {
      'dateTime': DateTime.now().subtract(Duration(hours: 5)),
      'shopName': "Fast Food",
      'category': 'Food',
      'amount': 22.50,
      'paidBy': 'Alice'
    },
  ];
  Set<String> selectedCategories = Set<String>();
  Set<String> selectedPersons = Set<String>();
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = '';

  List<Map<String, dynamic>> getFilteredExpenses() {
    return testData.where((expense) {
      bool dateInRange = true;
      DateTime expenseDate = DateTime(
        expense['dateTime'].year,
        expense['dateTime'].month,
        expense['dateTime'].day,
      );

      if (startDate != null && endDate != null) {
        dateInRange = expenseDate.isAtSameMomentAs(startDate!) ||
            expenseDate.isAtSameMomentAs(endDate!) ||
            (expenseDate.isAfter(startDate!) && expenseDate.isBefore(endDate!));
      } else if (startDate != null) {
        dateInRange = expenseDate.isAtSameMomentAs(startDate!) ||
            expenseDate.isAfter(startDate!);
      } else if (endDate != null) {
        dateInRange = expenseDate.isAtSameMomentAs(endDate!) ||
            expenseDate.isBefore(endDate!);
      }

      bool matchesSearch = searchQuery.isEmpty ||
          expense['shopName']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          expense['category']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          expense['paidBy']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      return dateInRange &&
          matchesSearch &&
          (selectedCategories.isEmpty ||
              selectedCategories.contains(expense['category'])) &&
          (selectedPersons.isEmpty ||
              selectedPersons.contains(expense['paidBy']));
    }).toList();
  }

  void showFilterBottomSheet(BuildContext context) {
    Set<String> categories =
        testData.map((e) => e['category'] as String).toSet();
    Set<String> persons = testData.map((e) => e['paidBy'] as String).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            startDate = null;
                            endDate = null;
                            selectedCategories.clear();
                            selectedPersons.clear();
                          });
                          setState(() {});
                        },
                        child: Text('Clear All Filters'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Filter by Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (startDate != null)
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setModalState(() {
                                        startDate = null;
                                      });
                                      setState(() {});
                                    },
                                  ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: startDate != null
                                ? DateFormat('MM/dd/yyyy').format(startDate!)
                                : '',
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setModalState(() {
                                startDate = DateTime(pickedDate.year,
                                    pickedDate.month, pickedDate.day);
                              });
                              setState(() {});
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (endDate != null)
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setModalState(() {
                                        endDate = null;
                                      });
                                      setState(() {});
                                    },
                                  ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: endDate != null
                                ? DateFormat('MM/dd/yyyy').format(endDate!)
                                : '',
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setModalState(() {
                                endDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    23,
                                    59,
                                    59);
                              });
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Filter by Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((String category) {
                      return FilterChip(
                        label: Text(category),
                        selected: selectedCategories.contains(category),
                        onSelected: (bool selected) {
                          setModalState(() {
                            if (selected) {
                              selectedCategories.add(category);
                            } else {
                              selectedCategories.remove(category);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Filter by Person',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: persons.map((String person) {
                      return FilterChip(
                        label: Text(person),
                        selected: selectedPersons.contains(person),
                        onSelected: (bool selected) {
                          setModalState(() {
                            if (selected) {
                              selectedPersons.add(person);
                            } else {
                              selectedPersons.remove(person);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void onSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group expenses by date
    Map<String, List<Map<String, dynamic>>> groupedExpenses = {};
    for (var expense in getFilteredExpenses()) {
      String date = DateFormat('yyyy-MM-dd').format(expense['dateTime']);
      if (!groupedExpenses.containsKey(date)) {
        groupedExpenses[date] = [];
      }
      groupedExpenses[date]!.add(expense);
    }

    // Sort dates in descending order
    List<String> sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final rightColumnWidth = 400.0;
          final minLeftColumnWidth = 600.0;

          if (totalWidth >= minLeftColumnWidth + rightColumnWidth) {
            // Wide layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    child: TransactionList(
                      groupedExpenses: groupedExpenses,
                      sortedDates: sortedDates,
                      isNarrowLayout: false,
                      selectedCategories: selectedCategories,
                      selectedPersons: selectedPersons,
                      showFilterBottomSheet: showFilterBottomSheet,
                      startDate: startDate,
                      endDate: endDate,
                      onSearch: onSearch,
                      searchQuery: searchQuery,
                    ),
                  ),
                ),
                Container(
                  width: rightColumnWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 450,
                          child: SpendingByPerson(
                            filteredExpenses: getFilteredExpenses(),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        SizedBox(
                          height: 450,
                          child: ExpenseLastWeek(
                            filteredExpenses: getFilteredExpenses(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Narrow layout
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(minWidth: 400),
                            width: 450,
                            height: 450,
                            child: SpendingByPerson(
                              filteredExpenses: getFilteredExpenses(),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 450,
                            color: Colors.grey[300],
                          ),
                          Container(
                            constraints: BoxConstraints(minWidth: 400),
                            width: 450,
                            height: 450,
                            child: ExpenseLastWeek(
                              filteredExpenses: getFilteredExpenses(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    child: TransactionList(
                      groupedExpenses: groupedExpenses,
                      sortedDates: sortedDates,
                      isNarrowLayout: true,
                      selectedCategories: selectedCategories,
                      selectedPersons: selectedPersons,
                      showFilterBottomSheet: showFilterBottomSheet,
                      startDate: startDate,
                      endDate: endDate,
                      onSearch: onSearch,
                      searchQuery: searchQuery,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
