# DSON

Convert JSON to Dart Class withless code generate(build_runner)

## IN DEVELOPMENT

Don't use in production!!

## Example

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
        'parents': Person.new,
      },
      // cast List, Set and Map to
      // specific type,
      resolvers: [
        listResolver<Person>('parents'),
      ],
    );

    print(home);
}

```

## Resolvers

To work with collections **(List, Map)** it will be necessary 
to declare a resolver to help with the cast.
There are some default resolvers but you can create your own resolvers too.

default resolvers:
`- listResolver<T>('key-string')`
`- mapResolver<TKey, TValue>('key-string')`