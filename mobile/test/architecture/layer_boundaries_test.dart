import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Hand-written Dart sources under [directory]; generated files are derived
/// from them.
Iterable<File> _sources(String directory) => Directory(directory).existsSync()
    ? Directory(directory)
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.endsWith('.g.dart') &&
                !f.path.endsWith('.freezed.dart'),
          )
    : const [];

Iterable<Directory> _featureLayers(String layer) =>
    Directory('lib/features')
        .listSync()
        .whereType<Directory>()
        .map((feature) => Directory('${feature.path}/$layer'))
        .where((d) => d.existsSync());

final _importPattern = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

List<String> _violations(Iterable<File> files, List<Pattern> forbidden) => [
  for (final file in files)
    for (final line in file.readAsLinesSync())
      if (_importPattern.firstMatch(line)?.group(1) case final uri?)
        if (forbidden.any((pattern) => uri.contains(pattern)))
          '${file.path}: $uri',
];

void main() {
  test('Domain has no Flutter, Riverpod, transport or Data dependencies', () {
    final files = [
      for (final layer in _featureLayers('domain')) ..._sources(layer.path),
      File('lib/core/error/failure.dart'),
    ];

    expect(files, isNotEmpty);
    expect(
      _violations(files, [
        'package:flutter/',
        'package:flutter_riverpod/',
        'package:riverpod',
        'package:dio/',
        'package:json_annotation/',
        '/data/',
        'core/network/',
        '_dto.dart',
      ]),
      isEmpty,
    );
  });

  test('Presentation does not depend on transport, DTOs or Data', () {
    final files = [
      for (final layer in _featureLayers('presentation'))
        ..._sources(layer.path),
    ];

    expect(
      _violations(files, [
        'package:dio/',
        '/data/',
        'core/network/',
        '_dto.dart',
      ]),
      isEmpty,
    );
  });

  test('Use cases depend only on Either, Failure, models and repositories', () {
    final files = [
      for (final layer in _featureLayers('domain/usecases'))
        ..._sources(layer.path),
    ];
    bool allowed(String uri) =>
        uri == 'package:fpdart/fpdart.dart' ||
        uri.endsWith('/core/error/failure.dart') ||
        uri.startsWith('../models/') ||
        uri.startsWith('../repositories/');

    expect(files, isNotEmpty);
    expect([
      for (final file in files)
        for (final line in file.readAsLinesSync())
          if (_importPattern.firstMatch(line)?.group(1) case final uri?)
            if (!allowed(uri)) '${file.path}: $uri',
    ], isEmpty);
  });
}
