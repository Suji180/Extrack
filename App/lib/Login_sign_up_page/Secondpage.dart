import 'package:extrack/main.dart';
import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }


  void _checkOtpStatus() {
    bool complete = _controllers.every((c) => c.text.length == 1);
    if (complete != _isOtpComplete) {
      setState(() {
        _isOtpComplete = complete;
      });
    }
  }

  void _onConfirm() {
    if (_isOtpComplete) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) =>  const MainApp()));
    }
  }


  Widget _buildOtpBox(int index,BuildContext context) {
    final TextScaler ts= MediaQuery.textScalerOf(context);
    final double scaleFactor=ts.scale((1.0));
    final size=50.0* scaleFactor +6.0;
    return SizedBox(
      height: size,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.symmetric(
            vertical: 4*scaleFactor,
            horizontal: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),

        onChanged: (value) {

          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          } else if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }

        _checkOtpStatus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100.0, left: 25.0, right: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("OTP verification",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 26, 95, 135))),

            const SizedBox(height: 10),

            const Text(
                'Enter the 6 digit OTP pin send to your email',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index)
              {
                return Expanded(
                  child:Padding(
                      padding:const EdgeInsets.symmetric(horizontal: 4.0),
                      child:  _buildOtpBox(index,context),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),


            Row(
              children: [
                const Text(
                  "Didn't get code?",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resending code...')),
                    );
                  },
                  child: const Text('Resend Code', style: TextStyle(color: Color.fromARGB(255,26,95,135), fontSize: 16)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  onPressed: _isOtpComplete ? _onConfirm : null,
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}