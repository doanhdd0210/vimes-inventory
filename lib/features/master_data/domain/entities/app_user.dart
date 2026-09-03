import '../../../../core/domain/entity.dart';

enum UserRole {
  admin,
  warehouseKeeper,
  accountant,
  staff,
  viewer;

  static UserRole fromName(String? name) => UserRole.values.firstWhere(
    (r) => r.name == name,
    orElse: () => UserRole.staff,
  );

  String get label => switch (this) {
    UserRole.admin => 'Quản trị',
    UserRole.warehouseKeeper => 'Thủ kho',
    UserRole.accountant => 'Kế toán',
    UserRole.staff => 'Nhân viên',
    UserRole.viewer => 'Chỉ xem',
  };
}

/// Tài khoản / nhân sự. Là người giao, người lập phiếu, thủ kho, kế toán trưởng.
/// Khi dùng Firebase, [id] = Firebase Auth UID và không có mật khẩu ở đây.
class AppUser extends Entity {
  const AppUser({
    required this.id,
    required this.organizationId,
    required this.username,
    required this.fullName,
    this.departmentId,
    this.email,
    this.position,
    this.role = UserRole.staff,
    this.isActive = true,
  });

  @override
  final String id;
  final String organizationId;
  final String? departmentId;
  final String username;
  final String? email;
  final String fullName;
  final String? position;
  final UserRole role;
  final bool isActive;

  AppUser copyWith({
    String? id,
    String? organizationId,
    String? departmentId,
    String? username,
    String? email,
    String? fullName,
    String? position,
    UserRole? role,
    bool? isActive,
  }) => AppUser(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    departmentId: departmentId ?? this.departmentId,
    username: username ?? this.username,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    position: position ?? this.position,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    id,
    organizationId,
    departmentId,
    username,
    email,
    fullName,
    position,
    role,
    isActive,
  ];
}
