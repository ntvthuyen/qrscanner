import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _ViewExampleState();
}

class _ViewExampleState extends State<MyHomePage> { 
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  //@override
  //void reassemble() {
  //  super.reassemble();
  //  if (Platform.isAndroid) {
  //    controller!.pauseCamera();
  //  } else if (Platform.isIOS) {
  //    controller!.resumeCamera();
  //  }
  //}
  late TcpSocketConnection socket;
  late TextEditingController _controller_1;
  late TextEditingController _controller_2;
  
 
  @override
  void initState(){
      super.initState();
      _controller_1 = TextEditingController();
      _controller_2 = TextEditingController();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: (result != null)
                  ? Text(
              
                      'Alumni Id: ${result!.code}'
                      )
                  : Text('Scan a QR code'),
                                 
          ),
          Expanded(
            flex: 1,
            child: Row(children:[
                    SizedBox(width: 230, child: TextField(controller: _controller_1,decoration: InputDecoration( border: OutlineInputBorder(), hintText: 'ip'))),
                    SizedBox(width: 75, child: TextField(controller: _controller_2, decoration: InputDecoration( border: OutlineInputBorder(), hintText: 'port'), keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly
],)),
                    TextButton(child: Text('Apply'), onPressed: (){this.socketConnect();})
                  ]))

        ],
      ),
    );
  }
    void messageReceived(String msg){
    setState(() {
      print(msg);
    });
    }


  
    //starting the connection and listening to the socket asynchronously
  void startConnection() async{
    socket.enableConsolePrint(true);    //use this to see in the console what's happening
    if(await socket.canConnect(5000, attempts: 3)){   //check if it's possible to connect to the endpoint
      await socket.connect(5000, messageReceived, attempts: 3);
    }
  }

  void socketConnect() {

    this.socket=TcpSocketConnection(this._controller_1.text, int.parse(this._controller_2.text));
    startConnection();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
      
        result = scanData;
         
        
        });
      this.socket.sendMessage(result!.code ?? " ");

    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _controller_1.dispose();
    _controller_2.dispose();
}}
