import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';

class ChatServices {
  prepMessage(String message, String uid, String chatId) async {
    Map<String, dynamic> messageObject = {
      "message": message,
      "sentBy": uid,
      "type": "text",
      "timeStamp": DateTime.now().millisecondsSinceEpoch
    };
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection(chatId)
        .add(messageObject);
    return true;
  }

  Future<bool> setChatId(
    UserModel currentUserModel,
    UserModel otherUserModel,
    DocumentModel item,
  ) async {
    String chatId = otherUserModel.uid + currentUserModel.uid;
    try {
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(currentUserModel.uid)
          .collection('ChatIds')
          .doc(chatId)
          .set({
        'item': item.toJson(),
        'chatId': chatId,
        'peerUserModel': {
          'uid': otherUserModel.uid,
          'name': otherUserModel.name,
          'photoUrl': otherUserModel.photoURL
        }
      });
      await FirebaseFirestore.instance
          .collection('userData')
          .doc(otherUserModel.uid)
          .collection('ChatIds')
          .doc(chatId)
          .set({
        'item': item.toJson(),
        'chatId': chatId,
        'peerUserModel': {
          'uid': currentUserModel.uid,
          'name': currentUserModel.name,
          'photoUrl': currentUserModel.photoURL
        }
      });
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInbox(String currentUid) {
    Stream<QuerySnapshot<Map<String, dynamic>>> inbox = FirebaseFirestore
        .instance
        .collection('userData')
        .doc(currentUid)
        .collection('ChatIds')
        .snapshots();
    return inbox;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChats(
      String chatId, int limit) {
    Stream<QuerySnapshot<Map<String, dynamic>>> chats = FirebaseFirestore
        .instance
        .collection('Chats')
        .doc(chatId)
        .collection(chatId)
        .limit(limit)
        .orderBy('timeStamp', descending: true)
        .snapshots();

    return chats;
  }

  Future changeReadFlags(String uid, String chatId, bool value) async {
    if (uid.isNotEmpty)
      try {
        await FirebaseFirestore.instance
            .collection(userData)
            .doc(uid)
            .collection('ChatIds')
            .doc(chatId)
            .update({'read': value});
      } catch (e) {
        print(e.code);
      }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> readChatFlag(
      String uid, String chatId) {
    return FirebaseFirestore.instance
        .collection(userData)
        .doc(uid)
        .collection('ChatIds')
        .doc(chatId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUnreadNumber(String uid) {
    return FirebaseFirestore.instance
        .collection(userData)
        .doc(uid)
        .collection('ChatIds')
        .limit(10)
        .snapshots();
  }
}
