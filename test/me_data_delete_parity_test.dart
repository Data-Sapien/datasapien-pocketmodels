import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records [deleteMeData] calls without hitting the platform channel.
///
/// Mirrors how [MyDataTab] and [DataPrivacyScreen] use [MeDataService]
/// after [DataSapien.getMeDataService()].
class _RecordingMeDataApi extends MeDataServiceApi {
  _RecordingMeDataApi() : super(binaryMessenger: null);

  final List<String> deleteMeDataCalls = [];
  final List<MapEntry<String, String>> deleteMeDataRecordCalls = [];

  @override
  Future<void> deleteMeData(String name) async {
    deleteMeDataCalls.add(name);
  }

  @override
  Future<void> deleteMeDataRecord(String name, String recordId) async {
    deleteMeDataRecordCalls.add(MapEntry(name, recordId));
  }
}

void main() {
  group('MeData deleteMeData parity (My Data swipe + delete all)', () {
    test('single delete uses definition name as SDK key', () async {
      final api = _RecordingMeDataApi();
      final service = MeDataService(api);
      await service.deleteMeData('user_inferred_favorite_food');
      expect(api.deleteMeDataCalls, ['user_inferred_favorite_food']);
    });

    test('bulk delete calls deleteMeData once per definition', () async {
      final api = _RecordingMeDataApi();
      final service = MeDataService(api);
      const names = ['def_a', 'def_b', 'inference_xyz'];
      for (final name in names) {
        await service.deleteMeData(name);
      }
      expect(api.deleteMeDataCalls, names);
    });
  });

  group('MeData deleteMeDataRecord parity (History row delete)', () {
    test('record delete uses definition name + record id', () async {
      final api = _RecordingMeDataApi();
      final service = MeDataService(api);
      await service.deleteMeDataRecord(
        'user_inferred_favorite_food',
        'record-123',
      );
      expect(api.deleteMeDataRecordCalls, hasLength(1));
      expect(
          api.deleteMeDataRecordCalls.first.key, 'user_inferred_favorite_food');
      expect(api.deleteMeDataRecordCalls.first.value, 'record-123');
    });
  });
}
