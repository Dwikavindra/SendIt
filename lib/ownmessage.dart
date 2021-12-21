import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class OwnMessage extends StatelessWidget {
  const OwnMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;// to get the message from the constructor
  @override
  Widget build(BuildContext context) {
    List<String> messagesplit = splitmessage(message);   // split the message to a list of string

    String username = username_search(messagesplit[0]); // get the username

    String withoutusername = messagewithoutusername(messagesplit); // get the message without username

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(username,
                style: GoogleFonts.poppins(// to display username on top of the mssage
                  fontSize: 15,
                )),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,// align it to the right if message is our own message
          child: ConstrainedBox(// below is where the widget for the message
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 45,
              ),
              child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.black,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Stack(children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 30,
                        top: 5,
                        bottom: 20,
                      ),
                      child: Text(
                        withoutusername,
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ]))),
        ),
      ],
    );
  }

  static String messagewithoutusername(List<String> text) {// function to get the message
    //without the username
    String result = "";
    for (int i = 1; i < text.length; i++) {
      if (text[i] == " " && i == 1) {
        continue;
      }
      result += text[i];
    }
    return result;
  }

  static List<String> splitmessage(String text) {
    //function to split the incoming message into a
    //list of strings
    List<String> finalresult = [];
    String result = "";


    for (int i = 0; i < text.length; i++) {

      if ((i + 1 < text.length && text[i + 1] == " ") || i == text.length - 1) {
        result += text[i];
        finalresult.add(result);
        result = "";
      } else if (text[i] == " ") {
        result = text[i];
        finalresult.add(result);
      } else {
        result += text[i];
      }
    }
    return finalresult;
  }

  static String username_search(String text) {
    //to get the username
    String result = "";
    for (int i = 0; i < text.length; i++) {
      if (text[i] == ":") {
        break;
      }
      result += text[i];
    }
    return result;
  }
}
