import 'package:dson_adapter/dson_adapter.dart';

void main() {
  final jsondata = {
    'id': 1,
    'name': 'Jacob',
    'age': 1,
  };

  final person = DSON().fromJson<Person>(jsondata, Person.new);
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

class Test {
  final List<String> destination_addresses;
  Test({
    required this.destination_addresses,
  });
}
