import 'package:equatable/equatable.dart';

/// Base for anything persisted with a string id. Enables the generic
/// [CrudDataSource] / [CrudRepository] to work without `dynamic`.
abstract class Entity extends Equatable {
  const Entity();

  String get id;
}
