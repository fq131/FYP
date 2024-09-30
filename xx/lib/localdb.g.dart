// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localdb.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Users extends _Users with RealmEntity, RealmObjectBase, RealmObject {
  Users(
    String id,
    String name,
    String clockTime, {
    Iterable<double> embeddings1 = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'clockTime', clockTime);
    RealmObjectBase.set<RealmList<double>>(
        this, 'embeddings1', RealmList<double>(embeddings1));
  }

  Users._();

  @override
  String get id => RealmObjectBase.get<String>(this, '_id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get clockTime =>
      RealmObjectBase.get<String>(this, 'clockTime') as String;
  @override
  set clockTime(String value) => RealmObjectBase.set(this, 'clockTime', value);

  @override
  RealmList<double> get embeddings1 =>
      RealmObjectBase.get<double>(this, 'embeddings1') as RealmList<double>;
  @override
  set embeddings1(covariant RealmList<double> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Users>> get changes =>
      RealmObjectBase.getChanges<Users>(this);

  @override
  Users freeze() => RealmObjectBase.freezeObject<Users>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Users._);
    return const SchemaObject(ObjectType.realmObject, Users, 'Users', [
      SchemaProperty('id', RealmPropertyType.string,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('clockTime', RealmPropertyType.string),
      SchemaProperty('embeddings1', RealmPropertyType.double,
          collectionType: RealmCollectionType.list),
    ]);
  }
}
