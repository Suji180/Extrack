import 'package:extrack/datetime/date_time_helper.dart';
import 'package:extrack/models/expense_item.dart';

class Expensedata {

  //list of all expenses
  List<ExpenseItem> overallExpensesList  = [];
  //get all expenses
  List<ExpenseItem> getAllExpensesList()
  {
    return overallExpensesList;
  }
  //add an expense
  void addExpense(ExpenseItem expense)
  {
    overallExpensesList.add(expense);
  }
  //delete an expense
  void deleteExpense(ExpenseItem expense)
  {
    overallExpensesList.remove(expense);
  }
  //get weekday expenses (particular daytime)

  String getDayName(DateTime date)
  {
    switch (date.weekday)
    {
      case 1:
       return 'Monday';
      case 2:
       return 'Tuesday';
      case 3:
       return 'Wednesday';
      case 4:
       return 'Thursday';
      case 5:
       return 'Friday';
      case 6:
       return 'Saturday';
      case 7:
       return 'Sunday';
      default:
       return '';     
    }
  }
  
  //get the date for the start of the week (sunday)

  DateTime startOfWeekDate()
  {
     DateTime? startOfWeek;

     //gets today date
     DateTime today = DateTime.now();

     // go backwards to find the last Sunday
     for (int i =0 ; i<7;i++)
     {
      if(getDayName(today.subtract(Duration(days: i)))=='Sunday')
      {
        startOfWeek = today.subtract(Duration(days:i));
       
      }
     }
      return startOfWeek!;
  }


  /*
        convert overall list of expenses inta daily expnese summary
        
        eg :
        [food,date,money]

        DailyExpenseSummary = {
          how much money spent for each day }
  */

  Map<String,double>  calculateDailyExpenseSummary()
  {
    Map<String,double> DailyExpenseSummary = {
      //date yyyymmdd : amountTotalforday
    };

    for(var expense in overallExpensesList)
    {
      String date = convertDateTimeToString(expense.date);
      double amount = double.parse(expense.amount);

      if(DailyExpenseSummary.containsKey(date))
      {
        double currentAmount = DailyExpenseSummary[date]!;
        currentAmount+=amount;
        DailyExpenseSummary[date]=currentAmount;
      }
      else
      {
        DailyExpenseSummary.addAll({date:amount});

      }
    }
    return DailyExpenseSummary;
  }


  
}
