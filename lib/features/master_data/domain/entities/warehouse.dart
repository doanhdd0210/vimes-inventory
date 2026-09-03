import '../../../../core/domain/entity.dart';

/// Kho — "Nhập tại kho … địa điểm".
class Warehouse extends Entity {
  const Warehouse({
    required this.id,
    required this.organizationId,
    required this.code,
    required this.name,
    this.location,
    this.keeperUserId,
    this.isActive = true,
  });

  @override
  final String id;
  final String organizationId;
  final String code;
  final String name;
  final String? location;
  final String? keeperUserId;
  final bool isActive;

  Warehouse copyWith({
    String? id,
    String? organizationId,
    String? code,
    String? name,
    String? location,
    String? keeperUserId,
    bool? isActive,
  }) => Warehouse(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    code: code ?? this.code,
    name: name ?? this.name,
    location: location ?? this.location,
    keeperUserId: keeperUserId ?? this.keeperUserId,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    id,
    organizationId,
    code,
    name,
    location,
    keeperUserId,
    isActive,
  ];
}
