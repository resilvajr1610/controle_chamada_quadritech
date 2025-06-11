import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ConverterDataModelo{

  String formatarTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

}