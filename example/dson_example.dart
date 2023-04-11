// ignore_for_file: avoid_print

import 'package:dson_adapter/dson_adapter.dart';

void main() {
  final jsondata = {
    'id': 1,
    'name': 'Jacob',
    'age': 1,
  };

  final person = const DSON().fromJson<Person>(jsondata, Person.new);
  print(person.age);
}

class Person {
  final int id;
  final String? name;
  final int age;

  Person({
    required this.id,
    this.name,
    this.age = 20,
  });
}
