import 'Salarycalc/salarydata.dart';
import 'package:flutter/material.dart';
import 'package:extrack/server_logic.dart/server.dart';

class Salary extends StatefulWidget {
  const Salary({super.key});

  @override
  State<Salary> createState() => _SalaryState();
}

class _SalaryState extends State<Salary> {
  final TextEditingController salaryType = TextEditingController();
  final TextEditingController salaryAmount = TextEditingController();
  final TextEditingController salaryDate = TextEditingController();
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

                  value: Salarydata().salaryType,
                  items: ['Monthly', 'Yearly', 'Weekly', 'Daily']
                      .map(
                        (saltype) => DropdownMenuItem(
                          value: saltype,
                          child: Text(saltype),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    setState(() {
                      Salarydata().salaryType = value;
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

              Navigator.pop(context,{
                'type': Salarydata().salaryType ?? '',
                'amount': salaryAmount.text == '' ? 0 : double.tryParse(salaryAmount.text) ?? 0,
                'data': Salarydata().date ?? ''
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
