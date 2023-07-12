import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cripto_currency/data/constants/constants.dart';

import '../data/model/crypto.dart';

class CoinListScreen extends StatefulWidget {
  CoinListScreen({super.key, this.cryptoList});
  List<Crypto>? cryptoList;
  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  List<Crypto>? cryptoList;
  final controller = TextEditingController();

  bool isSearchLoadingVisible = false;

  @override
  void initState() {
    super.initState();
    cryptoList = widget.cryptoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        title: Text(
          'ارز باکس',
          style: TextStyle(fontFamily: 'mh'),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
            edgeOffset: 0,
            backgroundColor: blackColor,
            color: greenColor,
            onRefresh: () async {
              List<Crypto> refreshedData = await _getData();
              setState(() {
                cryptoList = refreshedData;
              });
            },
            child: Column(
              children: [
                Container(
                  height: 55,
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: TextField(
                    style: TextStyle(fontFamily: 'mh'),
                    textAlign: TextAlign.end,
                    controller: controller,
                    cursorColor: blackColor,
                    decoration: InputDecoration(
                      hintText: 'اسم رمز ارز خودتون رو سرچ بکنید',
                      fillColor: greenColor,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: blackColor, width: 2.0),
                      ),
                    ),
                    onChanged: _searchCrypto,
                  ),
                ),
                Visibility(
                  visible: isSearchLoadingVisible,
                  child: Text(
                    '...در حال آپدیت ارز ها',
                    style: TextStyle(color: greenColor, fontFamily: 'mh'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cryptoList!.length,
                    itemBuilder: (context, index) {
                      return _getListTileItem(cryptoList![index]);
                    },
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _getListTileItem(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(color: greenColor),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(color: greyColor),
      ),
      // Text(
      //       crypto.rank.toString(),
      //       style: TextStyle(color: greyColor),
      //     ),
      leading: SizedBox(
        width: 30.0,
        child: Center(
          child: Image.network(
            'http://assets.coincap.io/assets/icons/${crypto.symbol.toLowerCase()}@2x.png',
          ),
        ),
      ),
      trailing: SizedBox(
        width: 150.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(color: greyColor, fontSize: 16),
                ),
                Text(
                  crypto.changePercent24Hr.toStringAsFixed(2),
                  style: TextStyle(
                    color: _getColorChangeText(crypto.changePercent24Hr),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 50,
              child: Center(
                child: _getIconChangePercent(crypto.changePercent24Hr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconChangePercent(double percentChange) {
    return percentChange <= 0
        ? Icon(
            Icons.trending_down,
            size: 24,
            color: redColor,
          )
        : Icon(
            Icons.trending_up,
            size: 24,
            color: greenColor,
          );
  }

  Color _getColorChangeText(double percentChange) {
    return percentChange <= 0 ? redColor : greenColor;
  }

  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    return cryptoList;
  }

  Future<void> _searchCrypto(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearchLoadingVisible = true;
      });
      var result = await _getData();

      setState(() {
        isSearchLoadingVisible = false;
        cryptoList = result;
      });
      return;
    }

    final suggestions = cryptoList!.where((Crypto) {
      final cryptoName = Crypto.name.toLowerCase();
      final input = query.toLowerCase();

      return cryptoName.contains(input);
    }).toList();

    setState(() {
      cryptoList = suggestions;
    });
  }
}
