import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/typedefs.dart';
import '../models/warehouse_receipt_model.dart';

abstract class WarehouseReceiptDataSource {
  Future<String> createReceipt(WarehouseReceiptModel receipt);

  Future<List<WarehouseReceiptModel>> getReceipts();

  Future<WarehouseReceiptModel> getReceiptById(String id);
}

/// Cloud Firestore implementation. The phiếu is one document with an embedded
/// `items` array; `receiptNumber` uniqueness is enforced in a transaction via a
/// mirror doc in `receipt_numbers/{number}`.
class WarehouseReceiptFirestoreDataSource
    implements WarehouseReceiptDataSource {
  WarehouseReceiptFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<DataMap> get _receipts =>
      _firestore.collection(FirestoreCollections.warehouseReceipts);

  CollectionReference<DataMap> get _numbers =>
      _firestore.collection(FirestoreCollections.receiptNumbers);

  @override
  Future<String> createReceipt(WarehouseReceiptModel receipt) async {
    try {
      final receiptRef = _receipts.doc();
      final numberRef = _numbers.doc(receipt.receiptNumber.trim());

      await _firestore.runTransaction((txn) async {
        final existing = await txn.get(numberRef);
        if (existing.exists) {
          throw const ServerException(
            message: 'Số phiếu đã tồn tại',
            statusCode: 'already-exists',
          );
        }
        txn
          ..set(receiptRef, receipt.toMap())
          ..set(numberRef, {
            'receiptId': receiptRef.id,
            'createdAt': FieldValue.serverTimestamp(),
          });
      });

      return receiptRef.id;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<List<WarehouseReceiptModel>> getReceipts() async {
    try {
      final snapshot = await _receipts
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map(WarehouseReceiptModel.fromSnapshot)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }

  @override
  Future<WarehouseReceiptModel> getReceiptById(String id) async {
    try {
      final doc = await _receipts.doc(id).get();
      if (!doc.exists) {
        throw const ServerException(
          message: 'Không tìm thấy phiếu',
          statusCode: 'not-found',
        );
      }
      return WarehouseReceiptModel.fromSnapshot(doc);
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code, statusCode: e.code);
    }
  }
}
