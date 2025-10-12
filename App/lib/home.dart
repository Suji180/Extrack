import 'package:extrack/salary.dart';
import 'package:flutter/material.dart' as images;
import 'package:flutter/src/widgets/container.dart';
import 'dart:io';
import 'package:extrack/data/expense_data.dart';
import 'package:extrack/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extrack/server_logic.dart/server.dart';
import 'package:image_picker/image_picker.dart';


class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
    final TextEditingController newexpenseNameController = TextEditingController();
    final TextEditingController newexpenseAmountController = TextEditingController();
    final TextEditingController newreceiptNameController = TextEditingController();
    bool isuiupdated = true;
    double? totalBalance;
    File ? selectedimage;
    void addExpense() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          
          content: SizedBox(
            width: MediaQuery.of(context).size.width*0.8,
            height: MediaQuery.of(context).size.height*0.5,

            child: Column(
              children: [
                TextField(
                  controller: newexpenseNameController,
                  decoration: const InputDecoration(
                    labelText: 'Expense Name',
                    hintText: 'Enter the expense name',
                
                  ),
                
                ),
            
                TextField(
                  controller: newexpenseAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter the expense amount',
                
                  ),
                
                ),

                TextField(
                  controller: newreceiptNameController,
                  decoration: const InputDecoration(
                    labelText: 'Receipt',
                    hintText: 'Type your receipt name',
                
                  ),
                  
                
                ),
               GestureDetector(
                onTap: () {
                  _pickImageFromGallery();
                },
                 child: Container(
                          margin: const EdgeInsets.only(left: 20,right: 20,top: 20),
                          
                          height:MediaQuery.of(context).size.height * 0.04,
                          width: MediaQuery.of(context).size.width * 1,
                          child: Center(
                            child: Text("Upload from Gallery"
                            ,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),),
                            
                          ),
                          
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 2, 64, 118)
                          
                          ),
                         
                        ),
               ),
                GestureDetector(
                  onTap: () {
                    _pickImageFromCamera();
                  },
                  child: Container(
                          margin: const EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                          
                          height:MediaQuery.of(context).size.height * 0.04,
                          width: MediaQuery.of(context).size.width * 1,
                          child: Center(child: Text("Upload from Camera",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 2, 64, 118)
                          
                          ),
                        ),
                ),
               


              ],
            ),
           
          ),
          
          actions: [
            MaterialButton(
              onPressed: add,
              child: const Text('Add'),              
            ),

               MaterialButton(
              onPressed: cancel,
              child: const Text('Cancel '),              
            )
            
          ],
          

        );
      },
    );
  }
  XFile? _pickedImage;

  Future _pickImageFromGallery() async {
    final returnedimage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(returnedimage != null){
      setState(() {
        _pickedImage = returnedimage;
     
    });
      
    }
    
  }

  Future _pickImageFromCamera() async {
    final returnedcam = await ImagePicker().pickImage(source: ImageSource.camera);
    if(returnedcam != null){
      setState(() {
        _pickedImage = returnedcam;
     
    });
      
    }
  }
  void add() 
  {
     ref.read(expenseDataProvider.notifier).addExpense(
      ExpenseItem(
        name: newexpenseNameController.text,
        amount: newexpenseAmountController.text,
        date: DateTime.now(),
        receiptname: newreceiptNameController.text,
      )
      
     );
     postexpenses(newexpenseNameController.text, int.tryParse(newexpenseAmountController.text) ?? 0, newreceiptNameController.text, _pickedImage!.path);

     clear();
     // close the dialog 
    
    Navigator.of(context).pop();
  }
  void cancel()
  {
    Navigator.of(context).pop();
    clear();
  }

  void clear()
  {
    newexpenseNameController.clear();
    newexpenseAmountController.clear();
    newexpenseAmountController.clear();
  }


  @override
  Widget build(BuildContext context,) {
    final product = ref.watch(expenseDataProvider);
    
    
    return 
       Consumer(
         builder: (BuildContext context, WidgetRef ref, Widget? child) 
         => Scaffold(
          body:CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                
                title: const Text('Good Morning !\nMadhu',
                textAlign: TextAlign.left,
                
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'poppins',
                  color: Color.fromRGBO(217, 217, 217, 1)
                  
                ),),
                actions: [
                  Container(
                    height: 45,
                    width: 45,
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle                    
                    ),
                    child: const IconButton(
                      icon: Icon(Icons.notifications_outlined),
                      onPressed: null,
                    ),
                  ),
                                    Container(
                    height: 45,
                    width: 45,
                    margin: const EdgeInsets.only(right:3),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle                    
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_2_outlined),
                      onPressed:() => Navigator.pushNamed(context , '/profile'),
                        
                      
                    ),
                  ),
              Container(
                margin: const EdgeInsets.all(20),
                color: Colors.white,
              )
                ],
                titleTextStyle: const TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                expandedHeight: MediaQuery.of(context).size.height * 0.45,
                backgroundColor: const Color.fromRGBO(52, 49, 199, 1),
                floating: false,
                pinned: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
               
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        
                        height:MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width * 1.7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                         image : const DecorationImage(
                          image: AssetImage('assets/images/homepage.png'),
                          fit: BoxFit.fitWidth
                        )
                        ),
                       
                      ),
                      
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: isuiupdated ? Container(
                            
                margin: const EdgeInsets.only(left: 15 , top: 20 , bottom:10, right: 10),
                padding: const EdgeInsets.only(left : 110 , top: 10 , bottom: 10),
                height: MediaQuery.of(context).size.height * 0.18,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                image: const 
                DecorationImage(image: images.AssetImage('assets/images/addincome.png'),
                fit: BoxFit.fitWidth,
                
                )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            
                            GestureDetector(
                                 onTap: () async {
                        try{
                        final result = await Navigator.push(context ,MaterialPageRoute(builder: (context) => const Salary()));
                          if(result != null)
                          {
                            setState(() {
                              
                             totalBalance = result['amount'] as double?;
                             isuiupdated = false;
                              
                            });
                          } } catch(e) {
                            print('Error: $e');
                          }
             
                  },
                              child: Container(
                                margin: const EdgeInsets.only(left: 80, top : 0.5),
                                padding: const EdgeInsets.only(top:0.5,right: 1.7),
                                height: MediaQuery.of(context).size.height * 0.04,
                                width: MediaQuery.of(context).size.width * 0.37,
                                
                                
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.values[5],
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add
                                    ,
                                    color: Colors.white,
                                    size: 18,),
                                    const Text('Add Income',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'poppins',
                                      fontWeight: FontWeight.w100,
                                      color: Colors.white
                                      
                                    )),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: 
                                  Border.all(
                                    color: Colors.white,
                                    width: 1.0
                                  )
                                              
                                              
                                
                                ),
                                
                              ),
                            ),
                
                
                          ],
                        ),
                      )
                    ],
                  ),
                )
                : 
                 Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 15 , top: 20 , bottom:10, right: 10),
                        
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.width * 0.9,
                                 decoration: BoxDecoration(
                                   color:  const images.Color.fromARGB(255, 233, 233, 255),
                                   borderRadius: BorderRadius.circular(5)
                                 ),
                
                                  child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text("Total Balance \t ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins',
                                              
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54
                                            ),
                                            textAlign: TextAlign.start,),
                                          ),
                                           
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text('₹${totalBalance.toString()}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 23,
                                          fontFamily: 'poppins',
                                          fontWeight: FontWeight.bold,
                                          color: const images.Color.fromARGB(255, 0, 0, 0),
                                        ),
                                        ),
                                      ),
                                        ],
                                      ), 
                                    const Spacer(),
                      Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.18,
                       margin: const EdgeInsets.only(right: 5,top: 13),
                       padding: const EdgeInsets.only(left: 5),
                      
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(52, 49, 199, 1),
                        borderRadius: BorderRadius.circular(50)
                                   
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('May',
                          style: TextStyle(
                            color: Colors.white
                          ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,)
                        ],
                      ),
                      
                      
                      ),
                      Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.1,
                      margin: const EdgeInsets.only(right: 10,top: 13),
                      
                 
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(64, 123, 255,0.1),
                        shape: BoxShape.circle                    
                      ),
                      child:IconButton(
                        icon: Icon(Icons.list_rounded,
                        color: images.Color.fromRGBO(0, 0, 0, 1),),
                         
                        onPressed: null,
                        iconSize: 13,
                      ),
                    ),
                    
                
                                     
                                                                             
                                      
                
                                      
                
                                    ],
                                  ),
                                  
                                )
                                , 
                                SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                Container (
                
                  margin: const EdgeInsets.only(left : 15 , right: 15, bottom: 20 , top: 10),
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width *0.9,
                  
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.black12,
                      width: 1.0,
                    )
                  ),
                  child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10,top: 3),
                                            child: Text("Spending process",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins',
                                              
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54
                                            ),
                                            textAlign: TextAlign.start,),
                                          ),
                                          
                                         AnimatedContainer(
                                          duration: const Duration(seconds: 1),
                                          margin: const EdgeInsets.only(left: 20, right: 10),
                                          height: MediaQuery.of(context).size.height * 0.02,
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: const images.Color.fromARGB(0, 7, 243, 58),
                                            border: Border.all(
                                              color: Colors.black87,
                                              width: 1.0
                                            )
                                            
                                          ),
                                         ),
                                          images.Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              images.Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10,top: 5),
                                                    child: Text("left budget",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'poppins',
                                                      
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black54
                                                    ),
                                                    textAlign: TextAlign.start,),
                                                  ),
                                                  Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text('₹${totalBalance.toString()}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'poppins',
                                          fontWeight: FontWeight.w800,
                                          color: const images.Color.fromARGB(255, 0, 0, 0),
                                        ),
                                        ),
                                      ),
                                                ],
                                              ),

                                               images.Column(
                                                 children: [
                                                   Padding(
                                                                                               padding: const EdgeInsets.only(top: 10,right: 5),
                                                                                               child: Text("Spent budget",
                                                                                               style: TextStyle(
                                                                                                 fontSize: 12,
                                                                                                 fontFamily: 'poppins',
                                                                                                 
                                                                                                 fontWeight: FontWeight.w600,
                                                                                                 color: Colors.black54
                                                                                               ),
                                                                                               textAlign: TextAlign.start,),
                                                                                             ),
                                        Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: Text("0",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins',
                                              
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black54
                                            ),
                                            textAlign: TextAlign.start,),
                                          ),
                                                 ],
                                               ),
                                            ],
                                          ),
                                           
                                 
                                        ],
                                      ), 
                
                  ),
                              ],
                            ),
        

                  
                )
                ,
                 SliverToBoxAdapter(
                  
                child: Container (
                
                  margin: const EdgeInsets.only(left : 15 , right: 15, bottom: 20 , top: 10),
                  height: MediaQuery.of(context).size.height * 0.15,
                  
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.black12,
                      width: 1.0,
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.09,
                        width: MediaQuery.of(context).size.width * 0.18,
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color:  const Color.fromARGB(128, 241, 177, 241),
                          shape: BoxShape.circle                    
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline_outlined,
                          color: Color.fromRGBO(238, 130, 238, 1),),
                          onPressed: 
                          addExpense,
                          iconSize: 30,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.09,
                        width: MediaQuery.of(context).size.width * 0.18,
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color:  const Color.fromARGB(128, 255, 196, 86),
                          shape: BoxShape.circle                    
                        ),
                        child: const IconButton(
                          icon: Icon(Icons.savings_outlined,
                          color: Color.fromRGBO(255, 165, 0, 1),),
         
                          onPressed: null,
                          iconSize: 30,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.09,
                        width: MediaQuery.of(context).size.width * 0.18,
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(128, 117, 249, 117),
                          shape: BoxShape.circle                    
                        ),
                        child: const IconButton(
                          icon: Icon(Icons.dashboard_customize_outlined,
                          color: Color.fromRGBO(0, 128, 0, 1),),
                          onPressed: null,
                          iconSize: 30,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.09,
                        width: MediaQuery.of(context).size.width * 0.18,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color:  const Color.fromARGB(255, 227, 227, 255),
                          shape: BoxShape.circle                    
                        ),
                        child: const IconButton(
                          icon: Icon(Icons.money_off_csred_outlined,
                          color: Color.fromRGBO(0, 0, 255, 1),),
                          onPressed: null,
                          iconSize: 30,
                        ),
                      ),
                    ],
                  ),
                
                  ),
                 
                 
                  
                ),
                 SliverToBoxAdapter(
         
                child: Container(
                  margin: const EdgeInsets.all(15),
                  height: 30,
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        'Today Expense',
                         style: TextStyle(
                          fontSize: 16,
                         fontWeight: FontWeight.w600,
                          fontFamily: 'poppins'
                      )
                      ),
         
                      
                    ],
                  ),
                ),
                  
                ),
                  
                
                SliverList(
                  delegate: SliverChildBuilderDelegate
                  (
                    (BuildContext context , int index) {
                    return Container (
                      padding: const EdgeInsets.all(10),
         
                  margin: const EdgeInsets.only(left: 20,right: 20 , top:  10 ,bottom: 10),
                  height: MediaQuery.of(context).size.height * 0.11,
                  
                  
                   decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                           color:  const Color.fromARGB(255, 227, 227, 255),
                          border: Border.all(
                            color: Colors.grey
                          )
         
                        ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                           
                            product[index].name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w600
                            ),
                          ),
                      
                          Text(
                            '₹' + 
                            product[index].amount,                           
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                  
                );   
                    },
                    childCount: product.length,
                  ),   
                ),
            ],           
          ),
         ),
       );    
  }  
}
