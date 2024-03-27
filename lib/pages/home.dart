import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> currencies = [];
  String fromCurrency = '';
  String toCurrency = '';
  double amount = 0.0;
  double? convertedAmount;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currenciesJson = prefs.getString('currencies');

    if (currenciesJson != null) {
      List<String> cachedCurrencies =
          List<String>.from(jsonDecode(currenciesJson));
      setState(() {
        currencies = cachedCurrencies;
        fromCurrency = currencies[0];
        toCurrency = currencies[1];
      });
    } else {
      var uri = Uri.parse(
          'https://v6.exchangerate-api.com/v6/a7f0e525970e04f293e67f11/latest/USD');
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        Map<String, dynamic> conversionRates = data['conversion_rates'];
        setState(() {
          currencies = conversionRates.keys.toList();
          fromCurrency = currencies[0];
          toCurrency = currencies[1];
        });
        prefs.setString('currencies', jsonEncode(currencies));
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    }
  }

  void convertCurrency() async {
    var apiKey = 'a7f0e525970e04f293e67f11';
    var uri = Uri.parse(
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/${fromCurrency}');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      Map<String, dynamic> conversionRates = data['conversion_rates'];
      dynamic conversionRate = conversionRates[toCurrency];
      setState(() {
        convertedAmount = amount * conversionRate;
      });
    } else {
      print('Failed to convert currency: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: SvgPicture.asset('images/currency-exchange.svg'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    children: [
                      const Text(
                        'Amount to Convert: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter amount',
                          ),
                          onChanged: (value) {
                            setState(() {
                              amount = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    children: [
                      const Text(
                        'Source Currency: ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey)),
                        child: DropdownButton<String>(
                            value: fromCurrency,
                            underline: Container(),
                            items: currencies
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                fromCurrency = newValue!;
                              });
                            }),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    children: [
                      const Text(
                        'Target Currency:  ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                            value: toCurrency,
                            underline: Container(),
                            items: currencies
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                toCurrency = newValue!;
                              });
                            }),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: convertCurrency,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.greenAccent)),
                    child: const Text(
                      'Convert',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
                if (convertedAmount != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey)),
                    child: Text(
                      '$fromCurrency $amount is $toCurrency ${convertedAmount?.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  )
              ],
            ),
          ),
        ));
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Currency Converter',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profilepage');
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
              color: const Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_box_rounded),
          ),
        ),
      ],
    );
  }
}
