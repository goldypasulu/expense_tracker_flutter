import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class Transaction {
  final TransactionType type;
  final String category;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toUtc(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: json['category'],
      amount: json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']).toLocal(),
    );
  }
}
