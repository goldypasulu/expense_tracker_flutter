import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(PencatatKeuanganApp());
}

class PencatatKeuanganApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Keuangan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PencatatKeuanganPage(),
    );
  }
}

class PencatatKeuanganPage extends StatefulWidget {
  @override
  _PencatatKeuanganPageState createState() => _PencatatKeuanganPageState();
}

class _PencatatKeuanganPageState extends State<PencatatKeuanganPage> {
  List<Transaction> transactions = [];
  List<String> categories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Lainnya',
  ];
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    selectedCategory = categories[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pencatat Keuangan'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(transactions[index].date.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Konfirmasi'),
                    content: Text(
                        'Apakah Anda yakin ingin menghapus transaksi ini?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('Tidak'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Ya'),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              _deleteTransaction(index);
            },
            child: ListTile(
              leading: transactions[index].type == TransactionType.income
                  ? Icon(Icons.add, color: Colors.green)
                  : Icon(Icons.remove, color: Colors.red),
              title: Text(transactions[index].category),
              subtitle: Text(transactions[index].date.toString()),
              trailing: Text(transactions[index].amount.toString()),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddTransactionDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });

    _saveTransactions(transactions);

    Fluttertoast.showToast(
      msg: 'Transaksi berhasil dihapus!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _openAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController amountController = TextEditingController();

        String selectedCategory =
            categories[0]; // Inisialisasi dengan kategori pertama

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Tambah Transaksi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Jumlah'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      final amount = double.parse(amountController.text);

                      setState(() {
                        transactions.add(
                          Transaction(
                            type: TransactionType.expense,
                            category: selectedCategory,
                            amount: amount,
                            date: DateTime.now(),
                          ),
                        );
                      });

                      _saveTransactions(transactions);

                      Fluttertoast.showToast(
                        msg: 'Transaksi berhasil ditambahkan!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );

                      Navigator.pop(context);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Mohon isi semua field!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTransactions(List<Transaction> transactions) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedTransactions = transactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();
    await prefs.setStringList('transactions', encodedTransactions);
  }

  Future<void> _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedTransactions = prefs.getStringList('transactions');
    if (encodedTransactions != null) {
      List<Transaction> loadedTransactions = encodedTransactions
          .map((encoded) => Transaction.fromJson(jsonDecode(encoded)))
          .toList();
      setState(() {
        transactions = loadedTransactions;
      });
    }
  }
}

enum TransactionType { income, expense }

class Transaction {
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;

  Transaction({
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: json['category'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }
}
