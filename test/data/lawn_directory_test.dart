import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/data/lawn/lawn_directory.dart';
import 'package:lawnly/data/lawn/lawn_profile.dart';
import 'package:lawnly/data/lawn/lawn_scoped_storage_adapter.dart';
import 'package:lawnly/data/local/adapter/storage_adapter.dart';

class _MemoryStorage extends StorageAdapter {
  final values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async => values[key] = value;

  @override
  Future<void> delete({required String key}) async => values.remove(key);
}

void main() {
  final profile = LawnProfile(
    name: 'Za domem',
    location: const LawnLocation(latitude: 52, longitude: 21),
    areaSqm: 120,
    establishedOn: DateTime(2024, 4, 1),
    establishment: EstablishmentMethod.seeded,
    sun: SunExposure.sun,
    grassMix: GrassMix.unknown,
    soil: SoilType.unknown,
    watering: WateringMode.automatic,
    mowingIntervalDays: 5,
    gardenWeekdays: const {DateTime.saturday},
    fertilizingIntervalDays: 15,
  );

  test('pierwszy trawnik korzysta z dotychczasowych kluczy', () async {
    final directory = await LawnDirectory.load(_MemoryStorage());

    expect(directory.activeId.value, LawnDirectory.mainId);
    expect(directory.scopedKey('care_plan'), 'care_plan');
  });

  test('nowy trawnik staje się wybrany i ma osobne dane', () async {
    final storage = _MemoryStorage();
    final directory = await LawnDirectory.load(storage);
    final scoped = LawnScopedStorageAdapter(adapter: storage, lawns: directory);
    await scoped.write(key: 'care_plan', value: 'pierwszy');

    await directory.add('2', profile);

    expect(directory.activeId.value, '2');
    expect(await scoped.read(key: 'care_plan'), isNull);
    await scoped.write(key: 'care_plan', value: 'drugi');
    await directory.select(LawnDirectory.mainId);
    expect(await scoped.read(key: 'care_plan'), 'pierwszy');
  });

  test('wybór i lista trawników przetrwają ponowne uruchomienie', () async {
    final storage = _MemoryStorage();
    final directory = await LawnDirectory.load(storage);
    await directory.add('2', profile);

    final reloaded = await LawnDirectory.load(storage);

    expect(reloaded.activeId.value, '2');
    expect((await reloaded.lawns()).single.profile.name, 'Za domem');
  });

  test('uszkodzona lista wraca do pierwszego trawnika', () async {
    final storage = _MemoryStorage()..values['lawn_index'] = 'to nie json';

    final directory = await LawnDirectory.load(storage);

    expect(directory.activeId.value, LawnDirectory.mainId);
  });
}
