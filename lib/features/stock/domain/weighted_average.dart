/// Weighted-average (bình quân gia quyền) stock maths, shared by the Firestore
/// transaction and the in-memory store so both post identically.
class WeightedAverage {
  const WeightedAverage._();

  /// Apply a receipt (goods-in) to a running balance.
  static ({num qty, num value, num avg}) applyReceipt({
    required num currentQty,
    required num currentValue,
    required num inQty,
    required num inValue,
  }) {
    final qty = currentQty + inQty;
    final value = currentValue + inValue;
    return (
      qty: qty,
      value: value,
      avg: qty > 0 ? (value / qty).roundToDouble() : 0,
    );
  }
}
