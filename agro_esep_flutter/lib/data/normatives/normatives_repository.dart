import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'normatives.dart';

/// Откуда взялись действующие нормативы.
enum NormativesSource {
  /// Из комплекта приложения (assets).
  bundled,

  /// Загружены сотрудником института через режим администратора.
  imported,
}

class LoadedNormatives {
  const LoadedNormatives({required this.normatives, required this.source});

  final Normatives normatives;
  final NormativesSource source;
}

/// Нормативы поставляются вместе с приложением, но институт должен
/// иметь возможность обновить их без нового релиза в сторе. Загруженный
/// файл кладётся в каталог приложения и с этого момента имеет приоритет
/// над встроенным.
class NormativesRepository {
  const NormativesRepository();

  static const _fileName = 'normatives_imported.json';

  Future<File> _importedFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<LoadedNormatives> load() async {
    try {
      final file = await _importedFile();
      if (file.existsSync()) {
        final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        return LoadedNormatives(
          normatives: Normatives.fromJson(raw),
          source: NormativesSource.imported,
        );
      }
    } catch (_) {
      // Битый или несовместимый импорт не должен превращать приложение
      // в нерабочее: откатываемся на встроенную базу.
    }
    return LoadedNormatives(
      normatives: await Normatives.loadFromAssets(),
      source: NormativesSource.bundled,
    );
  }

  Future<void> saveImported(Normatives normatives, Map<String, dynamic> rawJson) async {
    final file = await _importedFile();
    await file.writeAsString(jsonEncode(rawJson));
  }

  /// Возврат к встроенной базе — нужен, если импорт оказался ошибочным.
  Future<void> clearImported() async {
    final file = await _importedFile();
    if (file.existsSync()) await file.delete();
  }

  Future<bool> hasImported() async => (await _importedFile()).existsSync();
}
