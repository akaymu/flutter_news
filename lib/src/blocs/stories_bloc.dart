import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/item_model.dart';
import '../resources/repository.dart';

class StoriesBloc {
  final _repository = Repository();

  // Ayrıntılar: https://pub.dev/documentation/rxdart/latest/rx_subjects/rx_subjects-library.html
  final _topIds = PublishSubject<List<int>>();

  // Herkesin dinlediği ve transforme edilmeyen StreamController
  final _itemsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>();

  // Yeni oluşturulan ve transformasyonun yapıldığı StreamController
  final _itemsFetcher = PublishSubject<int>();

  // Getters to Streams
  Stream<List<int>> get topIds => _topIds.stream;
  Stream<Map<int, Future<ItemModel>>> get items => _itemsOutput.stream;

  // Getters to Sinks
  Function(int) get fetchItem => _itemsFetcher.sink.add;

  // Şimdi _itemsFetcher ile _itemsOutput arasındaki bağlantıyı
  // CONSTRUCTOR fonksiyonunda kuracağız.
  StoriesBloc() {
    _itemsFetcher.stream.transform(_itemsTransformer()).pipe(_itemsOutput);
  }

  // topids sink için bir getter a ihtiyacımız olmadı çünkü
  // bir widget'tan gelmeyecek bu veriler.
  // Repository'den gelecek... Dolayısıyla aşağıdaki methodu ekledik.
  fetchTopIds() async {
    final ids = await _repository.fetchTopIds();
    _topIds.sink.add(ids);
  }

  Future<void> clearCache() {
    return _repository.clearCache();
  }

  _itemsTransformer() {
    return ScanStreamTransformer<int, Map<int, Future<ItemModel>>>(
      (Map<int, Future<ItemModel>> cache, int id, index) {
        cache[id] = _repository.fetchItem(id);
        return cache;
      },
      <int, Future<ItemModel>>{}, // Initial value of cache map
    );
  }

  dispose() {
    _topIds.close();
    _itemsFetcher.close();
    _itemsOutput.close();
  }
}
