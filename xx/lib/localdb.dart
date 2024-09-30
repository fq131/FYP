import 'package:realm/realm.dart';
part 'localdb.g.dart';

@RealmModel()
class _Users {
  @PrimaryKey()
  @MapTo("_id")
  late String id;

  late String name;
  late String clockTime;
  late List<double> embeddings1;
}

class UserHelper {
  //define config obj
  final _config = Configuration.local([Users.schema]);
  static late Realm realm;

  //constructor to open database
  UserHelper() {
    openRealm();
  }

  //open database
  openRealm() {
    realm = Realm(_config);
  }

  //close database
  closeRealm() {
    if (realm.isClosed) {
      realm.close();
    }
  }

  //get user details
  Future<List<Map<String, dynamic>>> getAllUser() async {
    final RealmResults<Users> realmResults = realm.all<Users>();

    List<Map<String, dynamic>> listOfMaps = realmResults
        .map((user) => {
              'id': user.id,
              'name': user.name,
              'clockTime': user.clockTime,
              'embedding1': user.embeddings1,
            })
        .toList();
    return listOfMaps;
  }

  //get embedding1
  //get embedding1
  Future<List<List<double>>> getEmbedding1() async {
    final RealmResults<Users> getEmbedding = realm.all<Users>();

    // Simply map the user.embeddings1 list without wrapping it
    List<List<double>> listOfEmbedding = getEmbedding
        .map((user) => List<double>.from(user.embeddings1))
        .toList();

    return listOfEmbedding;
  }

  // add user - id, name, embedding
  Future<void> addUser(
    String id,
    String name,
    String clockTime,
    List<double> embeddings1,
  ) async {
    realm.write(() {
      return realm.add(Users(
        id,
        name,
        clockTime,
        embeddings1: embeddings1,
      ));
    });
  }

  Future<void> addClockTime(String id, String clockTime) async {
    final user = realm.find<Users>(id);
    if (user != null) {
      realm.write(() {
        user.clockTime = clockTime;
      });
    }
  }

  //delete user - id
  Future<void> deleteUser(String id) async {
    realm.write(() {
      final userdlt = realm.find<Users>(id);
      if (userdlt != null) {
        realm.delete(userdlt);
      }
    });
  }
}
