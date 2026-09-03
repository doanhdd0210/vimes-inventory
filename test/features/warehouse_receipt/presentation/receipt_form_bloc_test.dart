import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vimes_inventory/core/domain/crud_repository.dart';
import 'package:vimes_inventory/core/error/failures.dart';
import 'package:vimes_inventory/features/auth/data/auth_data_source.dart';
import 'package:vimes_inventory/features/auth/data/auth_repository_impl.dart';
import 'package:vimes_inventory/features/master_data/domain/entities/app_user.dart';
import 'package:vimes_inventory/features/master_data/domain/entities/department.dart';
import 'package:vimes_inventory/features/master_data/domain/entities/item.dart';
import 'package:vimes_inventory/features/master_data/domain/entities/organization.dart';
import 'package:vimes_inventory/features/master_data/domain/entities/unit_of_measure.dart';
import 'package:vimes_inventory/features/master_data/domain/entities/warehouse.dart';
import 'package:vimes_inventory/features/warehouse_receipt/domain/usecases/create_warehouse_receipt.dart';
import 'package:vimes_inventory/features/warehouse_receipt/presentation/viewmodel/receipt_form_bloc.dart';
import 'package:vimes_inventory/features/warehouse_receipt/presentation/viewmodel/receipt_form_data.dart';

class _MockCreate extends Mock implements CreateWarehouseReceipt {}

class _FakeParams extends Fake implements CreateWarehouseReceiptParams {}

class _OrgRepo extends Mock implements CrudRepository<Organization> {}

class _DeptRepo extends Mock implements CrudRepository<Department> {}

class _WhRepo extends Mock implements CrudRepository<Warehouse> {}

class _UserRepo extends Mock implements CrudRepository<AppUser> {}

class _ItemRepo extends Mock implements CrudRepository<Item> {}

class _UomRepo extends Mock implements CrudRepository<UnitOfMeasure> {}

const _org = Organization(id: 'o1', code: 'VIMES', name: 'VIMES');
const _wh = Warehouse(
  id: 'w1',
  organizationId: 'o1',
  code: 'K1',
  name: 'Kho A',
);
const _user = AppUser(
  id: 'u1',
  organizationId: 'o1',
  username: 'a',
  fullName: 'Nguyễn Văn A',
);
const _uom = UnitOfMeasure(id: 'm1', code: 'CAI', name: 'Cái');
const _item = Item(id: 'i1', code: 'VT001', name: 'Thép', uomId: 'm1');

void main() {
  late _MockCreate create;
  late _OrgRepo orgs;
  late _DeptRepo depts;
  late _WhRepo whs;
  late _UserRepo users;
  late _ItemRepo items;
  late _UomRepo uoms;

  setUpAll(() => registerFallbackValue(_FakeParams()));

  setUp(() {
    create = _MockCreate();
    orgs = _OrgRepo();
    depts = _DeptRepo();
    whs = _WhRepo();
    users = _UserRepo();
    items = _ItemRepo();
    uoms = _UomRepo();
    when(() => orgs.getAll()).thenAnswer((_) async => const Right([_org]));
    when(() => depts.getAll()).thenAnswer((_) async => const Right([]));
    when(() => whs.getAll()).thenAnswer((_) async => const Right([_wh]));
    when(() => users.getAll()).thenAnswer((_) async => const Right([_user]));
    when(() => items.getAll()).thenAnswer((_) async => const Right([_item]));
    when(() => uoms.getAll()).thenAnswer((_) async => const Right([_uom]));
  });

  ReceiptFormBloc build() => ReceiptFormBloc(
    createWarehouseReceipt: create,
    auth: AuthRepositoryImpl(FakeAuthDataSource()),
    organizations: orgs,
    departments: depts,
    warehouses: whs,
    users: users,
    items: items,
    uoms: uoms,
  );

  Future<void> fillValid(ReceiptFormBloc bloc) async {
    bloc.add(const ReceiptFormStarted());
    await Future<void>.delayed(Duration.zero);
    bloc
      ..add(
        const ReceiptHeaderChanged(
          receiptNumber: 'PN-001',
          warehouseId: 'w1',
          warehouseName: 'Kho A',
          delivererUserId: 'u1',
          delivererName: 'Nguyễn Văn A',
        ),
      )
      ..add(const ReceiptItemAdded());
    await Future<void>.delayed(Duration.zero);
    final rowId = bloc.state.data.items.single.rowId;
    bloc.add(
      ReceiptItemChanged(
        ReceiptItemFormData(
          rowId: rowId,
          itemId: 'i1',
          name: 'Thép',
          unit: 'Cái',
          quantityActual: 3,
          unitPrice: 100000,
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
  }

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'ReceiptFormStarted loads options and defaults the organisation',
    build: build,
    act: (bloc) => bloc.add(const ReceiptFormStarted()),
    verify: (bloc) {
      expect(bloc.state.status, ReceiptFormStatus.editing);
      expect(bloc.state.options.organizations, [_org]);
      expect(bloc.state.data.organizationId, 'o1');
    },
  );

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'submitting an empty form fails locally with field errors and no call',
    build: build,
    act: (bloc) async {
      bloc.add(const ReceiptFormStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ReceiptSubmitted());
    },
    verify: (bloc) {
      expect(bloc.state.status, ReceiptFormStatus.failure);
      expect(bloc.state.errorFor('receiptNumber'), isNotNull);
      expect(bloc.state.errorFor('items'), isNotNull);
      verifyNever(() => create(any()));
    },
  );

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'a valid form calls the use case and reaches success with the saved id',
    build: build,
    setUp: () => when(
      () => create(any()),
    ).thenAnswer((_) async => const Right('receipt-42')),
    act: (bloc) async {
      await fillValid(bloc);
      bloc.add(const ReceiptSubmitted());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (bloc) {
      expect(bloc.state.status, ReceiptFormStatus.success);
      expect(bloc.state.savedId, 'receipt-42');
      verify(() => create(any())).called(1);
    },
  );

  blocTest<ReceiptFormBloc, ReceiptFormState>(
    'a ServerFailure surfaces as submitError',
    build: build,
    setUp: () => when(
      () => create(any()),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'Mất mạng'))),
    act: (bloc) async {
      await fillValid(bloc);
      bloc.add(const ReceiptSubmitted());
      await Future<void>.delayed(Duration.zero);
    },
    verify: (bloc) {
      expect(bloc.state.status, ReceiptFormStatus.failure);
      expect(bloc.state.submitError, 'Mất mạng');
    },
  );
}
