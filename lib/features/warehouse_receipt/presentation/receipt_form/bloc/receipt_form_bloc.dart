import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/domain/crud_repository.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/extensions/iterable_extensions.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../../../master_data/domain/entities/app_user.dart';
import '../../../../master_data/domain/entities/department.dart';
import '../../../../master_data/domain/entities/item.dart';
import '../../../../master_data/domain/entities/organization.dart';
import '../../../../master_data/domain/entities/unit_of_measure.dart';
import '../../../../master_data/domain/entities/warehouse.dart';
import '../../../domain/usecases/create_warehouse_receipt.dart';
import '../../../domain/usecases/warehouse_receipt_rules.dart';
import 'receipt_form_data.dart';
import 'receipt_form_options.dart';

part 'receipt_form_event.dart';
part 'receipt_form_state.dart';

/// ViewModel for the goods-receipt entry form. Loads master data for the
/// dropdowns, holds the [ReceiptFormData] draft with per-field [errors], and
/// submits through [CreateWarehouseReceipt].
class ReceiptFormBloc extends Bloc<ReceiptFormEvent, ReceiptFormState> {
  ReceiptFormBloc({
    required CreateWarehouseReceipt createWarehouseReceipt,
    required AuthRepository auth,
    required CrudRepository<Organization> organizations,
    required CrudRepository<Department> departments,
    required CrudRepository<Warehouse> warehouses,
    required CrudRepository<AppUser> users,
    required CrudRepository<Item> items,
    required CrudRepository<UnitOfMeasure> uoms,
  }) : _createWarehouseReceipt = createWarehouseReceipt,
       _auth = auth,
       _organizations = organizations,
       _departments = departments,
       _warehouses = warehouses,
       _users = users,
       _items = items,
       _uoms = uoms,
       super(const ReceiptFormState(data: ReceiptFormData())) {
    on<ReceiptFormStarted>(_onStarted);
    on<ReceiptHeaderChanged>(_onHeaderChanged);
    on<ReceiptItemAdded>(_onItemAdded);
    on<ReceiptItemRemoved>(_onItemRemoved);
    on<ReceiptItemChanged>(_onItemChanged);
    on<ReceiptStepRequested>(_onStepRequested);
    on<ReceiptSubmitted>(_onSubmitted);
  }

  final CreateWarehouseReceipt _createWarehouseReceipt;
  final AuthRepository _auth;
  final CrudRepository<Organization> _organizations;
  final CrudRepository<Department> _departments;
  final CrudRepository<Warehouse> _warehouses;
  final CrudRepository<AppUser> _users;
  final CrudRepository<Item> _items;
  final CrudRepository<UnitOfMeasure> _uoms;

  var _rowSeq = 0;
  String _nextRowId() => 'row-${++_rowSeq}';

  Future<void> _onStarted(
    ReceiptFormStarted event,
    Emitter<ReceiptFormState> emit,
  ) async {
    emit(state.copyWith(status: ReceiptFormStatus.loading));

    final orgs = await _organizations.getAll();
    final depts = await _departments.getAll();
    final whs = await _warehouses.getAll();
    final users = await _users.getAll();
    final items = await _items.getAll();
    final uoms = await _uoms.getAll();

    for (final r in [orgs, depts, whs, users, items, uoms]) {
      final failure = r.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) {
        emit(
          state.copyWith(
            status: ReceiptFormStatus.failure,
            submitError: failure.message,
          ),
        );
        return;
      }
    }

    final options = ReceiptFormOptions(
      organizations: orgs.getOrElse(() => const []),
      departments: depts.getOrElse(() => const []),
      warehouses: whs.getOrElse(() => const []),
      users: users.getOrElse(() => const []),
      items: items.getOrElse(() => const []),
      uoms: uoms.getOrElse(() => const []),
    );

    // Đơn vị / bộ phận lấy từ user đăng nhập; nếu không tìm thấy thì fallback
    // về đơn vị đầu tiên.
    final uid = _auth.currentAccount?.uid;
    final me = options.users
        .where((u) => u.id == uid)
        .cast<AppUser?>()
        .firstOrNull;
    final org = me == null
        ? (options.organizations.isNotEmpty
              ? options.organizations.first
              : null)
        : options.organizations
              .where((o) => o.id == me.organizationId)
              .cast<Organization?>()
              .firstOrNull;
    final dept = me?.departmentId == null
        ? null
        : options.departments
              .where((d) => d.id == me!.departmentId)
              .cast<Department?>()
              .firstOrNull;

    var data = state.data.copyWith(
      receiptDate: state.data.receiptDate ?? DateTime.now(),
      organizationId: org?.id ?? '',
      organizationName: org?.name ?? '',
      departmentId: dept?.id,
      departmentName: dept?.name,
    );
    if (me != null) {
      // gợi ý mặc định: người giao & người lập phiếu = người đăng nhập
      data = data.copyWith(
        delivererUserId: me.id,
        delivererName: me.fullName,
        preparerUserId: me.id,
        preparerName: me.fullName,
      );
    }

    emit(
      state.copyWith(
        status: ReceiptFormStatus.editing,
        options: options,
        data: data,
      ),
    );
  }

  void _onHeaderChanged(
    ReceiptHeaderChanged event,
    Emitter<ReceiptFormState> emit,
  ) {
    emit(
      state.copyWith(
        data: event.apply(state.data),
        status: ReceiptFormStatus.editing,
        clearErrorsFor: event.touchedKeys,
      ),
    );
  }

  void _onItemAdded(ReceiptItemAdded event, Emitter<ReceiptFormState> emit) {
    emit(
      state.copyWith(
        data: state.data.copyWith(
          items: [
            ...state.data.items,
            ReceiptItemFormData(rowId: _nextRowId()),
          ],
        ),
        status: ReceiptFormStatus.editing,
        clearErrorsFor: const ['items'],
      ),
    );
  }

  void _onItemRemoved(
    ReceiptItemRemoved event,
    Emitter<ReceiptFormState> emit,
  ) {
    emit(
      state.copyWith(
        data: state.data.copyWith(
          items: state.data.items
              .where((i) => i.rowId != event.rowId)
              .toList(growable: false),
        ),
        status: ReceiptFormStatus.editing,
        clearRowErrors: true,
      ),
    );
  }

  void _onItemChanged(
    ReceiptItemChanged event,
    Emitter<ReceiptFormState> emit,
  ) {
    emit(
      state.copyWith(
        data: state.data.copyWith(
          items: state.data.items
              .map((i) => i.rowId == event.row.rowId ? event.row : i)
              .toList(growable: false),
        ),
        status: ReceiptFormStatus.editing,
        clearRowErrors: true,
      ),
    );
  }

  void _onStepRequested(
    ReceiptStepRequested event,
    Emitter<ReceiptFormState> emit,
  ) {
    final target = event.target.clamp(0, ReceiptFormState.lastStep);

    // Going back (or staying) is free.
    if (target <= state.step) {
      emit(state.copyWith(step: target, status: ReceiptFormStatus.editing));
      return;
    }

    // Going forward: every field owned by a step we're leaving must be valid.
    final all = WarehouseReceiptRules.validate(state.data.toEntity());
    final blocking = <String, String>{
      for (final e in all.entries)
        if (WarehouseReceiptRules.stepOfKey(e.key) < target) e.key: e.value,
    };
    if (blocking.isNotEmpty) {
      emit(state.copyWith(errors: blocking, status: ReceiptFormStatus.failure));
      return;
    }

    emit(
      state.copyWith(
        step: target,
        errors: const {},
        status: ReceiptFormStatus.editing,
      ),
    );
  }

  Future<void> _onSubmitted(
    ReceiptSubmitted event,
    Emitter<ReceiptFormState> emit,
  ) async {
    final receipt = state.data.toEntity();

    final localErrors = WarehouseReceiptRules.validate(receipt);
    if (localErrors.isNotEmpty) {
      emit(
        state.copyWith(status: ReceiptFormStatus.failure, errors: localErrors),
      );
      return;
    }

    emit(
      state.copyWith(status: ReceiptFormStatus.submitting, errors: const {}),
    );

    final result = await _createWarehouseReceipt(
      CreateWarehouseReceiptParams(receipt),
    );

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: ReceiptFormStatus.failure,
              errors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ReceiptFormStatus.failure,
              submitError: failure.message,
            ),
          );
        }
      },
      (id) =>
          emit(state.copyWith(status: ReceiptFormStatus.success, savedId: id)),
    );
  }
}
