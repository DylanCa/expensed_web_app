import 'package:flutter/material.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/providers/goal_provider.dart';
import 'package:provider/provider.dart';

class AddGoalPanel extends StatefulWidget {
  final VoidCallback onClose;

  const AddGoalPanel({Key? key, required this.onClose}) : super(key: key);

  @override
  _AddGoalPanelState createState() => _AddGoalPanelState();
}

class _AddGoalPanelState extends State<AddGoalPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryNameController;
  late TextEditingController _monthlyBudgetController;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  @override
  void initState() {
    super.initState();
    _categoryNameController = TextEditingController();
    _monthlyBudgetController = TextEditingController();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _monthlyBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(labelText: 'Category Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a category name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _monthlyBudgetController,
                    decoration: InputDecoration(labelText: 'Monthly Budget'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a monthly budget';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Add color picker and icon picker here
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                child: Text('Add Goal'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _categoryNameController.text,
        color: _selectedColor,
        icon: _selectedIcon,
      );

      // Add the new category
      goalProvider.addCategory(newCategory);

      // Set the goal for the new category
      goalProvider.setGoal(
        newCategory,
        double.parse(_monthlyBudgetController.text),
      );

      widget.onClose();
    }
  }
}
