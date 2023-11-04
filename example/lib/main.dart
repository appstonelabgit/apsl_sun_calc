import 'package:apsl_sun_calc/apsl_sun_calc.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apsl Sun Calc Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic sunPosition;
  dynamic moonPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apsl Sun Calc Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sun Position:  \n${sunPosition ?? "Not Calculated"}",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  sunPosition = SunCalc.getSunPosition(
                    DateTime.now(),
                    51.5,
                    -0.1,
                  );
                });
              },
              child: const Text("Get Sun Position"),
            ),
          ],
        ),
      ),
    );
  }
}
