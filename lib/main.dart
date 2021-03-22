

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: MyHomePage(title: _title),
      home: MySplashScreen(title: _title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class MySplashScreen extends StatefulWidget {
  MySplashScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}


class _MySplashScreenState extends State<MySplashScreen> {
  @override
  Widget build(BuildContext context) {
    print("Triggered MySplashScreenState");
    return new SplashScreen(
      seconds: 10,
      navigateAfterSeconds: new MyHomePage(),
      image:  new Image.asset('assets/logo.png'),  
      backgroundColor: Colors.white,
      photoSize: 200,
      loaderColor: Colors.amber,
    );
  }
}




class ProductInfo{
  String ProdctCode;
  String BarCode;
}

class ProductName{
  String English;
  String ChineseHK;
  String ChineseCN;
}

class ProductBrandName{
  String English;
  String ChineseHK;
  String ChineseCN;
}

class ProductOffers{
  String SuperMarketCode;
  String English;
  String ChineseHK;
  String ChineseCN;
}

class ProductPrice{
  String SuperMarketCode;
  String Price;
}

class Product {
  String ProductCode="";
  List<ProductName> Name=[];
  List<ProductBrandName> Brand=[];
  List<ProductPrice> Price=[];
  List<ProductOffers> Offers=[];
}


class _MyHomePageState extends State<MyHomePage> {

  String _scanBarcode = '';

  List<ProductInfo> pdtCodeList = [];
  List<Product> pdtList = [];

  Product pdtInfo = new Product();

  List<Widget> textWidgetListPrice = List<Widget>();
  List<Widget> textWidgetListOffer = List<Widget>();


  Future<void> doScanCode() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      print("Scanned Barcode:" + _scanBarcode);
      DoSearchData(_scanBarcode);
    });
  }


  Future<void> loadCSVData() async {
    String data_BarCode = await DefaultAssetBundle.of(context).loadString(
        "assets/barcode.json");
    final jsonResultBarCode = json.decode(data_BarCode);
    String data_Product = "";


    final response = await http.get("https://online-price-watch.consumer.org.hk/opw/opendata/pricewatch.json");

    if (response.statusCode == 200) {
      data_Product=response.body;
    }
    final jsonResultProduct = json.decode(data_Product);

    String barCode;
    String pdtCode;

    for (var jsonObj in jsonResultBarCode) {
      ProductInfo productInfo = new ProductInfo();
      barCode = jsonObj['BarCode'].toString();
      pdtCode = jsonObj['ProductCode'].toString();
      productInfo.ProdctCode = pdtCode;
      productInfo.BarCode = barCode;
      pdtCodeList.add(productInfo);
    }

    for (var jsonObj in jsonResultProduct) {
      Product pdt = new Product();

      pdt.ProductCode = jsonObj['code'].toString();


      //BrandName
      ProductBrandName brandName = new ProductBrandName();
      brandName.ChineseHK = jsonObj['brand']['zh-Hant'].toString();
      brandName.ChineseCN = jsonObj['brand']['zh-Hans'].toString();
      brandName.English = jsonObj['brand']['en'].toString();
      pdt.Brand.add(brandName);

      //TODO: Product Name
      ProductName pdtName = new ProductName();
      pdtName.ChineseHK = jsonObj['name']['zh-Hant'].toString();
      pdtName.ChineseCN = jsonObj['name']['zh-Hans'].toString();
      pdtName.English = jsonObj['name']['en'].toString();
      pdt.Name.add(pdtName);
      //TODO: Price


      List<ProductPrice> pdtPriceList = new List<ProductPrice>();

      for (var pdtPriceItem in jsonObj['prices']) {
        ProductPrice pdtPrice = new ProductPrice();
        pdtPrice.SuperMarketCode = pdtPriceItem['supermarketCode'].toString();
        pdtPrice.Price = pdtPriceItem['price'];
        pdtPriceList.add(pdtPrice);
      }
      pdt.Price.addAll(pdtPriceList);

      List<ProductOffers> pdtOffersList = new List<ProductOffers>();

      //TODO: Offers
      for (var pdtOfferItem in jsonObj['offers']) {
        ProductOffers pdtOffers = new ProductOffers();
        pdtOffers.SuperMarketCode = pdtOfferItem['supermarketCode'].toString();
        pdtOffers.ChineseCN = pdtOfferItem['zh-Hans'].toString();
        pdtOffers.ChineseHK = pdtOfferItem['zh-Hant'].toString();
        pdtOffers.English = pdtOfferItem['en'].toString();
        pdtOffersList.add(pdtOffers);
      }
      pdt.Offers.addAll(pdtOffersList);
      pdtList.add(pdt); //All
    }
  }

  Future<void> getPrices(productCode) async {}

  Future<String> searchProductCode(barcode) async {
    String tmpResult = "";


    for (var searchObj in pdtCodeList) {
      print(barcode + "----" + searchObj.BarCode.toString());
      if (searchObj.BarCode
          .toString()
          .hashCode == barcode
          .toString()
          .hashCode) {
        print("Search barcode:" + searchObj.ProdctCode);
        tmpResult = searchObj.ProdctCode;
        break;
      }
    }


    return tmpResult;
  }

  Future<Product> _searchProduct(productCode) async {
    Product tmpPdt = new Product();
    print("SearchProduct productCode:" + productCode);
    for (var product in pdtList) {
      if (product.ProductCode.toString() == productCode) {
        print("Found Product !!! ");
        tmpPdt = product;
        break;
      }
    }
    return tmpPdt;
  }

  @override
  void initState() {
    super.initState();
    doScanCode();
  }

  Future<Product> DoSearchData(barCode) async {
    await loadCSVData();
    //barCode = "";
    print("DoSearchData BarCode:" + barCode);
    String pdtCode = await searchProductCode(barCode);
    print("Product Code:" + pdtCode);
    Product tmppdt = await _searchProduct(pdtCode);
    return tmppdt;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Colors.deepOrange,
              tabs: [
                Tab(icon: new SvgPicture.asset("assets/price_check.svg",color: Colors.white),text:"超市價格"),
                Tab(icon: new SvgPicture.asset("assets/event_note.svg",color:Colors.white),text:"優惠情報"),
                Tab(icon: new SvgPicture.asset("assets/aboutme.svg",color:Colors.white),text:"關於本APP"),
                //Tab(icon:Icons.a)
              ],
            ),
            title: Text('碼上找到的結果'),
            backgroundColor: Colors.amber,
          ),
          body: TabBarView(
            children: [
            FutureBuilder<Product>(
              future: DoSearchData(_scanBarcode),
            builder:
                (BuildContext context, AsyncSnapshot<Product> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return new Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                            child: Container(
                              color: Colors.grey[100],
                              child: Column(
                                children: [
                                  Text("沒有找到任何資料",style: TextStyle(color: Colors.red, height: 15, fontSize: 30,),),
                                ],
                              ),
                            )),
                        Container(
                            width: 180.0,
                            height: 65.0,
                            child :RaisedButton(
                              child: Text("掃描條碼",style: TextStyle( fontSize: 30)),
                              onPressed: () => doScanCode(),
                              color: Colors.amber, //Color(0xff0091EA),
                              textColor: Colors.white,
                              splashColor: Colors.grey,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),

                            )
                        )

                      ]
                  );
                case ConnectionState.waiting:
                  return new Center(child: new CircularProgressIndicator());
                case ConnectionState.active:
                  return new Text('');
              // ignore: missing_return, missing_return
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return new Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[

                          Expanded(
                              child: Container(
                                color: Colors.grey[100],
                                child: Column(
                                  children: [
                                    Text('${snapshot.error}',style: TextStyle(color: Colors.red, height: 15, fontSize: 30,),),
                                  ],
                                ),
                              )),
                          Container(
                              width: 180.0,
                              height: 65.0,
                              child :RaisedButton(
                                child: Text("掃描條碼",style: TextStyle( fontSize: 30)),
                                onPressed: () => doScanCode(),
                                color: Colors.amber, //Color(0xff0091EA),
                                textColor: Colors.white,
                                splashColor: Colors.grey,
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),

                              )
                          )

                        ]
                    );
                  } else {  //Correct Data here! Master Detail Design
                    if(snapshot.data.Brand.length==0){
                      return new Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(100),
                              color: Colors.grey[100],
                              child: Table(
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children : [
                                  TableRow(
                                  children: [
                                      Text("沒有找到任何資料", textAlign: TextAlign.center,textScaleFactor: 3.25,style: TextStyle(color: Colors.red),),
                                  ]),
                                ],
                              ),
                            ),
                            Expanded
                              (child:new Align
                              (
                              alignment: FractionalOffset.bottomCenter,
                              child: new Container(
                                  width: double.maxFinite,
                                  child :RaisedButton(
                                    child: Text("掃描條碼",style: TextStyle(fontSize: 30)),
                                    onPressed: () => doScanCode(),
                                    color: Colors.amber, //Color(0xff0091EA),
                                    textColor: Colors.white,
                                    splashColor: Colors.grey,
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  )
                              ),
                            ),
                            ),
                          ]);
                    }
                    else
                    {
                      return new Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(40),
                              //color: Colors.grey[100],
                              child: Table(
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children : [
                                  TableRow(
                                    children: [
                                      for ( var item in snapshot.data.Brand)
                                        Text(item.ChineseHK, textAlign: TextAlign.center,textScaleFactor: 1.25,
                                          style: TextStyle(color: Colors.deepOrange,),),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      for ( var item in snapshot.data.Name)
                                        Text(item.ChineseHK, textAlign: TextAlign.center,textScaleFactor: 1.50,
                                          style: TextStyle(color: Colors.deepOrange,),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              //padding: const EdgeInsets.all(10.0),
                              //color: Colors.grey[100],
                              child: Table(
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  for ( var item in snapshot.data.Price )
                                    TableRow(
                                        children: [
                                          Image.asset("assets/" + item.SuperMarketCode.toLowerCase()+ ".png",
                                            width: 70,
                                            height: 70,
                                            alignment: Alignment.center,
                                          ),
                                          Text(item.Price,textAlign: TextAlign.center,textScaleFactor: 2.0,),
                                        ]
                                    ),
                                ],
                              ),
                            ),
                            Expanded
                              (child:new Align
                              (
                                alignment: FractionalOffset.bottomCenter,
                                child: new Container(
                                    width: double.maxFinite,
                                    child :RaisedButton(
                                      child: Text("掃描條碼",style: TextStyle(fontSize: 30)),
                                      onPressed: () => doScanCode(),
                                      color: Colors.amber, //Color(0xff0091EA),
                                      textColor: Colors.white,
                                      splashColor: Colors.grey,
                                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    )
                                ),
                            ),
                            ),
                          ]
                      );
                    }
                  }
              }
            }),
              FutureBuilder<Product>(
                  future: DoSearchData(_scanBarcode),
                  builder:
                      (BuildContext context, AsyncSnapshot<Product> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return new Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                    color: Colors.grey[100],
                                    child: Column(
                                      children: [
                                        Text("沒有找到任何資料",style: TextStyle(color: Colors.red, height: 15, fontSize: 30,),),
                                      ],
                                    ),
                                  )),
                              Container(
                                  width: 180.0,
                                  height: 65.0,
                                  child :RaisedButton(
                                    child: Text("掃描條碼",style: TextStyle( fontSize: 30)),
                                    onPressed: () => doScanCode(),
                                    color: Colors.amber, //Color(0xff0091EA),
                                    textColor: Colors.white,
                                    splashColor: Colors.grey,
                                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),

                                  )
                              )

                            ]
                        );
                      case ConnectionState.waiting:
                        return new Center(child: new CircularProgressIndicator());
                      case ConnectionState.active:
                        return new Text('');
                    // ignore: missing_return, missing_return
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return new Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[

                                Expanded(
                                    child: Container(
                                      color: Colors.grey[100],
                                      child: Column(
                                        children: [
                                          Text('${snapshot.error}',style: TextStyle(color: Colors.red, height: 15, fontSize: 30,),),
                                        ],
                                      ),
                                    )),
                                Container(
                                    width: 180.0,
                                    height: 65.0,
                                    child :RaisedButton(
                                      child: Text("掃描條碼",style: TextStyle( fontSize: 30)),
                                      onPressed: () => doScanCode(),
                                      color: Colors.amber, //Color(0xff0091EA),
                                      textColor: Colors.white,
                                      splashColor: Colors.grey,
                                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),

                                    )
                                )

                              ]
                          );
                        } else {  //Correct Data here! Master Detail Design
                          if(snapshot.data.Brand.length==0){
                            return new Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(100),
                                    color: Colors.grey[100],
                                    child: Table(
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children : [
                                        TableRow(
                                            children: [
                                              Text("沒有找到任何資料", textAlign: TextAlign.center,textScaleFactor: 3.25,style: TextStyle(color: Colors.red),),
                                            ]),
                                      ],
                                    ),
                                  ),
                                  Expanded
                                    (child:new Align
                                    (
                                    alignment: FractionalOffset.bottomCenter,
                                    child: new Container(
                                        width: double.maxFinite,
                                        child :RaisedButton(
                                          child: Text("掃描條碼",style: TextStyle(fontSize: 30)),
                                          onPressed: () => doScanCode(),
                                          color: Colors.amber, //Color(0xff0091EA),
                                          textColor: Colors.white,
                                          splashColor: Colors.grey,
                                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        )
                                    ),
                                  ),
                                  ),
                                ]);
                          }
                          else
                          {
                            return new Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(40),
                                    //color: Colors.grey[100],
                                    child: Table(
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children : [
                                        TableRow(
                                          children: [
                                            for ( var item in snapshot.data.Brand)
                                              Text(item.ChineseHK, textAlign: TextAlign.center,textScaleFactor: 1.25,
                                                style: TextStyle(color: Colors.deepOrange,),),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            for ( var item in snapshot.data.Name)
                                              Text(item.ChineseHK, textAlign: TextAlign.center,textScaleFactor: 1.50,
                                                style: TextStyle(color: Colors.deepOrange,),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //padding: const EdgeInsets.all(10.0),
                                    //color: Colors.grey[100],
                                    child: Table(
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      children: [
                                        if(snapshot.data.Offers.length==0)
                                          TableRow(
                                              children: [
                                                Text("沒有找到優惠情報", textAlign: TextAlign.center,textScaleFactor: 2.25,style: TextStyle(color: Colors.red),),

                                              ]
                                          )
                                        else


                                        for ( var item in snapshot.data.Offers )
                                          TableRow(
                                              children: [
                                                Image.asset("assets/" + item.SuperMarketCode.toLowerCase()+ ".png",
                                                  width: 70,
                                                  height: 70,
                                                  alignment: Alignment.center,
                                                ),
                                                Text(item.ChineseHK,textAlign: TextAlign.justify,textScaleFactor: 1.25,),
                                              ]
                                          ),
                                      ],
                                    ),
                                  ),
                                  Expanded
                                    (child:new Align
                                    (
                                    alignment: FractionalOffset.bottomCenter,
                                    child: new Container(
                                        width: double.maxFinite,
                                        child :RaisedButton(
                                          child: Text("掃描條碼",style: TextStyle(fontSize: 30)),
                                          onPressed: () => doScanCode(),
                                          color: Colors.amber, //Color(0xff0091EA),
                                          textColor: Colors.white,
                                          splashColor: Colors.grey,
                                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        )
                                    ),
                                  ),
                                  ),
                                ]
                            );
                          }
                        }
                    }
                  }),
              Center(
                child: Container(
                  margin: EdgeInsets.all(5),

                  child:
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children : [
                        TableRow(
                          children:  [
                              Padding (
                                padding: const EdgeInsets.all(8.0),
                                child: Text("關於本APP", textAlign: TextAlign.center,textScaleFactor: 2.25,
                                style: TextStyle(color: Colors.black),),
                            )
                        ]),
                        TableRow(
                            children:  [
                              Padding (
                                padding: const EdgeInsets.all(1.0),
                                child: Text("本APP所顯示的資料由香港消費者委員會提供。有見及此，在本APP顯示情報也許與實際情況有差異，故此只能作參考之用", textAlign: TextAlign.justify,textScaleFactor: 1.25,
                                  style: TextStyle(color: Colors.black),),
                              )
                            ]),
                        TableRow(
                            children:  [
                              Padding (
                                padding: const EdgeInsets.all(1.0),
                                child: Text("本APP乃個人製作，免費提供給所有人下載。如果各位有意聯絡製作者，請Click我的Linkedln個人專頁，謝謝。", textAlign: TextAlign.justify,textScaleFactor: 1.25,
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            ]),
                        TableRow(
                            children:  [
                              Padding (
                                padding: const EdgeInsets.all(1.0), //const EdgeInsets.fromLTRB(1, 10, 10, 0),
                                child: RichText(
                                   text: new TextSpan(
                                      text: '我的Linkedln個人專頁',
                                      style: new TextStyle(color: Colors.deepOrange, height: 10, fontSize: 20 ), //TextStyle(height: 5, fontSize: 10),
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () { launch('https://www.linkedin.com/in/timothy-leung-48261b8b/');
                                        },
                                  ),
                                ),
                              ) //
                            ]),
                      ], //Children
                  ),

                ),

              ),

            ],
          ),
        ),
      ),
    );

  }
}

