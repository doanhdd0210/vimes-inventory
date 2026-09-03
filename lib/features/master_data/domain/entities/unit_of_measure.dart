import '../../../../core/domain/entity.dart';

/// Đơn vị tính (cột D): cái, kg, mét, thùng…
class UnitOfMeasure extends Entity {
  const UnitOfMeasure({
    required this.id,
    required this.code,
    required this.name,
  });

  @override
  final String id;
  final String code;
  final String name;

  UnitOfMeasure copyWith({String? id, String? code, String? name}) =>
      UnitOfMeasure(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
      );

  @override
  List<Object?> get props => [id, code, name];
}
