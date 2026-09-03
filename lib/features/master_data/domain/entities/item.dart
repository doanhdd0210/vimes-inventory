import '../../../../core/domain/entity.dart';

/// Sản phẩm / vật tư, hàng hoá. Cột B (tên/quy cách), cột C (mã số), cột D
/// (đơn vị tính gốc = [uomId]).
class Item extends Entity {
  const Item({
    required this.id,
    required this.code,
    required this.name,
    required this.uomId,
    this.specification,
    this.categoryId,
    this.defaultUnitPrice,
    this.minStock,
    this.isActive = true,
  });

  @override
  final String id;
  final String code;
  final String name;
  final String uomId;
  final String? specification;
  final String? categoryId;
  final num? defaultUnitPrice;
  final num? minStock;
  final bool isActive;

  Item copyWith({
    String? id,
    String? code,
    String? name,
    String? uomId,
    String? specification,
    String? categoryId,
    num? defaultUnitPrice,
    num? minStock,
    bool? isActive,
  }) => Item(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    uomId: uomId ?? this.uomId,
    specification: specification ?? this.specification,
    categoryId: categoryId ?? this.categoryId,
    defaultUnitPrice: defaultUnitPrice ?? this.defaultUnitPrice,
    minStock: minStock ?? this.minStock,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    uomId,
    specification,
    categoryId,
    defaultUnitPrice,
    minStock,
    isActive,
  ];
}
