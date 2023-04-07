import '../dson_adapter.dart';

abstract class IParam<T> {
  T call(
    DSON dson,
    dynamic map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
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
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            constructor,
            inner: inner,
            resolvers: resolvers,
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
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            constructor,
            inner: inner,
            resolvers: resolvers,
          );
        })
        .toSet()
        .cast<T>();

    return typedList;
  }
}
