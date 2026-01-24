import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChecklistSection extends StatelessWidget {
  final List<String> labels;
  final RxList<bool> checklistState;
  final Function(int index, bool value) onStateChanged;

  const ChecklistSection({
    super.key,
    required this.labels,
    required this.checklistState,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Checklist", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Obx(() {
          return Column(
            children: List.generate(labels.length, (index) {
              return Column(
                children: [
                  Row(
                    children: [
                      Switch(
                        value: checklistState[index],
                        onChanged: (value) {
                          onStateChanged(index, value);
                        },
                        activeColor: Colors.blueGrey,

                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            labels[index],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ],
              );
            }),
          );
        }),
      ],
    );
  }
}
