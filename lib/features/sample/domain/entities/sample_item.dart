import 'package:equatable/equatable.dart';

/// Pure business object. No JSON, no Firestore, no Flutter — just the shape the
/// rest of the app reasons about.
class SampleItem extends Equatable {
  const SampleItem({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, createdAt];
}
