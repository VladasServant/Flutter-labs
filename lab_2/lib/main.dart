import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

sealed class PcSpecItem {
  final String category;
  final String modelName;

  const PcSpecItem({
    required this.category,
    required this.modelName,
  });
}

class HardwareComponentModel extends PcSpecItem {
  final String architectureSpec;
  final int tdpWatts;

  const HardwareComponentModel({
    required super.category,
    required super.modelName,
    required this.architectureSpec,
    required this.tdpWatts,
  });
}

class MemoryStorageModel extends PcSpecItem {
  final int capacityGb;
  final String interfaceSpeed;

  const MemoryStorageModel({
    required super.category,
    required super.modelName,
    required this.capacityGb,
    required this.interfaceSpeed,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lists Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'First Page'),
        '/second': (context) => const SecondPage(title: 'Second Page'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/second');
          },
          child: const Text('Next'),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key, required this.title});

  final String title;

  static const List<PcSpecItem> _pcSpecs = [
    HardwareComponentModel(
      category: 'Процесор (CPU)',
      modelName: 'AMD Ryzen 7 7800X3D',
      architectureSpec: '8 ядер / 16 потоків, до 5.0 ГГц',
      tdpWatts: 120,
    ),
    HardwareComponentModel(
      category: 'Відеокарта (GPU)',
      modelName: 'NVIDIA GeForce RTX 4070 Super',
      architectureSpec: '12 ГБ GDDR6X, 192-bit',
      tdpWatts: 220,
    ),
    MemoryStorageModel(
      category: 'Оперативна пам\'ять (RAM)',
      modelName: 'Kingston Fury Beast DDR5',
      capacityGb: 32,
      interfaceSpeed: 'DDR5-6000 МТ/с (2x16 ГБ)',
    ),
    MemoryStorageModel(
      category: 'Накопичувач (SSD)',
      modelName: 'Samsung 990 PRO NVMe',
      capacityGb: 1000,
      interfaceSpeed: 'PCIe 4.0 x4 (до 7450 МБ/с)',
    ),
    HardwareComponentModel(
      category: 'Блок живлення (PSU)',
      modelName: 'be quiet! Pure Power 12 M',
      architectureSpec: '80 PLUS Gold, ATX 3.0',
      tdpWatts: 750,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Специфікація ПК'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Комплектуюча / Модель',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Параметр',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _pcSpecs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _pcSpecs[index];

                return switch (item) {
                  HardwareComponentModel() => ListTile(
                      leading: const Icon(Icons.developer_board, color: Colors.blueGrey),
                      title: Text(
                        '${item.category}: ${item.modelName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(item.architectureSpec),
                      trailing: Chip(
                        label: Text('${item.tdpWatts} Вт'),
                      ),
                    ),
                  MemoryStorageModel() => ListTile(
                      leading: const Icon(Icons.storage, color: Colors.teal),
                      title: Text(
                        '${item.category}: ${item.modelName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(item.interfaceSpeed),
                      trailing: Chip(
                        backgroundColor: Colors.teal.shade50,
                        label: Text('${item.capacityGb} ГБ'),
                      ),
                    ),
                };
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ),
        ],
      ),
    );
  }
}