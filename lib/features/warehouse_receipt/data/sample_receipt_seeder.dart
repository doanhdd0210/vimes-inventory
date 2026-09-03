import '../../master_data/data/master_seed.dart';
import '../domain/entities/warehouse_receipt.dart';
import '../domain/entities/warehouse_receipt_item.dart';
import '../domain/repositories/warehouse_receipt_repository.dart';

/// Seeds two example phiếu nhập kho the first time the receipt store is empty,
/// so a reviewer opening the app immediately sees the phiếu list, the **Tồn
/// kho** snapshot and the **Thẻ kho** ledger already populated — instead of
/// three empty screens.
///
/// Each phiếu is written through the real
/// [WarehouseReceiptRepository.createReceipt] path (Firestore `runTransaction`
/// / in-memory), which also posts stock with weighted-average cost — the same
/// path covered by `test/features/warehouse_receipt/**` and
/// `test/features/stock/stock_posting_test.dart`.
///
/// Thép hộp (VT001) is received on **both** phiếu at different prices, so the
/// weighted-average cost visibly blends on the Thẻ kho screen:
/// 100 m @ 42 000 then 50 m @ 45 000 → 150 m, bình quân 43 000.
class SampleReceiptSeeder {
  const SampleReceiptSeeder(this._repository);

  final WarehouseReceiptRepository _repository;

  Future<void> seedIfEmpty() async {
    final existing = await _repository.getReceipts();
    final skip = existing.fold(
      (_) => true, // read failed — don't attempt to write on top of it
      (list) => list.isNotEmpty,
    );
    if (skip) return;

    for (final receipt in _samples()) {
      final result = await _repository.createReceipt(receipt);
      if (result.isLeft()) break; // e.g. permission denied — stop quietly
    }
  }

  List<WarehouseReceipt> _samples() => [
    WarehouseReceipt(
      id: '',
      receiptNumber: 'PN-2026-08-001',
      receiptDate: DateTime(2026, 8, 20, 9, 30),
      organizationId: MasterSeed.orgId,
      organizationName: 'Công ty CP VIMES',
      departmentId: MasterSeed.dptWarehouse,
      departmentName: 'Phòng Kho vận',
      warehouseId: MasterSeed.whMain,
      warehouseName: 'Kho chính',
      warehouseLocation: 'Tầng 1 - Nhà A',
      debitAccount: '152',
      creditAccount: '331',
      delivererUserId: MasterSeed.userDeliver,
      delivererName: 'Lê Văn Giao',
      referenceDocNumber: 'HĐ 0004521',
      referenceDocDate: DateTime(2026, 8, 19),
      referenceDocIssuer: 'Công ty Thép Hòa Phát',
      attachedDocumentCount: 2,
      preparerUserId: MasterSeed.userKeeper,
      preparerName: 'Nguyễn Văn Kho',
      storekeeperUserId: MasterSeed.userKeeper,
      storekeeperName: 'Nguyễn Văn Kho',
      chiefAccountantUserId: MasterSeed.userAccountant,
      chiefAccountantName: 'Trần Thị Toán',
      items: const [
        WarehouseReceiptItem(
          lineNo: 1,
          itemId: 'item-thephop',
          name: 'Thép hộp mạ kẽm 40x40x1.4mm',
          code: 'VT001',
          uomId: MasterSeed.uomMet,
          unit: 'Mét',
          quantityDoc: 100,
          quantityActual: 100,
          unitPrice: 42000,
        ),
        WarehouseReceiptItem(
          lineNo: 2,
          itemId: 'item-day-dien',
          name: 'Dây điện Cadivi CV 2x2.5',
          code: 'VT010',
          uomId: MasterSeed.uomMet,
          unit: 'Mét',
          quantityDoc: 500,
          quantityActual: 500,
          unitPrice: 9500,
        ),
      ],
    ),
    WarehouseReceipt(
      id: '',
      receiptNumber: 'PN-2026-08-002',
      receiptDate: DateTime(2026, 8, 27, 14, 0),
      organizationId: MasterSeed.orgId,
      organizationName: 'Công ty CP VIMES',
      departmentId: MasterSeed.dptWarehouse,
      departmentName: 'Phòng Kho vận',
      warehouseId: MasterSeed.whMain,
      warehouseName: 'Kho chính',
      warehouseLocation: 'Tầng 1 - Nhà A',
      debitAccount: '152',
      creditAccount: '111',
      delivererUserId: MasterSeed.userDeliver,
      delivererName: 'Lê Văn Giao',
      referenceDocNumber: 'HĐ 0004977',
      referenceDocDate: DateTime(2026, 8, 26),
      referenceDocIssuer: 'Công ty Thiết bị điện Cadivi',
      attachedDocumentCount: 1,
      preparerUserId: MasterSeed.userKeeper,
      preparerName: 'Nguyễn Văn Kho',
      storekeeperUserId: MasterSeed.userKeeper,
      storekeeperName: 'Nguyễn Văn Kho',
      chiefAccountantUserId: MasterSeed.userAccountant,
      chiefAccountantName: 'Trần Thị Toán',
      items: const [
        WarehouseReceiptItem(
          lineNo: 1,
          itemId: 'item-thephop',
          name: 'Thép hộp mạ kẽm 40x40x1.4mm',
          code: 'VT001',
          uomId: MasterSeed.uomMet,
          unit: 'Mét',
          quantityDoc: 50,
          quantityActual: 50,
          unitPrice: 45000,
        ),
        WarehouseReceiptItem(
          lineNo: 2,
          itemId: 'item-aptomat',
          name: 'Aptomat MCB 2P 32A',
          code: 'VT011',
          uomId: MasterSeed.uomCai,
          unit: 'Cái',
          quantityDoc: 10,
          quantityActual: 10,
          unitPrice: 135000,
        ),
      ],
    ),
  ];
}
