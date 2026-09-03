import '../../../../core/domain/entity.dart';

/// Đơn vị (pháp nhân / công ty) — dòng "Đơn vị:" trên phiếu.
class Organization extends Entity {
  const Organization({
    required this.id,
    required this.code,
    required this.name,
    this.taxCode,
    this.address,
    this.phone,
    this.isActive = true,
  });

  @override
  final String id;
  final String code;
  final String name;
  final String? taxCode;
  final String? address;
  final String? phone;
  final bool isActive;

  Organization copyWith({
    String? id,
    String? code,
    String? name,
    String? taxCode,
    String? address,
    String? phone,
    bool? isActive,
  }) => Organization(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    taxCode: taxCode ?? this.taxCode,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    taxCode,
    address,
    phone,
    isActive,
  ];
}
