import '../dson_adapter.dart';

abstract class IParam<T> {
  T call(
    DSON dson,
    dynamic map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
    Map<Type, Map<String, String>> aliases,
  );
}

class ListParam<T> implements IParam<List<T>> {
  final Function constructor;

  ListParam(this.constructor);

  @override
  List<T> call(
    DSON dson,
    covariant List map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
    Map<Type, Map<String, String>> aliases,
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            constructor,
            inner: inner,
            resolvers: resolvers,
            aliases: aliases,
          );
        })
        .toList()
        .cast<T>();

    return typedList;
  }
}

class SetParam<T> implements IParam<Set<T>> {
  final Function constructor;

  SetParam(this.constructor);

  @override
  Set<T> call(
    DSON dson,
    covariant List map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
    Map<Type, Map<String, String>> aliases,
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            constructor,
            inner: inner,
            resolvers: resolvers,
            aliases: aliases,
          );
        })
        .toSet()
        .cast<T>();

    return typedList;
  }
}
