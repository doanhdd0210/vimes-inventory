import '../../../../core/domain/entity.dart';

/// Nhóm sản phẩm / vật tư (cây qua [parentId]).
class ItemCategory extends Entity {
  const ItemCategory({
    required this.id,
    required this.code,
    required this.name,
    this.parentId,
    this.isActive = true,
  });

  @override
  final String id;
  final String code;
  final String name;
  final String? parentId;
  final bool isActive;

  ItemCategory copyWith({
    String? id,
    String? code,
    String? name,
    String? parentId,
    bool? isActive,
  }) => ItemCategory(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    parentId: parentId ?? this.parentId,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [id, code, name, parentId, isActive];
}
