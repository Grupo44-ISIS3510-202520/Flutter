import 'package:flutter/material.dart';

class ProtocolSearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const ProtocolSearchField({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search protocols...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: value.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close), onPressed: () => onChanged('')),
      ),
    );
  }
}
