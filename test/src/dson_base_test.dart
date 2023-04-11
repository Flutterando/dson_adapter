import 'package:dson_adapter/dson_adapter.dart';
import 'package:test/test.dart';

void main() {
  late DSON dson;
  setUp(() {
    dson = DSON();
  });

  test('fromJson convert map in Person', () {
    final jsonMap = {
      'id': 1,
      'name': 'Joshua Clak',
      'age': 3,
    };

    Person person = dson.fromJson(jsonMap, Person.new);
    expect(person.id, 1);
    expect(person.name, 'Joshua Clak');
    expect(person.age, 3);
  });

  test('fromJson convert map in Person withless name', () {
    final jsonMap = {
      'id': 1,
      'age': 3,
    };

    Person person = dson.fromJson(jsonMap, Person.new);
    expect(person.id, 1);
    expect(person.name, null);
    expect(person.age, 3);
  });

  test('fromJson convert map in Person withless age', () {
    final jsonMap = {
      'id': 1,
      'name': 'Joshua Clak',
    };

    Person person = dson.fromJson(jsonMap, Person.new);
    expect(person.id, 1);
    expect(person.name, 'Joshua Clak');
    expect(person.age, 20);
  });

  test('fromJson convert map in Home (inner object)', () {
    final jsonMap = {
      'id': 1,
      'name': 'MyHome',
      'owner': {
        'id': 1,
        'name': 'Joshua Clak',
        'age': 3,
      },
      'parents': [
        {
          'id': 2,
          'name': 'Kepper Vidal',
          'age': 25,
        },
        {
          'id': 3,
          'name': 'Douglas Bisserra',
          'age': 23,
        },
      ],
    };

    Home home = dson.fromJson(
      // json Map or List
      jsonMap,
      // Main constructor
      Home.new,
      // external types
      inner: {
        'owner': Person.new,
        'parents': ListParam<Person>(Person.new),
      },
    );

    expect(home.id, 1);
    expect(home.name, 'MyHome');
    expect(home.owner, isA<Person>());
    expect(home.owner.id, 1);
    expect(home.owner.name, 'Joshua Clak');
    expect(home.owner.age, 3);

    expect(home.parents[0].id, 2);
    expect(home.parents[0].name, 'Kepper Vidal');
    expect(home.parents[0].age, 25);

    expect(home.parents[1].id, 3);
    expect(home.parents[1].name, 'Douglas Bisserra');
    expect(home.parents[1].age, 23);
  });

  test('fromJson works only named params constructor', () {
    expect(() => dson.fromJson({}, (String name) {}, aliases: {}), throwsA(isA<ParamsNotAllowed>()));
  });

  test('throws error if dont has required param', () {
    final jsonMap = {
      'name': 'Joshua Clak',
      'age': 3,
    };

    expect(() => dson.fromJson(jsonMap, Person.new), throwsA(isA<DSONException>()));
  });

  test('fromJson convert map in Person with id alias to key', () {
    final jsonMap = {
      'key': 1,
      'name': 'Joshua Clak',
      'age': 3,
    };
    Person person = dson.fromJson(jsonMap, Person.new, aliases: {
      Person: {'id': 'key'}
    });
    expect(person.id, 1);
    expect(person.name, 'Joshua Clak');
    expect(person.age, 3);
  });

  test('fromJson convert map in Person withless name when name has alias but alias no exist in map', () {
    final jsonMap = {
      'id': 1,
      'name': 'Joshua Clak',
      'age': 3,
    };

    Person person = dson.fromJson(
      jsonMap,
      Person.new,
      aliases: {
        Person: {'name': 'othername'}
      },
    );
    expect(person.id, 1);
    expect(person.name, null);
    expect(person.age, 3);
  });

  test('fromJson convert map in Home (inner object) when API modify most keys', () {
    final jsonMap = {
      'id': 1,
      'name': 'MyHome',
      'master': {
        'key': 1,
        'name': 'Joshua Clak',
        'age': 3,
      },
      'parents': [
        {
          'key': 2,
          'name': 'Kepper Vidal',
          'age': 25,
        },
        {
          'key': 3,
          'name': 'Douglas Bisserra',
          'age': 23,
        },
      ],
    };

    Home home = dson.fromJson(
      // json Map or List
      jsonMap,
      // Main constructor
      Home.new,
      // external types
      inner: {
        'owner': Person.new,
        'parents': ListParam<Person>(Person.new),
      },
      // Param names Object <-> Param name in API
      aliases: {
        Home: {'owner': 'master'},
        Person: {'id': 'key'}
      },
    );

    expect(home.id, 1);
    expect(home.name, 'MyHome');
    expect(home.owner, isA<Person>());
    expect(home.owner.id, 1);
    expect(home.owner.name, 'Joshua Clak');
    expect(home.owner.age, 3);

    expect(home.parents[0].id, 2);
    expect(home.parents[0].name, 'Kepper Vidal');
    expect(home.parents[0].age, 25);

    expect(home.parents[1].id, 3);
    expect(home.parents[1].name, 'Douglas Bisserra');
    expect(home.parents[1].age, 23);
  });

  test('throws error if dont has required param when use aliases in required param', () {
    final jsonMap = {
      'id': 2,
      'name': 'Kepper Vidal',
      'age': 25,
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Person.new,
        aliases: {
          Person: {'id': 'key'}
        },
      ),
      throwsA(isA<DSONException>()),
    );
  });

  test('Convert List with primitive type', () {
    final list = ['Philadelphia, PA, USA'];

    final json = {
      'destination_addresses': list,
    };

    final primitive = DSON().fromJson<PrimitiveList>(
      json,
      PrimitiveList.new,
    );

    expect(primitive.destination_addresses, list);
  });
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

  @override
  String toString() => 'PersonModel(id: $id, name: $name, age: $age)';
}

class Home {
  final int id;
  final String name;
  final Person owner;
  final List<Person> parents;

  Home({
    required this.id,
    required this.name,
    required this.owner,
    required this.parents,
  });
}

class PrimitiveList {
  final List<String> destination_addresses;
  PrimitiveList({
    required this.destination_addresses,
  });
}
