import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=95656370";

void main() async {
  runApp(MaterialApp(
      title: "Conversor de Moedas",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        hintColor: Colors.amberAccent,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amberAccent))),
      ),
      home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  double real;
  double dolar;
  double euro;
  double bitcoin;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
    bitcoinController.text = (real/bitcoin).toStringAsFixed(6);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
    bitcoinController.text = (dolar * this.dolar/bitcoin).toStringAsFixed(6);
  }


  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    bitcoinController.text = (euro * this.euro/bitcoin).toStringAsFixed(6);
    dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);
  }

  void _bitcoinChanged(String text) {
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    euroController.text = (bitcoin * this.bitcoin/euro).toStringAsFixed(2);
    dolarController.text = (bitcoin * this.bitcoin/dolar).toStringAsFixed(6);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text("\$ Conversor de moedas"),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amberAccent, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Ocorreu um erro no sistema :(",
                    style: TextStyle(color: Colors.amberAccent, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amberAccent),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólar", "\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
                      Divider(),
                      buildTextField("Bitcoin", "BTC", bitcoinController, _bitcoinChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    onChanged: f,
    style: TextStyle(
        color: Colors.amberAccent, fontSize: 25.0),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      hintStyle: TextStyle(
          fontSize: 20.0, color: Colors.redAccent),
      labelText: label,
      labelStyle: TextStyle(
          color: Colors.amberAccent, fontSize: 25.0),
      border: OutlineInputBorder(),
      prefixText: prefix,
      prefixStyle: TextStyle(
          color: Colors.amberAccent, fontSize: 25.0),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
