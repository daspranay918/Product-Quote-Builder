import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quote_builder/models/quote.dart';
import 'package:quote_builder/storage/local_storage.dart';
import 'package:quote_builder/utils/currency.dart';
import 'package:quote_builder/widgets/quote_preview.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  late Quote quote;

  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  final List<_LineCtrls> _lineCtrls = [];

  @override
  void initState() {
    super.initState();
    quote = Quote();
    _syncClientToCtrls();
    _ensureLineCtrls();
    _loadSavedQuote();
  }

  Future<void> _loadSavedQuote() async {
    final json = await LocalStore.load();
    if (json != null) {
      setState(() {
        quote = Quote.fromJson(json);
        _syncClientToCtrls();
        _lineCtrls.clear();
        _ensureLineCtrls();
      });
    }
  }

  void _syncClientToCtrls() {
    _nameCtrl.text = quote.client.name;
    _addrCtrl.text = quote.client.address;
    _refCtrl.text = quote.client.reference;
  }

  void _ensureLineCtrls() {
    while (_lineCtrls.length < quote.items.length) {
      final i = _lineCtrls.length;
      final item = quote.items[i];
      final c = _LineCtrls();

      c.name.text = item.name;
      c.qty.text = item.quantity.toString();
      c.rate.text = item.rate.toString();
      c.disc.text = item.discount.toString();
      c.tax.text = item.taxPercent.toString();

      for (final ctrl in c.all) {
        ctrl.addListener(_onChange);
      }
      _lineCtrls.add(c);
    }
  }

  void _onChange() {
    quote.client
      ..name = _nameCtrl.text
      ..address = _addrCtrl.text
      ..reference = _refCtrl.text;

    for (var i = 0; i < _lineCtrls.length; i++) {
      final c = _lineCtrls[i];
      quote.items[i]
        ..name = c.name.text
        ..quantity = double.tryParse(c.qty.text) ?? 0
        ..rate = double.tryParse(c.rate.text) ?? 0
        ..discount = double.tryParse(c.disc.text) ?? 0
        ..taxPercent = double.tryParse(c.tax.text) ?? 0;
    }

    setState(() {});
  }

  void _addLine() {
    setState(() {
      quote.items.add(LineItem());
      _ensureLineCtrls();
    });
  }

  void _removeLine(int i) {
    setState(() {
      quote.items.removeAt(i);
      final removed = _lineCtrls.removeAt(i);
      for (final c in removed.all) {
        c.dispose();
      }
    });
  }

  void _showSendSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Send Quote",
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email Quote"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Simulated: Email Sent")),
                );
              },
            ),

            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
              ),
              title: const Text("Send via WhatsApp"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Simulated: WhatsApp Sent")),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("Download PDF"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Simulated: PDF Downloaded")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _lineCtrls) {
      for (final t in c.all) {
        t.dispose();
      }
    }
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget itemRow(int i) {
      final c = _lineCtrls[i];
      final item = quote.items[i];
      final total = money(
        quote.taxMode == TaxMode.exclusive
            ? item.totalExclusive()
            : item.totalInclusive(),
        code: quote.currencyCode,
      );

      if (width < 600) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: c.name,
                decoration: const InputDecoration(labelText: "Item Name"),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.qty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Qty"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: c.rate,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Rate"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.disc,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Disc"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: c.tax,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Tax %"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    total,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _removeLine(i),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: c.name,
                decoration: const InputDecoration(hintText: "Item"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c.qty,
                decoration: const InputDecoration(hintText: "Qty"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c.rate,
                decoration: const InputDecoration(hintText: "Rate"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c.disc,
                decoration: const InputDecoration(hintText: "Disc"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: c.tax,
                decoration: const InputDecoration(hintText: "Tax %"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Text(total, style: const TextStyle(fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () => _removeLine(i),
            ),
          ],
        ),
      );
    }

    final form = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Client Information",
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Client Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _refCtrl,
                    decoration: const InputDecoration(
                      labelText: "Reference",
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _addrCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Address",
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            "Items & Pricing",
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Chip(
                        label: const Text("Line Items"),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      DropdownButton<TaxMode>(
                        value: quote.taxMode,
                        onChanged: (v) => setState(() => quote.taxMode = v!),
                        items: const [
                          DropdownMenuItem(
                            value: TaxMode.exclusive,
                            child: Text("Tax Exclusive"),
                          ),
                          DropdownMenuItem(
                            value: TaxMode.inclusive,
                            child: Text("Tax Inclusive"),
                          ),
                        ],
                      ),
                      DropdownButton<QuoteStatus>(
                        value: quote.status,
                        onChanged: (v) => setState(() => quote.status = v!),
                        items: const [
                          DropdownMenuItem(
                            value: QuoteStatus.draft,
                            child: Text("Draft"),
                          ),
                          DropdownMenuItem(
                            value: QuoteStatus.sent,
                            child: Text("Sent"),
                          ),
                          DropdownMenuItem(
                            value: QuoteStatus.accepted,
                            child: Text("Accepted"),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (width >= 600)
                    Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Item",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Qty",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Rate",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Disc",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Tax %",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),

                  const SizedBox(height: 8),

                  Column(
                    children: [
                      for (int i = 0; i < quote.items.length; i++) itemRow(i),
                    ],
                  ),

                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Item"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Subtotal",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  money(quote.subtotal(), code: quote.currencyCode),
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await LocalStore.save(quote.toJson());
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Quote saved")),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                    ),

                    OutlinedButton.icon(
                      onPressed: _loadSavedQuote,
                      icon: const Icon(Icons.restore, color: Colors.white,),
                      label: const Text("Load",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () => _showSendSheet(context),
                      icon: const Icon(Icons.send),
                      label: const Text("Send"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final preview = Padding(
      padding: const EdgeInsets.all(16),
      child: QuotePreview(quote: quote),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Quote Builder")),
      body: width >= 1000
          ? Row(
              children: [
                Expanded(flex: 3, child: form),
                const VerticalDivider(),
                Expanded(flex: 2, child: preview),
              ],
            )
          : ListView(children: [form, const Divider(height: 1), preview]),
    );
  }
}

class _LineCtrls {
  final name = TextEditingController();
  final qty = TextEditingController(text: "1");
  final rate = TextEditingController(text: "0");
  final disc = TextEditingController(text: "0");
  final tax = TextEditingController(text: "0");

  List<TextEditingController> get all => [name, qty, rate, disc, tax];
}
