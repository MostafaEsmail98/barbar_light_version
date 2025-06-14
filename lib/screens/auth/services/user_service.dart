import 'package:frezka/screens/auth/model/user_data_model.dart';
import 'package:frezka/screens/auth/services/base_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/constants.dart';

class UserService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  UserService() {
    ref = fireStore.collection(USER_COLLECTION);
  }

  Future<UserData> getUser({String? key, String? email}) {
    return ref!.where(key ?? "email", isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserData.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw USER_NOT_FOUND;
      }
    });
  }

  Stream<List<UserData>> users({String? searchText}) {
    return ref!.where('caseSearch', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase()).snapshots().map((x) {
      return x.docs.map((y) {
        return UserData.fromJson(y.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<UserData> userByEmail(String? email) async {
    return await ref!.where('email', isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserData.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw locale.noUserFound;
      }
    });
  }

  Stream<UserData> singleUser(String? id, {String? searchText}) {
    return ref!.where('uid', isEqualTo: id).limit(1).snapshots().map((event) {
      return UserData.fromJson(event.docs.first.data() as Map<String, dynamic>);
    });
  }

  Future<UserData> userByMobileNumber(String? phone) async {
    log("Phone $phone");
    return await ref!.where('phoneNumber', isEqualTo: phone).limit(1).get().then(
          (value) {
        log(value);
        if (value.docs.isNotEmpty) {
          return UserData.fromJson(value.docs.first.data() as Map<String, dynamic>);
        } else {
          throw locale.noUserFound;
        }
      },
    );
  }

  Future<void> deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> isUserExistWithUid(String? uid) async {
    Query query = ref!.limit(1).where('uid', isEqualTo: uid);
    var res = await query.get();

    return res.docs.isNotEmpty;
  }

}
