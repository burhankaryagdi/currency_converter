import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _apiKey = "b27169bb744a6d7ec1a83ce3131ce901";
  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key=";

  final TextEditingController _controller = TextEditingController();

  final Map<String, double> _oranlar = {};

  String _secilenKur = "USD";
  double _sonuc = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter', style: TextStyle(fontSize: 30)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body:
          _oranlar.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildExchangeRow(),
                    SizedBox(height: 16),
                    _buildSonucText(),
                    SizedBox(height: 16),
                    Container(height: 2, color: Colors.blueGrey),
                    SizedBox(height: 16),
                    _buildKurList(),
                  ],
                ),
              )
              : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildExchangeRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (String yeniDeger) {
              _hesapla();
            },
          ),
        ),
        SizedBox(width: 16),
        DropdownButton(
          underline: SizedBox(),
          value: _secilenKur,
          items:
              _oranlar.keys.map((String kur) {
                return DropdownMenuItem<String>(value: kur, child: Text(kur));
              }).toList(),
          onChanged: (String? yeniDeger) {
            if (yeniDeger != null) {
              _secilenKur = yeniDeger;
              _hesapla();
            }
          },
        ),
      ],
    );
  }

  void _hesapla() {
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_secilenKur];

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _verileriInternettenCek() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    Map<String, dynamic> rates = parsedResponse["rates"];
    double? baseTlKuru = rates["TRY"];

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }
    setState(() {});
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(_oranlar.keys.toList()[index]),
      trailing: Text(
        "${_oranlar.values.toList()[index].toStringAsFixed(2)} TL",
      ),
    );
  }

  Widget _buildSonucText() {
    return Text(
      "${_sonuc.toStringAsFixed(2)} TL",
      style: TextStyle(fontSize: 24),
    );
  }

  Widget _buildKurList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _oranlar.keys.length,
        itemBuilder: _buildListItem,
      ),
    );
  }
}

  /*
{
    "success": true,
    "timestamp": 1519296206,
    "base": "EUR",
    "date": "2021-03-17",
    "rates": {
        "AUD": 1.566015,
        "CAD": 1.560132,
        "CHF": 1.154727,
        "CNY": 7.827874,
        "GBP": 0.882047,
        "JPY": 132.360679,
        "USD": 1.23396,
    [...]
    }
}
 */

