import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        SizedBox(
          width: 500,
          child: CalcButton(),
        )
      ],
    );
  }
}

class CalcButton extends StatefulWidget {
  const CalcButton({Key? key}) : super(key: key);

  @override
  CalcButtonState createState() => CalcButtonState();
}

class CalcButtonState extends State<CalcButton> {
  double? _currentValue = 0;
  @override
  Widget build(BuildContext context) {
    var calc = SimpleCalculator(
      value: _currentValue!,
      hideExpression: false,
      hideSurroundingBorder: true,
      autofocus: true,
      onChanged: (key, value, expression) {
        setState(() {
          _currentValue = value ?? 0;
        });
        if (kDebugMode) {
          print('$key\t$value\t$expression');
        }
      },
      onTappedDisplay: (value, details) {
        if (kDebugMode) {
          print('$value\t${details.globalPosition}');
        }
      },
      theme: CalculatorThemeData(
        borderColor: Colors.black,
        borderWidth: 2,
        displayColor: Colors.black,
        displayStyle: const TextStyle(fontSize: 80, color: Colors.white),
        expressionColor: Colors.indigo,
        expressionStyle: const TextStyle(fontSize: 20, color: Colors.white),
        operatorColor: Colors.grey,
        operatorStyle: const TextStyle(fontSize: 30, color: Colors.white),
        commandColor: Colors.grey[500],
        commandStyle: const TextStyle(fontSize: 30, color: Colors.white),
        numColor: Colors.grey[700],
        numStyle: const TextStyle(fontSize: 50, color: Colors.white),
      ),
    );
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.grey[500])
      ),
      child: Tooltip(
        message: "Click to use a calculator",
        child: Row(
          children: [
            const Icon(Icons.calculate, color: Colors.black,),
            Text(
              "Calc Result: ${_currentValue.toString()}", 
              style: const TextStyle(
                color: Colors.black
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: calc);
            });
      },
    );
  }
}