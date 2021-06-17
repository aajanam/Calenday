import 'package:flutter/material.dart';
import 'package:jadwalku/model/discussion.dart';
import 'package:jadwalku/services/firestore_service.dart';

class DiscussionProvider with ChangeNotifier {
  final firestoreService = FireStore();

  String _messageId;
  List _message;


  String get messageId => _messageId;
  List get message => _message;
  Stream<List<Discussion>> get messageList => firestoreService.getDiscussion();



  set changeMessageId(String messageId) {
    _messageId = messageId;
    notifyListeners();
  }

  set changeMessage(List message) {
    _message = message;
    notifyListeners();
  }


  loadAll(Discussion discussion) async {
    if (discussion != null) {

      _messageId = discussion.messageId;
      _message = discussion.message;

    } else {
      _messageId = null;
      _message = null;
    }
  }

  saveMessage() {
    if (_messageId == null) {
      //Add
      var newMessage = Discussion(

          message: _message,
          messageId: _messageId);
      firestoreService.postMessage(newMessage, messageId);
    }
    else{
        var editMessage = Discussion(
            message: _message,
            messageId: _messageId);
          firestoreService.postMessage(editMessage, messageId);
        }
    }
  removeMessage(String messageId) {
    firestoreService.removeMessage(messageId);
  }
}
