import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Expense extends StatelessWidget {
  final Color backgroundColor;
  final DateTime dateTime;
  final String shopName;
  final String category;
  final double amount;
  final String paidBy;

  const Expense({
    Key? key,
    required this.backgroundColor,
    required this.dateTime,
    required this.shopName,
    required this.category,
    required this.amount,
    required this.paidBy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Shop logo
            SizedBox(
              width: 48,
              height: 48,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.fastfood, color: Colors.orange),
              ),
            ),
            SizedBox(width: 16),
            // Shop name, date, and location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shopName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    DateFormat('h:mm a').format(dateTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Paid by $paidBy",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            // Category
            Container(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_dining, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Price
            Container(
              width: 80,
              child: Text(
                "-\$${amount.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
