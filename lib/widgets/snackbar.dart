import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String mensagem, Color cor){

  final snackbar = SnackBar(
      backgroundColor: cor,
      duration: Duration(milliseconds: 500),
      content: Row(
        children: [
          Icon(Icons.info_outline,color: Colors.white,),
          SizedBox(width: 20,),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white
              ),
            )
          )
        ],
      )
  );

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}