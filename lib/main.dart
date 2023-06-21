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
  TransactionType selectedType = TransactionType.income;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    selectedCategory = categories[0];
    _calculateTotalIncome();
    _calculateTotalExpense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pencatat Keuangan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pemasukan: $totalIncome',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Total Pengeluaran: $totalExpense',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transactions[index].date.toString()),
                        Text(transactions[index].description),
                      ],
                    ),
                    trailing: Text(transactions[index].amount.toString()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddTransactionDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _calculateTotalIncome() {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        total += transaction.amount;
      }
    }
    setState(() {
      totalIncome = total;
    });
  }

  void _calculateTotalExpense() {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        total += transaction.amount;
      }
    }
    setState(() {
      totalExpense = total;
    });
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.insert(0, transaction);
    });

    _saveTransactions(transactions);
    _calculateTotalIncome(); // Tambahkan ini
    _calculateTotalExpense(); // Tambahkan ini

    Fluttertoast.showToast(
      msg: 'Transaksi berhasil ditambahkan!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });

    _saveTransactions(transactions);
    _calculateTotalIncome(); // Tambahkan ini
    _calculateTotalExpense(); // Tambahkan ini

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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Tambah Transaksi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Pemasukan'),
                    leading: Radio(
                      value: TransactionType.income,
                      groupValue: selectedType,
                      onChanged: (TransactionType? value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Pengeluaran'),
                    leading: Radio(
                      value: TransactionType.expense,
                      groupValue: selectedType,
                      onChanged: (TransactionType? value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Jumlah'),
                    onChanged: (value) {
                      try {
                        double.parse(value);
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: 'Mohon masukkan angka',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: 'Deskripsi'),
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
                      final transaction = Transaction(
                        type: selectedType,
                        category: selectedCategory,
                        amount: amount,
                        description: descriptionController.text,
                        date: DateTime.now(),
                      );
                      _addTransaction(transaction);

                      // Mengatur kembali nilai-nilai setelah menyimpan transaksi
                      setState(() {
                        selectedType = TransactionType.income;
                        selectedCategory = categories[0];
                        amountController.clear();
                        descriptionController.clear();
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: Text('Simpan'),
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
      _calculateTotalIncome(); // Tambahkan ini
      _calculateTotalExpense(); // Tambahkan ini
    }
  }
}

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
