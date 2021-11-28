import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

void main() async {
  final socket = await Socket.connect('34.101.88.159', 3389);
  print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
  runApp(MyApp(socket: socket));
  socket.write("h");
}

class MyApp extends StatelessWidget {
  final Socket socket;

  const MyApp({required this.socket, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', socket: socket),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Socket socket;

  MyHomePage({Key? key, required this.title, required this.socket})
      : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final inputController = TextEditingController();

  ScrollController scrollcontrol = ScrollController();

  List<String> messageList = [];

  @override
  void dispose() {
    // TODO: implement dispose
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            StreamBuilder(
                stream: widget.socket,
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return CircularProgressIndicator();
                  }
                  String sent =
                      String.fromCharCodes(snapshot.data as Uint8List);
                  if (sent.contains("joinedConnected to the server!") == true) {
                    return Padding(padding: EdgeInsets.all(0));
                  } else {
                    messageList.add(sent);
                    return Container(
                        height: MediaQuery.of(context).size.height - 300,
                        child: ListView.builder(
                          controller: scrollcontrol,
                          shrinkWrap: true,
                          itemCount: messageList.length,
                          itemBuilder: (BuildContext context, int index) {
                            String messagerecieved = messageList[index];
                            List<String> messagedisected =
                            messagerecieved.split(" ");
                            if (messagedisected[0] != "h:" &&
                                messagerecieved.contains(
                                    "Connected to the server!") == false) {
                              return Align(
                                  alignment: Alignment.centerLeft,
                                  child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                        MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            45,
                                      ),
                                      child: Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8)),
                                          color: Color(0xffdcf8c6),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: Stack(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 30,
                                                top: 5,
                                                bottom: 20,
                                              ),
                                              child: Text(
                                                messageList[index],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ]))));
                            }
                            else {
                              return Align(
                                  alignment: Alignment.centerRight,
                                  child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                        MediaQuery
                                            .of(context)
                                            .size
                                            .width - 45,
                                      ),
                                      child:
                                      Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8)),
                                          color: Colors.grey,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 45, vertical: 5),
                                          child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(
                                                    left: 10,
                                                    right: 30,
                                                    top: 5,
                                                    bottom: 20,
                                                  ),
                                                  child: Text(
                                                    messageList[index],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ]
                                          )
                                      )
                                  )
                              );
                            }
                          }));
                  }
                }),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter your message'),
              controller: inputController,
            ),
            IconButton(
                onPressed: () {
                  scrollcontrol.animateTo(scrollcontrol.position.maxScrollExtent, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
                  String message = inputController.text;
                  widget.socket.write("h: " + message);
                  inputController.clear();
                },
                icon: const Icon(Icons.send))
          ],
        ));
  }
}
