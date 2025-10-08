import 'Salarycalc/salarydata.dart';
import 'package:flutter/material.dart';

class Salary extends StatefulWidget 
{

const Salary({super.key});

  @override
  State<Salary> createState() => _SalaryState();
}

class _SalaryState extends State<Salary> {


final TextEditingController salaryType = TextEditingController();
final TextEditingController salaryAmount = TextEditingController();
final TextEditingController salaryDate = TextEditingController();
@override
Widget build(BuildContext context) 
{
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: BackButton(),
        onPressed: () {
          Navigator.pop(context);
        },),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height*0.4,
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              
            
               
                  DropdownButtonFormField<String> ( 
                               
                   decoration: InputDecoration(
                    
                      border: OutlineInputBorder(),
                      label: const Text('Salary Type',),
                      hintText: 'Select Type'
                   ),
                  
                   value:Salarydata().salaryType,
                   items: ['Monthly','Yearly','Weekly','Daily'].map((saltype)
                  
                    =>  DropdownMenuItem(
                      value: saltype,
                      child: Text(saltype),
                    )
                   
                   ).toList(),
                  
                   onChanged :(value)
                   {
                    setState(() {
                                     
                      Salarydata().salaryType=value;
                    });
                   }
                  
                                   
                   
                   
                                   ),
               

              
              
               TextField(
                controller: salaryAmount,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: const Text('Salary Amount'),
                  hintText: 'Enter Amount'
                ),
              ),
               TextField(
                controller: salaryDate,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: const Text('Choose Date'),
                  hintText: 'DD/MM/YYYY'
                ),
              ),
            ],
          ),
        ),
      ))
  );
    
  
}
}
