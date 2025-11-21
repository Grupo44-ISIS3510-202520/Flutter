import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/di.dart' show sl;
import '../viewmodels/cas_brightness_viewmodel.dart';

class CasBrightnessScreen extends StatelessWidget {
  const CasBrightnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<CasBrightnessViewModel>()..init(),
      child: Consumer<CasBrightnessViewModel>(
        builder: (_, CasBrightnessViewModel vm, __) {
          return Scaffold(
            appBar: AppBar(title: const Text('Context Aware: Brightness')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (!vm.supported)
                    const Text(
                      'auto-brightness not supported on this platform',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      const Text('Auto brightness'),
                      const Spacer(),
                      Switch(
                        value: vm.autoOn,
                        onChanged: vm.supported ? vm.toggleAuto : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Current brightness: ${vm.currentBrightness.toStringAsFixed(2)}'),
                  const SizedBox(height: 24),
                  const Text(
                    'note: ambient light sensor available only on Android. '
                    'On iOS/web this screen stays manual.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
