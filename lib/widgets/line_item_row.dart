import 'package:flutter/material.dart';

class LineItemRow extends StatelessWidget {
  final int index;
  final TextEditingController nameCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController discCtrl;
  final TextEditingController taxCtrl;
  final VoidCallback onRemove;

  const LineItemRow({
    super.key,
    required this.index,
    required this.nameCtrl,
    required this.qtyCtrl,
    required this.rateCtrl,
    required this.discCtrl,
    required this.taxCtrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;

    final row = [
      Expanded(
        flex: 3,
        child: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Product/Service'),
        ),
      ),
      const SizedBox(width: 8),

      Expanded(
        child: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Qty'),
        ),
      ),
      const SizedBox(width: 8),

      Expanded(
        child: TextField(
          controller: rateCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Rate'),
        ),
      ),
      const SizedBox(width: 8),

      Expanded(
        child: TextField(
          controller: discCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Discount'),
        ),
      ),
      const SizedBox(width: 8),

      Expanded(
        child: TextField(
          controller: taxCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Tax %'),
        ),
      ),

      IconButton(
        onPressed: onRemove,
        icon: const Icon(Icons.delete_outline),
        tooltip: "Remove this item",
      ),
    ];

    if (isWide) {
      return Row(children: row);
    }

    return Column(
      children: [
        Row(children: row.sublist(0, 3)),
        const SizedBox(height: 8),
        Row(children: row.sublist(3)),
      ],
    );
  }
}
