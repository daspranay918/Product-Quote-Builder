import 'package:flutter/material.dart';
import 'package:quote_builder/models/quote.dart';
import 'package:quote_builder/utils/currency.dart';

class QuotePreview extends StatelessWidget {
  final Quote quote;
  const QuotePreview({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'QUOTE PREVIEW',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                Chip(label: Text(quote.status.name.toUpperCase())),
              ],
            ),

            const SizedBox(height: 16),

            // Client info
            Text(
              quote.client.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(quote.client.address),
            if (quote.client.reference.isNotEmpty)
              Text("Reference: ${quote.client.reference}"),

            const Divider(height: 32),

            _buildTable(context),

            const Divider(height: 32),

            _buildTotals(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelLarge;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.5),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: FlexColumnWidth(),
        5: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Text("Item", style: headerStyle),
            Text("Qty", style: headerStyle),
            Text("Rate", style: headerStyle),
            Text("Disc", style: headerStyle),
            Text("Tax %", style: headerStyle),
            Align(alignment: Alignment.centerRight, child: Text("Total", style: headerStyle)),
          ],
        ),
        ...quote.items.map((item) {
          final total = quote.taxMode == TaxMode.exclusive
              ? item.totalExclusive()
              : item.totalInclusive();

          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(item.name),
              ),
              Text(item.quantity.toStringAsFixed(2)),
              Text(money(item.rate, code: quote.currencyCode)),
              Text(money(item.discount, code: quote.currencyCode)),
              Text("${item.taxPercent.toStringAsFixed(2)}%"),
              Align(
                alignment: Alignment.centerRight,
                child: Text(money(total, code: quote.currencyCode)),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTotals(BuildContext context) {
    final subtotal = quote.subtotal();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text("Subtotal", style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(money(subtotal, code: quote.currencyCode),
              style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text("Grand Total", style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(
              money(subtotal, code: quote.currencyCode),
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text("Tax Mode: ${quote.taxMode.name}"),
      ],
    );
  }
}
