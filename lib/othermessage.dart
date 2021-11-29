import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:tcp/ownmessage.dart';
import 'package:tcp/ownmessage.dart';

class OtherMessage extends StatelessWidget {
  OtherMessage({Key? key, required this.message}) : super(key: key);

  String message;

  @override
  Widget build(BuildContext context) {
    List<String> messagesplit = OwnMessage.splitmessage(message);
    String username = OwnMessage.username_search(messagesplit[0]);
    String withoutusername = OwnMessage.messagewithoutusername(messagesplit);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(username,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                )),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
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
}
