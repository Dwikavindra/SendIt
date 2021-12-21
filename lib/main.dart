import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tcp/othermessage.dart';
import 'package:tcp/ownmessage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: () => MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const SubmitPage(),
            ));
  }
}

class SubmitPage extends StatefulWidget {
  const SubmitPage({Key? key}) : super(key: key);

  @override
  _SubmitPageState createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:()=>FocusScope.of(context).unfocus(),// dismiss when tapped
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,//dismiss keyboard when
                // scrolled up
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(children: [
                      Text("What is your name?",
                          style: TextStyle(fontSize: 20.sp)),
                      Padding(padding: EdgeInsets.only(top: 5.h)),
                      Container(
                          margin: EdgeInsets.only(left: 12.w),
                          width: 330,
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(214, 214, 214, 100),
                              borderRadius: BorderRadius.circular(14.65)),
                          child: TextFormField(
                            decoration: const InputDecoration(
                                hintText: "Do not enter a username with spaces ",
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 15, bottom: 11, top: 11, right: 15)),
                            controller: inputController,
                          )),
                      Padding(padding: EdgeInsets.only(top: 38.h)),
                      ElevatedButton(
                        onPressed: () async {
                          if (inputController.text.contains(" ")) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text('Username still has space')));
                            return;// check if the username has space if it has return nothing and show a warning
                            // in the form a snackbar
                          }
                          final socket =
                              await Socket.connect('34.101.88.159', 3389);// to connect to server
                          print(
                              'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
                          socket.write(inputController.text);// write the name to the server
                          Navigator.push(// to switch to another page
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage(
                                    title: inputController.text, socket: socket)),
                          );
                        },
                        style: ElevatedButton.styleFrom(// the enter button
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 15.0,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.h),
                          child: Text(
                            'Enter',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
                          ),
                        ),
                      )
                    ]),
                  ],
                ),
              ),
            ),
          )),
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

  final ScrollController scrollcontrol = ScrollController();

  List<String> messageList = [];
/*First we declare inputcontroller to control input from textfiled, scrollcontroller
* scroll to controll scroll in listview for message, we also declare message list to store
* the messages sent
* */
  late Stream broadcaststream;
/*Since  socket is in a form of Stream in Dart, A Stream provides a way to receive a sequence of  async events
* */
  @override
  void initState() {
    broadcaststream = widget.socket.asBroadcastStream();
    /*we cast broadcaststream with the function widget.socket.asBroadcastStream so that the stream
    * could be listened by more than one StreamBuilder*/
    super.initState();
  }

  @override
  void dispose() {
    widget.socket.destroy();/*to destroy the socket when page is dismissed*/
    widget.socket.close();/*to close the socket when page is dismissed*/
    inputController.dispose();/*dispose the input controller when page is dismissed*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      // Gesture Detector to close keyboard when user taps the screen
      child: Scaffold(
          appBar: AppBar(//we use a streambuilder on the appbar to listen to status call, and build the status bar
              backgroundColor: Colors.black,
              title: StreamBuilder(
                //Widget that builds itself based on the latest snapshot of interaction with a Stream.
                /*We use streambuilder so that we dont have to use await whic slows down the process
                of receiving the data  */
                  stream: broadcaststream,//input stream as broadcast stream
                  builder: (context, snapshot) {
                    //snapshot is to capture the data from the stream that comes from the server
                    if (snapshot.hasData == false) {//check if snapshot has data
                      return (const Text("Connecting..."));// return a text if it doesnt
                    }
                    else {//else
                      String data = String.fromCharCodes(snapshot.data as Uint8List);
                      // we read the data as a String by converting from Uint8List
                      if (data.contains("Connected to the Server!") ||
                          data.contains(": left") ||
                          data.contains(": joined")) {
                        // function bool contains(
                        // Pattern other,
                        // [int startIndex = 0]
                        // )
                        // Whether this string contains a match of other.
                        print(data);
                        return (Text("Status: ${data}"));
                      }
                      return (const Text("Connected to Chat Room"));
                    }
                  })),
          backgroundColor: Colors.white,
          body:Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,

            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StreamBuilder(// Use this streambuilder to listen for mesages
                        stream: broadcaststream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData == false ||
                              String.fromCharCodes(snapshot.data as Uint8List)
                                      .contains("Connected to the server!") ==
                                  true) {
                            return Flexible(
                              child: Container(
                                  height: MediaQuery.of(context).size.height - 300),
                            );
                          }

                            String sent = String.fromCharCodes(snapshot.data as Uint8List);
                          print(sent);
                          sent.contains(": joined")|| sent.contains(": left")||sent.contains(": ready")?
                          print("message not sent"):messageList.add(sent);// do a check if the string sent
                          //is a status then don't add it to the messageList else append to the list
                            return Flexible(
                              child: ListView.builder(//create a scrollable widget or chat page

                                  controller: scrollcontrol,
                                  itemCount: messageList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    String messagerecieved = messageList[index];
                                    if (messagerecieved.contains("${widget.title}:" )==false){
                                      //detect if the message is sent from the user if its not than return  a widgt
                                      // Other Message
                                      return OtherMessage(
                                          message: messageList[index]);
                                    } else {
                                      //else return a widget of  OwnMessage
                                      return OwnMessage(
                                          message: messageList[index]);
                                    }
                                  }),
                            );
                          }),
              SingleChildScrollView(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 14.w,bottom:20.w),
                        width: 300.w,
                        height: 39.h,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(214, 214, 214, 100),
                            borderRadius: BorderRadius.circular(14.65)),
                        child: TextFormField(// text input to listen for message
                          keyboardType: TextInputType.multiline,//so that we could enter and have multiple lines of words
                          minLines: 1,
                          maxLines: 5,
                          decoration: const InputDecoration(
                              hintText: 'Enter your message',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 5, right: 15)),
                          controller: inputController,
                        ),
                      ),
                      IconButton(
                          padding: EdgeInsets.only(top: 5.h),
                          iconSize: 36,
                          onPressed: () {
                            //when the button is pressed
                            String message = inputController.text;
                            //get the text from TextFormField
                            widget.socket.write("${widget.title}: " + message);
                            //send it to the server by socket write
                            inputController.clear();
                            //delete the words written in the text field
                            Timer(Duration(milliseconds: 100), () {
                              scrollcontrol.animateTo(
                                scrollcontrol.position.maxScrollExtent,
                                //scroll the listview to the very bottom everytime the user inputs a message
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            });
                          }

                          ,icon: SvgPicture.asset('assets/images/SendButton.svg'))
                    ],
                  ),
                ),
              ),
          ]))),
    );
  }
}
