# DSON

Convert JSON to Dart Class withless code generate(build_runner)

## A simple Object

```dart
class Person {
  final int id;
  final String name;
  final int age;

  Person({
    required this.id,
    required this.name,
    required this.age,
  });
}
```

Convert json to Object:

```dart
main(){
     final jsonMap = {
      'id': 1,
      'name': 'Joshua Clak',
      'age': 3,
    };

    Person person = dson.fromJson(jsonMap, Person.new);

    print(person.id);
    print(person.name);
    print(person.age);
}


```

## A complex object:

For complex objects it is necessary to declare the constructor in the `inner` property;

```dart
main(){
    final jsonMap = {
      'id': 1,
      'name': 'MyHome',
      'owner': {
        'id': 1,
        'name': 'Joshua Clak',
        'age': 3,
      },
    };

    Person person = dson.fromJson(
      jsonMap,
      Person.new,
      inner: {
        'owner':  Person.new,
      }
    );

    print(person);
}

```

## A complex object with List:

For work with a list, it is necessary to declare the constructor in the `inner` property and declare
the list resolver in the `resolvers` property.

```dart
main(){
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

    print(home);
}

```

DSON Have `ListParam` and `SetParam` for collection.

## When API replace Param Name:

You need to declare within the paramNameReplace map the object type that has changed in the key, and in the value, a map with the old key as the key and the new key as the value.

```dart
main(){
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
      paramNameReplace: {
        Home: {'owner': 'master'},
        Person: {'id': 'key'}
      }
    );

    print(home);
}

```
