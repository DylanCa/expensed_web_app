import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:expensed_web_app/models/category.dart';
import 'package:expensed_web_app/models/person.dart';

class Expense {
  final String id;
  final DateTime dateTime;
  final String shopName;
  final Category category;
  final double amount;
  final Person paidBy;
  final String? notes;
  final List<String> tags;
  final bool isRecurring;
  final RecurrenceInterval? recurrenceInterval;

  Expense({
    String? id,
    required this.dateTime,
    required this.shopName,
    required this.category,
    required this.amount,
    required this.paidBy,
    this.notes,
    List<String>? tags,
    this.isRecurring = false,
    this.recurrenceInterval,
  })  : id = id ?? Uuid().v4(),
        tags = tags ?? [];

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      shopName: map['shopName'],
      category: Category.fromMap(map['category']),
      amount: map['amount'].toDouble(),
      paidBy: Person.fromMap(map['paidBy']),
      notes: map['notes'],
      tags: List<String>.from(map['tags'] ?? []),
      isRecurring: map['isRecurring'] ?? false,
      recurrenceInterval: map['recurrenceInterval'] != null
          ? RecurrenceInterval.fromMap(map['recurrenceInterval'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'shopName': shopName,
      'category': category.toMap(),
      'amount': amount,
      'paidBy': paidBy.toMap(),
      'notes': notes,
      'tags': tags,
      'isRecurring': isRecurring,
      'recurrenceInterval': recurrenceInterval?.toMap(),
    };
  }

  String get formattedDate => DateFormat('MMMM d, yyyy').format(dateTime);
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  Expense copyWith({
    DateTime? dateTime,
    String? shopName,
    Category? category,
    double? amount,
    Person? paidBy,
    String? notes,
    List<String>? tags,
    bool? isRecurring,
    RecurrenceInterval? recurrenceInterval,
  }) {
    return Expense(
      id: this.id,
      dateTime: dateTime ?? this.dateTime,
      shopName: shopName ?? this.shopName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RecurrenceInterval {
  final int frequency;
  final RecurrenceType type;

  RecurrenceInterval({
    required this.frequency,
    required this.type,
  });

  factory RecurrenceInterval.fromMap(Map<String, dynamic> map) {
    return RecurrenceInterval(
      frequency: map['frequency'],
      type: RecurrenceType.values[map['type']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency,
      'type': type.index,
    };
  }
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}
