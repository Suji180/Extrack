import 'Salarycalc/salarydata.dart';
import 'package:flutter/material.dart';
import 'package:extrack/server_logic.dart/server.dart';
import 'package:extrack/home.dart';
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

  final Salarydata salaryData = Salarydata();

  final List<String> salaryTypes = ['Monthly', 'Yearly', 'Weekly', 'Daily'];

  @override
  void initState() {
    super.initState();

    if (salaryData.salaryType == null) {
      salaryData.salaryType = salaryTypes[0];
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
                  value: salaryData.salaryType,
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
                      salaryData.salaryType = value;
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
            setState(() {
              Salarydata().Amount = salaryAmount.text == ''
                  ? 0
                  : double.tryParse(salaryAmount.text) ?? 0;
              Salarydata().date = salaryDate.text;

              print("the data is ${salaryData.salaryType}");
              salaryData.Amount = double.tryParse(salaryAmount.text) ?? 0;

              salaryData.date = salaryDate.text;

              print("Salary Data from Salary Pages");

              print(salaryData.salaryType);

              print(salaryData.Amount);

              print(salaryData.date);

              print(context);

              print("Data sent back to home pages");

              addincome(
                salaryData.salaryType ?? '',

                (salaryData.Amount ?? 0).toInt(),

                salaryData.date ?? '',
              );
              localcached();
              

              Navigator.pop(context, {
                'type': Salarydata().salaryType ?? '',
                'amount': salaryAmount.text == ''
                    ? 0
                    : double.tryParse(salaryAmount.text) ?? 0,
                'data': Salarydata().date ?? '',
              });
            });

            // print("the output is",Salarydata().Amount);
            // print(Salarydata().date);

            // addincome(
            //   Salarydata().salaryType ?? '',
            //   (Salarydata().Amount ?? 0).toInt(),
            //   Salarydata().date ?? '',
            // );
            //  addincome(salaryType.text,salaryAmount.text as int,salaryDate.text);
          },
          child: const Icon(Icons.save_alt_outlined),
        ),
      ),
    );
  }
}
