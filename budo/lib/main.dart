import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'state/task_store.dart';
import 'theme.dart';
import 'widgets/glitch_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = TaskStore();
  await store.load();
  runApp(ChangeNotifierProvider.value(value: store, child: const BuDoApp()));
}

class BuDoApp extends StatelessWidget {
  const BuDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BU! DOO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Palette.purple),
        scaffoldBackgroundColor: Palette.cream,
      ),
      // O glitch fica POR CIMA do Navigator: telas e diálogos também são assombrados.
      builder: (context, child) => Consumer<TaskStore>(
        builder: (_, store, __) => GlitchOverlay(intensity: store.haunting, child: child!),
      ),
      home: const HomeScreen(),
    );
  }
}
