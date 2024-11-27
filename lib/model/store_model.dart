import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    required String storeName,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
