import 'Salarycalc/salarydata.dart';
import 'package:flutter/material.dart';
import 'package:extrack/server_logic.dart/server.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

class Salary extends StatefulWidget {
  const Salary({super.key});

  @override
  State<Salary> createState() => _SalaryState();
}
class _SalaryState extends State<Salary> {
  final TextEditingController salaryAmount = TextEditingController();
  final TextEditingController salaryDate = TextEditingController();

  // Single instance of Salarydata
  final Salarydata salaryData = Salarydata();

  // Default dropdown value
  final List<String> salaryTypes = ['Monthly', 'Yearly', 'Weekly', 'Daily'];

  @override
  void initState() {
    super.initState();
    // Set default value if null
    if (salaryData.salaryType == null) {
      salaryData.salaryType = salaryTypes[0]; // default to "Monthly"
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: const Text('Salary Type'),
                    hintText: 'Select Type',
                  ),
                  value: salaryData.salaryType, // current selected type
                  items: salaryTypes
                      .map(
                        (saltype) => DropdownMenuItem(
                          value: saltype,
                          child: Text(saltype),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      salaryData.salaryType = value; // update the selected type
                    });
                  },
                ),
                TextField(
                  controller: salaryAmount,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: const Text('Salary Amount'),
                    hintText: 'Enter Amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: salaryDate,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: const Text('Salary Date'),
                    hintText: 'DD/MM/YYYY',
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Update Salarydata instance
            salaryData.Amount = double.tryParse(salaryAmount.text) ?? 0;
            salaryData.date = salaryDate.text;

            // Print values
            print("Salary Data from Salary Pages");
            print(salaryData.salaryType); // now it will always have a value
            print(salaryData.Amount);
            print(salaryData.date);
            print(context);
            print("Data sent back to home pages");

            // Return data to previous screen
            Navigator.pop(context, {
              'type': salaryData.salaryType ?? '',
              'amount': salaryData.Amount,
              'date': salaryData.date ?? '',
            });

            // Call API
            addincome(
              salaryData.salaryType ?? '',
              (salaryData.Amount ?? 0).toInt(),
              salaryData.date ?? '',
            );
          },
          child: const Icon(Icons.save_alt_outlined),
        ),
      ),
    );
  }
}
