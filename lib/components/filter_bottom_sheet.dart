import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expensed_web_app/providers/expense_provider.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';

void showFilterBottomSheet(
    BuildContext context, ExpenseProvider expenseProvider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        expenseProvider.clearFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Clear All Filters'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Filter by Date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('Current Week'),
                          selected: false,
                          onSelected: (bool selected) {
                            if (selected) {
                              final now = DateTime.now();
                              final startOfWeek =
                                  now.subtract(Duration(days: now.weekday - 1));
                              final endOfWeek =
                                  startOfWeek.add(Duration(days: 6));
                              setState(() {
                                expenseProvider.setDateRange(
                                    startOfWeek, endOfWeek);
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text('Current Month'),
                          selected: false,
                          onSelected: (bool selected) {
                            if (selected) {
                              final now = DateTime.now();
                              final startOfMonth =
                                  DateTime(now.year, now.month, 1);
                              final endOfMonth =
                                  DateTime(now.year, now.month + 1, 0);
                              setState(() {
                                expenseProvider.setDateRange(
                                    startOfMonth, endOfMonth);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: expenseProvider.startDate != null
                              ? DateFormat('MM/dd/yyyy')
                                  .format(expenseProvider.startDate!)
                              : '',
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                expenseProvider.startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              expenseProvider.setDateRange(
                                  pickedDate, expenseProvider.endDate);
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: expenseProvider.endDate != null
                              ? DateFormat('MM/dd/yyyy')
                                  .format(expenseProvider.endDate!)
                              : '',
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                expenseProvider.endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              expenseProvider.setDateRange(
                                  expenseProvider.startDate, pickedDate);
                            });
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
                  children: expenseProvider.categories.map((Category category) {
                    return FilterChip(
                      label: Text(category.name),
                      selected:
                          expenseProvider.selectedCategories.contains(category),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            expenseProvider.selectedCategories.add(category);
                          } else {
                            expenseProvider.selectedCategories.remove(category);
                          }
                          expenseProvider.setSelectedCategories(
                              expenseProvider.selectedCategories);
                        });
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
                  children: expenseProvider.persons.map((Person person) {
                    return FilterChip(
                      label: Text(person.name),
                      selected:
                          expenseProvider.selectedPersons.contains(person),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            expenseProvider.selectedPersons.add(person);
                          } else {
                            expenseProvider.selectedPersons.remove(person);
                          }
                          expenseProvider.setSelectedPersons(
                              expenseProvider.selectedPersons);
                        });
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
