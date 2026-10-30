import 'package:flutter/material.dart';

import 'router/app_router.dart';

class MimiApp extends StatefulWidget {
  const MimiApp({super.key});

  @override
  State<MimiApp> createState() => _MimiAppState();
}

class _MimiAppState extends State<MimiApp> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Mimi', routerConfig: _router.config());
  }
}
