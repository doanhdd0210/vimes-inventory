extension IterableX<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;

  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  Iterable<E> separatedBy(E separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    yield iterator.current;
    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }

  Map<K, List<E>> groupBy<K>(K Function(E element) keyOf) {
    final result = <K, List<E>>{};
    for (final element in this) {
      result.putIfAbsent(keyOf(element), () => []).add(element);
    }
    return result;
  }
}

extension ListX<E> on List<E> {
  List<E> get immutable => List.unmodifiable(this);
}
