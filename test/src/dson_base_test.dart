import 'package:dson_adapter/dson_adapter.dart';
import 'package:test/test.dart';

void main() {
  late DSON dson;
  setUp(() {
    dson = const DSON();
  });

  test('fromJson convert map in Person', () {
    final jsonMap = {
      'id': 1,
      'name': 'Joshua Clak',
      'age': 3,
      'nickname': 'Josh',
    };

    final person = dson.fromJson<Person>(jsonMap, Person.new);
    expect(person.id, 1);
    expect(person.name, 'Joshua Clak');
    expect(person.age, 3);
    expect(person.nickname, 'Josh');
  });

  test('fromJson convert map in Person withless name', () {
    final jsonMap = {
      'id': 1,
      'age': 3,
    };

    final person = dson.fromJson(jsonMap, Person.new);
    expect(person.id, 1);
    expect(person.name, null);
    expect(person.age, 3);
  });

  test('fromJson convert map in Person withless age', () {
    final jsonMap = {
      'id': 1,
      'name': 'Joshua Clak',
    };

    final person = dson.fromJson(jsonMap, Person.new);
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

    final home = dson.fromJson(
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
    expect(
      () => dson.fromJson({}, (String name) {}, aliases: {}),
      throwsA(isA<ParamsNotAllowed>()),
    );
  });

  test('throws error if dont has non-nullable required param [id]', () {
    final jsonMap = {
      'name': 'Joshua Clak',
      'age': 3,
    };

    expect(
      () => dson.fromJson(jsonMap, Person.new),
      throwsA(isA<DSONException>()),
    );
  });

  test('fromJson convert map in Person with id alias to key', () {
    final jsonMap = {
      'key': 1,
      'name': 'Joshua Clak',
      'age': 3,
    };
    final person = dson.fromJson(
      jsonMap,
      Person.new,
      aliases: {
        Person: {'id': 'key'}
      },
    );
    expect(person.id, 1);
    expect(person.name, 'Joshua Clak');
    expect(person.age, 3);
  });

  test(
      'fromJson convert map in Person withless name when name '
      'has alias but alias no exist in map', () {
    final jsonMap = {
      'id': 1,
      'name': 'Joshua Clak',
      'age': 3,
    };

    final person = dson.fromJson(
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

  test('fromJson convert map in Home (inner object) when API modify most keys',
      () {
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

    final home = dson.fromJson(
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

  test(
      'throws error if dont has required param when '
      'use aliases in required param', () {
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

    final primitive = const DSON().fromJson<PrimitiveList>(
      json,
      PrimitiveList.new,
      aliases: {
        PrimitiveList: {'destinationAddresses': 'destination_addresses'},
      },
    );

    expect(primitive.destinationAddresses, list);
  });

  test(
      'fromJson should allow '
      'to have required and nullable parameters simultaneously', () {
    // arrange
    final jsonMap = {
      'id': 1,
      'age': 3,
    };

    // act
    final person = dson.fromJson<Person>(jsonMap, Person.new);

    // assert
    expect(person.age, 3); // not required and non-nullable
    expect(person.name, null); // not required and nullable
    expect(person.id, 1); // required and non-nullable
    expect(person.nickname, null); // required and nullable
  });

  test(
      'fromJson convert map in Person '
      'with required and nullable param nickname equal null', () {
    // arrange
    final jsonMap = {
      'id': 1,
      'age': 3,
      'name': 'Joshua Clak',
    };

    // act
    final person = dson.fromJson<Person>(jsonMap, Person.new);

    // assert
    expect(person.id, 1);
    expect(person.age, 3);
    expect(person.name, 'Joshua Clak');
    expect(person.nickname, 'Joshua Clak');
  });

  test(
      'Given a list [List<Object?>] is not nullable, '
      'When the converted json for this list is null, '
      'Then it should throw an exception of type [DSONException] '
      'instead of [TypeError]', () {
    // arrange
    final errorsSnapshotJson = {'errors': null};

    // act, assert
    expect(
      () => dson.fromJson<ErrorsSnapshot>(
        errorsSnapshotJson,
        ErrorsSnapshot.new,
      ),
      throwsA(
        predicate(
          (e) => e is DSONException && e is! TypeError,
        ),
      ),
    );
  });

  test(
      'Given id is a parameter of type int, '
      'When the json contains a value of type String, '
      'Then it should throw an exception of type [ParamInvalidType]', () {
    final jsonMap = {
      'id': '1',
      'name': 'Joshua Clak',
      'age': 3,
      'nickname': 'Josh',
    };

    expect(
      () => dson.fromJson(jsonMap, Person.new),
      throwsA(
        predicate(
          (e) =>
              e is ParamInvalidType &&
              e.functionParam.type == 'int' &&
              e.receivedType == 'String',
        ),
      ),
    );
  });

  test(
      'Given [key] is an alias of the parameter [id], '
      'And [id] is a parameter of type [int], '
      'When the json contains a value of type [String], '
      'Then it should throw an exception of type [ParamInvalidType]', () {
    final jsonMap = {
      'key': '1',
      'name': 'Joshua Clak',
      'age': 3,
      'nickname': 'Josh',
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Person.new,
        aliases: {
          Person: {'id': 'key'}
        },
      ),
      throwsA(
        predicate(
          (e) =>
              e is ParamInvalidType &&
              e.functionParam.type == 'int' &&
              e.receivedType == 'String' &&
              e.functionParam.alias == 'key',
        ),
      ),
    );
  });

  test(
      'Given [key] is an alias of the parameter [id], '
      'And [key] was not specified in the [aliases] property, '
      'And [key] is INCORRECTLY typed, '
      'When [dson.fromJson] is called, '
      'Then it should throw an exception of type [ParamNullNotAllowed]', () {
    final jsonMap = {
      'key': '1',
      'name': 'Joshua Clak',
      'age': 3,
      'nickname': 'Josh',
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Person.new,
      ),
      throwsA(isA<ParamNullNotAllowed>()),
    );
  });

  test(
      'Given [key] is an alias of the parameter [id], '
      'And [key] was not specified in the [aliases] property, '
      'And [key] is typed CORRECT, '
      'When [dson.fromJson] is called, '
      'Then it should throw an exception of type [ParamNullNotAllowed]', () {
    final jsonMap = {
      'key': 1,
      'name': 'Joshua Clak',
      'age': 3,
      'nickname': 'Josh',
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Person.new,
      ),
      throwsA(isA<ParamNullNotAllowed>()),
    );
  });

  test(
      'Given [key] is an alias of the parameter [id], '
      'And [key] is specified in the [aliases] property, '
      'And [key] value is null, '
      'When [dson.fromJson] is called, '
      'Then it should throw an exception of type [ParamNullNotAllowed]', () {
    final jsonMap = {
      'key': null,
      'name': 'Joshua Clak',
      'age': 3,
      'nickname': 'Josh',
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Person.new,
        aliases: {
          Person: {
            'id': 'key',
          }
        },
      ),
      throwsA(isA<ParamNullNotAllowed>()),
    );
  });

  test(
      'Given [key] is an alias of the parameter [id], '
      'And [key] is specified in the [aliases] property, '
      'And [key] is not present in the json, '
      'When [dson.fromJson] is called, '
      'Then it should throw an exception of type [ParamNullNotAllowed]', () {
    final jsonMap = {
      'name': 'Joshua Clak',
      'age': 3,
      'nickname': 'Josh',
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Person.new,
        aliases: {
          Person: {
            'id': 'key',
          }
        },
      ),
      throwsA(isA<ParamNullNotAllowed>()),
    );
  });

  test(
      'Since [parents] is a list of [Pearson], '
      'When the value of [parents] is a list of [List], '
      'Then it should throw an error [ParamUnknown] ', () {
    final jsonMap = {
      'id': 1,
      'name': 'MyHome',
      'owner': {
        'id': 1,
        'name': 'Joshua Clak',
        'age': 3,
      },
      'parents': [[]]
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Home.new,
        inner: {
          'owner': Person.new,
          'parents': ListParam<Person>(Person.new),
        },
      ),
      throwsA(
        predicate((e) => e is ParamUnknown && e.parentClass == 'Person'),
      ),
    );
  });

  test(
      'Since [parents] is a list of [Pearson], '
      'When the value of [parents] is a list of [String] '
      '(not iterable object), Then it should throw a [ParamInvalidType] error ',
      () {
    final jsonMap = {
      'id': 1,
      'name': 'MyHome',
      'owner': {
        'id': 1,
        'name': 'Joshua Clak',
        'age': 3,
      },
      'parents': ['']
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Home.new,
        inner: {
          'owner': Person.new,
          'parents': ListParam<Person>(Person.new),
        },
      ),
      throwsA(
        predicate(
          (e) =>
              e is ParamInvalidType &&
              e.parentClass == 'Person' &&
              e.receivedType == 'String' &&
              e.message ==
                  "Type not iterable 'String' is not a subtype of type "
                      "'Person'.",
        ),
      ),
    );
  });

  test(
      'Since [owner] is of type [Person], '
      'And has the alias [owner_alias] '
      'When the value of [owner] is a [String], '
      'Then it should throw a [ParamInvalidType] error', () {
    final jsonMap = {
      'id': 1,
      'name': 'MyHome',
      'owner_alias': '',
      'parents': [],
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Home.new,
        inner: {
          'owner': Person.new,
          'parents': ListParam<Person>(Person.new),
        },
        aliases: {
          Home: {
            'owner': 'owner_alias',
          },
        },
      ),
      throwsA(
        predicate(
          (e) =>
              e is ParamInvalidType &&
              e.parentClass == 'Home' &&
              e.receivedType == 'String' &&
              e.functionParam.type == 'Person' &&
              e.functionParam.alias == 'owner_alias' &&
              e.functionParam.name == 'owner',
        ),
      ),
    );
  });

  test(
      'Since home [name] is of type [String], '
      'When the value of [name] is a [_Map<String, Object>], '
      'Then it should throw a [ParamInvalidType] error', () {
    final jsonMap = {
      'id': 1,
      'name': {
        'id': 1,
        'name': 'Joshua Clak',
        'age': 3,
      },
      'owner': {
        'id': 2,
        'name': 'Father',
        'age': 4,
      },
      'parents': [],
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Home.new,
        inner: {
          'owner': Person.new,
          'parents': ListParam<Person>(Person.new),
        },
      ),
      throwsA(
        predicate(
          (e) =>
              e is ParamInvalidType &&
              e.parentClass == 'Home' &&
              (e.receivedType == '_Map<String, Object>' ||
                  e.receivedType == '_InternalLinkedHashMap<String, Object>') &&
              e.functionParam.type == 'String' &&
              e.functionParam.name == 'name',
        ),
      ),
    );
  });

  test(
      'Since home [name] is of type [String], '
      'When the value of [name] is a [List<Map<String, Object>>], '
      'And [name] has the alias [name_alias], '
      'Then it should throw a [ParamInvalidType] error', () {
    final jsonMap = {
      'id': 1,
      'name_alias': [
        {
          'id': 2,
          'name': 'Father',
          'age': 4,
        }
      ],
      'owner': {
        'id': 2,
        'name': 'Father',
        'age': 4,
      },
      'parents': [],
    };

    expect(
      () => dson.fromJson(
        jsonMap,
        Home.new,
        inner: {
          'owner': Person.new,
          'parents': ListParam<Person>(Person.new),
        },
        aliases: {
          Home: {
            'name': 'name_alias',
          },
        },
      ),
      throwsA(
        predicate(
          (e) =>
              e is ParamInvalidType &&
              e.parentClass == 'Home' &&
              e.receivedType == 'List<Map<String, Object>>' &&
              e.functionParam.type == 'String' &&
              e.functionParam.name == 'name' &&
              e.functionParam.alias == 'name_alias',
        ),
      ),
    );
  });
}

class Person {
  final int id;
  final String? name;
  final int age;
  final String? nickname;

  Person({
    required this.id,
    this.name,
    this.age = 20,
    required String? nickname,
  }) : nickname = nickname ?? name;

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
  final List<String> destinationAddresses;
  PrimitiveList({
    required this.destinationAddresses,
  });
}

class ErrorsSnapshot {
  final List<String?> errors;
  ErrorsSnapshot({required this.errors});
}
