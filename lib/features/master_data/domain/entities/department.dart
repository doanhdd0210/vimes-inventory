import '../../../../core/domain/entity.dart';

/// Bộ phận — dòng "Bộ phận:" trên phiếu. Thuộc một [Organization], có thể lồng
/// cây qua [parentId].
class Department extends Entity {
  const Department({
    required this.id,
    required this.organizationId,
    required this.code,
    required this.name,
    this.parentId,
    this.isActive = true,
  });

  @override
  final String id;
  final String organizationId;
  final String code;
  final String name;
  final String? parentId;
  final bool isActive;

  Department copyWith({
    String? id,
    String? organizationId,
    String? code,
    String? name,
    String? parentId,
    bool? isActive,
  }) => Department(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    code: code ?? this.code,
    name: name ?? this.name,
    parentId: parentId ?? this.parentId,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    id,
    organizationId,
    code,
    name,
    parentId,
    isActive,
  ];
}
