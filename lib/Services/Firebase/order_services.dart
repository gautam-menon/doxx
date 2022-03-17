import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dox/Models/item_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class OrderServices {
  String generateItemId(String uid) {
    String time = DateTime.now().toString().replaceAll('.', '');
    String itemId = uid + time;
    return itemId;
  }

  Future uploadItem(DocumentModel item, List<File> images) async {
    List<String> imageUrls = await uploadImages(images, item.user.uid);
    if (imageUrls.length == 0) {
      throw ({'error': 'code 101'});
    }
    item.imageUrl = imageUrls;
    item.id = generateItemId(item.user.uid);
    Map<String, dynamic> itemJson = item.toJson();
    try {
      await FirebaseFirestore.instance
          .collection('AllItems')
          .doc(item.id)
          .set(itemJson);

      await FirebaseFirestore.instance
          .collection('userData')
          .doc(item.user.uid)
          .collection('Items')
          .doc(item.id)
          .set(itemJson);
    } catch (e) {
      return {"error": '$e code: 102'};
    }
    return true;
  }

  Future<List<String>> uploadImages(List<File> _imageFile, String uid) async {
    List<String> _urllist = [];
    try {
      await Future.forEach(_imageFile, (image) async {
        final String url = await uploadImage(image, uid);
        _urllist.add(url);
      });
    } catch (e) {
      print(e);
    }
    return _urllist;
  }

  Future<String> uploadImage(File image, String uid) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}$uid';
    final FirebaseStorage storage = FirebaseStorage.instance;

    final storageReference = storage.ref().child('Documents').child(fileName);
    UploadTask _uploadTask = storageReference.putFile(image);

    String url;
    await _uploadTask.whenComplete(
        () async => url = await storageReference.getDownloadURL());
    return url;
  }

  Future uploadEditedItem(
    DocumentModel item,
  ) async {
    Map<String, dynamic> itemJson = item.toJson();
    try {
      await FirebaseFirestore.instance
          .collection('AllItems')
          .doc(item.id)
          .set(itemJson);

      await FirebaseFirestore.instance
          .collection('userData')
          .doc(item.user.uid)
          .collection('Items')
          .doc(item.id)
          .set(itemJson);
    } catch (e) {
      return {"error": '$e code: 102'};
    }
    return true;
  }
}
