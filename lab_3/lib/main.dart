import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class CheckBoxItem {
  final String category;
  final String modelName;
  final String spec;
  final String badgeText;
  final bool isMemoryType;
  bool isChecked;

  CheckBoxItem({
    required this.category,
    required this.modelName,
    required this.spec,
    required this.badgeText,
    this.isMemoryType = false,
    this.isChecked = false,
  });
}

class TriStateCheckBoxController extends ChangeNotifier {
  final String groupTitle;
  final List<CheckBoxItem> items;

  TriStateCheckBoxController({required this.groupTitle, required this.items});

  int get checkedCount => items.where((item) => item.isChecked).length;

  bool? get groupState {
    if (items.isEmpty) return false;

    if (checkedCount == 0) {
      return false;
    } else if (checkedCount == items.length) {
      return true;
    } else {
      return null;
    }
  }

  String get stateLabel => switch (groupState) {
    true => 'Помічений',
    false => 'Непомічений',
    null => 'Частково',
  };

  void toggleGroup(bool? value) {
    final bool targetState = value ?? false;
    for (final item in items) {
      item.isChecked = targetState;
    }
    notifyListeners();
  }

  void toggleItem(int index, bool? value) {
    items[index].isChecked = value ?? false;
    notifyListeners();
  }
}

class TriStateCheckBoxGroup extends StatelessWidget {
  final TriStateCheckBoxController controller;

  const TriStateCheckBoxGroup({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.groupState;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Checkbox(
                    tristate: true,
                    value: state,
                    onChanged: controller.toggleGroup,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      controller.groupTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      controller.stateLabel,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = controller.items[index];

                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 28, right: 16),
                  onTap: () => controller.toggleItem(index, !item.isChecked),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: item.isChecked,
                        onChanged: (value) =>
                            controller.toggleItem(index, value),
                      ),
                      Icon(
                        item.isMemoryType
                            ? Icons.storage
                            : Icons.developer_board,
                        color: item.isMemoryType
                            ? Colors.teal
                            : Colors.blueGrey,
                      ),
                    ],
                  ),
                  title: Text(
                    '${item.category}: ${item.modelName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.spec),
                  trailing: Chip(
                    backgroundColor: item.isMemoryType
                        ? Colors.teal.shade50
                        : null,
                    label: Text(item.badgeText),
                  ),
                );
              },
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckBox Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const CheckBoxLabPage(),
    );
  }
}

class CheckBoxLabPage extends StatefulWidget {
  const CheckBoxLabPage({super.key});

  @override
  State<CheckBoxLabPage> createState() => _CheckBoxLabPageState();
}

class _CheckBoxLabPageState extends State<CheckBoxLabPage> {
  late final TriStateCheckBoxController _coreHardwareController;
  late final TriStateCheckBoxController _storageAndPowerController;

  @override
  void initState() {
    super.initState();
    _coreHardwareController = TriStateCheckBoxController(
      groupTitle: 'Основні комплектуючі (CPU / GPU / RAM)',
      items: [
        CheckBoxItem(
          category: 'Процесор (CPU)',
          modelName: 'AMD Ryzen 7 7800X3D',
          spec: '8 ядер / 16 потоків, до 5.0 ГГц',
          badgeText: '120 Вт',
          isChecked: true,
        ),
        CheckBoxItem(
          category: 'Відеокарта (GPU)',
          modelName: 'NVIDIA GeForce RTX 4070 Super',
          spec: '12 ГБ GDDR6X, 192-bit',
          badgeText: '220 Вт',
          isChecked: false,
        ),
        CheckBoxItem(
          category: 'Оперативна пам\'ять (RAM)',
          modelName: 'Kingston Fury Beast DDR5',
          spec: 'DDR5-6000 МТ/с (2x16 ГБ)',
          badgeText: '32 ГБ',
          isMemoryType: true,
          isChecked: false,
        ),
      ],
    );

    _storageAndPowerController = TriStateCheckBoxController(
      groupTitle: 'Накопичувачі та живлення',
      items: [
        CheckBoxItem(
          category: 'Накопичувач (SSD)',
          modelName: 'Samsung 990 PRO NVMe',
          spec: 'PCIe 4.0 x4 (до 7450 МБ/с)',
          badgeText: '1000 ГБ',
          isMemoryType: true,
          isChecked: true,
        ),
        CheckBoxItem(
          category: 'Блок живлення (PSU)',
          modelName: 'be quiet! Pure Power 12 M',
          spec: '80 PLUS Gold, ATX 3.0',
          badgeText: '750 Вт',
          isChecked: true,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _coreHardwareController.dispose();
    _storageAndPowerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Специфікація ПК: Тристановий CheckBox'),
      ),
      body: ListView(
        children: [
          TriStateCheckBoxGroup(controller: _coreHardwareController),
          const SizedBox(height: 16),
          TriStateCheckBoxGroup(controller: _storageAndPowerController),
        ],
      ),
    );
  }
}
