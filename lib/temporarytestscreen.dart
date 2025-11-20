import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TemporaryTestScreen extends StatefulWidget {
  const TemporaryTestScreen({super.key});

  @override
  State<TemporaryTestScreen> createState() => _TemporaryTestScreenState();
}

class _TemporaryTestScreenState extends State<TemporaryTestScreen> {
  String result = "Waiting...";

  @override
  void initState() {
    super.initState();
    testErpApi();
  }

  Future<void> testErpApi() async {
    final dio = Dio();
    final url = "http://pg-ERPBI.premiergroup.com.pk:7060/api/Worker/GetErpEmployees?EmpCode=99917864";

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Basic UHJFbSFlci5Hcm91cCQkJCsrOkNyRThpVmUmKl4xMjM0NTYrKw==',
            'Pr3mKEY': 'W74=Jse==ZU1JWR158TjJuUjlVN@t3Zz09',
          },
          validateStatus: (_) => true,
        ),
      );

      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");

      setState(() {
        result = "Status: ${response.statusCode}\nData: ${response.data}";
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ERP API Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: Text(result)),
      ),
    );
  }
}
