import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Utils/locator.dart';
import '../auth_service.dart';
import 'package:dox/Helpers/constants.dart';

class FirebaseServices {
  UserModel user = locator<AuthService>().getCurrentUser();

  Future<QuerySnapshot<Map<String, dynamic>>> getItemsByUid(
      String uid, int limit) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection(allItems)
        .where('user.uid', isEqualTo: uid)
        .get();
    return result;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTrending(int limit) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection(allItems)
        //   .where('user.uid', isNotEqualTo: user.uid)
        .limit(limit)
        .orderBy('dateSubmitted', descending: true)
        .get();
    return result;
  }

  // Future<QuerySnapshot> getRangeItems(int limit, int upperLimit) async {
  //   QuerySnapshot result = await FirebaseFirestore.instance
  //       .collection(allItems)
  //       .where('price', isLesserThan: upperLimit)
  //       .limit(limit)
  //       // .orderBy('dateSubmitted', descending: true)
  //       .get();
  //   return result;
  // }

  Future<bool> submitBug(UserModel user, String bugText) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bug Reports')
          .add({'Description': bugText});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getitemsByCategory(
      String category, int limit) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection(allItems)
        .where('category', isEqualTo: category.toUpperCase())
        .limit(10)
        .get();
    return result;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> searchResults(
      String keyword) async {
    List<DocumentSnapshot<Map<String, dynamic>>> results = [];
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('ItemList')
        .doc('ItemList')
        .get();

    Map<String, dynamic> data = result.data();

    await Future.forEach<MapEntry<String, dynamic>>(data.entries,
        (element) async {
      String uid = element.value['uid'] ?? '';
      if (uid != user.uid) {
        String title = element.value['title'];
        if (title.contains(keyword)) {
          if (results.length < 10) {
            String docId = element.key;
            DocumentSnapshot doc = await getItemsFromdocId(docId);
            if (doc.exists) {
              results.add(doc);
            }
          }
        }
      }
    });

    return results;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getFavorites(
      int limit, Map<String, dynamic> map) async {
    List<DocumentSnapshot<Map<String, dynamic>>> docs = [];
    List itemIds = map['itemId'];
    if ((itemIds?.length ?? 0) > 0) {
      await Future.forEach(itemIds, (docId) async {
        if (docs.length < limit) {
          DocumentSnapshot<Map<String, dynamic>> temp =
              await getItemsFromdocId(docId);
          if (temp.exists) {
            docs.add(temp);
          }
        }
      });
    }
    return docs;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getItemsFromdocId(
      String docId) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection(allItems).doc(docId).get();
    return doc;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserItems(
      String uid, int limit) {
    Future<QuerySnapshot> doc = FirebaseFirestore.instance
        .collection(userData)
        .doc(uid)
        .collection(items)
        .get();
    return doc;
  }

  Future<bool> setFavorite(DocumentModel item) async {
    List itemId = [item.id];

    try {
      await FirebaseFirestore.instance
          .collection(userData)
          .doc(user.uid)
          .collection(favIds)
          .doc(favIds)
          .update({'itemId': FieldValue.arrayUnion(itemId)});
      return true;
    } catch (e) {
      //if it doesnt exist, create field 'itemId'
      await FirebaseFirestore.instance
          .collection(userData)
          .doc(user.uid)
          .collection(favIds)
          .doc(favIds)
          .set({'itemId': FieldValue.arrayUnion(itemId)});
      return false;
    }
  }

  Future<bool> removeFavorite(DocumentModel item) async {
    List itemId = [item.id];
    try {
      await FirebaseFirestore.instance
          .collection(userData)
          .doc(user.uid)
          .collection(favIds)
          .doc(favIds)
          .update({'itemId': FieldValue.arrayRemove(itemId)});
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getLikes(String uid) {
    if (uid != null) {
      Stream<DocumentSnapshot> stream = FirebaseFirestore.instance
          .collection(userData)
          .doc(user.uid)
          .collection(favIds)
          .doc(favIds)
          .snapshots();
      return stream;
    }
    return null;
  }

  Future<bool> disableAd(DocumentModel item) async {
    try {
      await FirebaseFirestore.instance
          .collection(allItems)
          .doc(item.id)
          .delete();
      await FirebaseFirestore.instance
          .collection(userData)
          .doc(user.uid)
          .collection(items)
          .doc(item.id)
          .update({'status': 'inactive'});
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> enableAd(DocumentModel item) async {
    try {
      await FirebaseFirestore.instance
          .collection(allItems)
          .doc(item.id)
          .set(item.toJson());
      await FirebaseFirestore.instance
          .collection(userData)
          .doc(user.uid)
          .collection(items)
          .doc(item.id)
          .update({'status': 'active'});
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> submitReview(
    UserModel reviewer,
    String uid,
    int rating,
    String reviewText,
  ) async {
    Map<String, dynamic> map = {
      'userModel': reviewer.toJson(),
      'rating': rating,
      'review': reviewText,
      'timeStamp': DateTime.now().millisecondsSinceEpoch
    };
    try {
      await FirebaseFirestore.instance
          .collection(userData)
          .doc(uid)
          .collection(reviews)
          .doc(reviews)
          .update(
        {reviewer.uid: map},
      );
      return true;
    } catch (e) {
      if (e.code == 'not-found') {
        try {
          await FirebaseFirestore.instance
              .collection(userData)
              .doc(uid)
              .collection(reviews)
              .doc(reviews)
              .set(
            {reviewer.uid: map},
          );
          return true;
        } catch (e) {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getReviews(String uid) async {
    return await FirebaseFirestore.instance
        .collection(userData)
        .doc(uid)
        .collection(reviews)
        .doc(reviews)
        .get();
  }

  Future<bool> bookItem(DocumentModel item, String name) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(item.id)
          .collection(item.id)
          .doc(item.id)
          .update({user.uid: user.toJson()});

      return true;
    } catch (e) {
      if (e.code == 'not-found') {
        try {
          await FirebaseFirestore.instance
              .collection('Bookings')
              .doc(item.id)
              .collection(item.id)
              .doc(item.id)
              .set({user.uid: user.toJson()});

          return true;
        } catch (e) {
          return false;
        }
      } else {
        return false;
      }
    }
  }

  Future<bool> unBookItem(DocumentModel item, UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(item.id)
          .collection(item.id)
          .doc(item.id)
          .update({user.uid: FieldValue.delete()});
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getBookings(String itemId) {
    return FirebaseFirestore.instance
        .collection('Bookings')
        .doc(itemId)
        .collection(itemId)
        .doc(itemId)
        .snapshots();
  }

  Future<bool> submitReport(
      String id, String category, String description) async {
    try {
      await FirebaseFirestore.instance.collection('Reported Items').add(
          {'Category': category, 'Description': description, 'itemId': id});
      return true;
    } catch (e) {
      return false;
    }
  }
}
