import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/sample_item.dart';
import '../repositories/sample_repository.dart';

class AddSampleItem extends UseCase<SampleItem, AddSampleItemParams> {
  const AddSampleItem(this._repository);

  final SampleRepository _repository;

  @override
  ResultFuture<SampleItem> call(AddSampleItemParams params) {
    return _repository.addSampleItem(params.title);
  }
}

class AddSampleItemParams extends Equatable {
  const AddSampleItemParams(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}
