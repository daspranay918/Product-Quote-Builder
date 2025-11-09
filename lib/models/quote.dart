import 'dart:convert';

enum TaxMode { exclusive, inclusive }
enum QuoteStatus { draft, sent, accepted }

class ClientInfo {
  String name;
  String address;
  String reference;

  ClientInfo({
    this.name = '',
    this.address = '',
    this.reference = '',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'reference': reference,
      };

  factory ClientInfo.fromMap(Map<String, dynamic> map) => ClientInfo(
        name: map['name'] ?? '',
        address: map['address'] ?? '',
        reference: map['reference'] ?? '',
      );
}

class LineItem {
  String name;
  double quantity;
  double rate;
  double discount;
  double taxPercent;

  LineItem({
    this.name = '',
    this.quantity = 1,
    this.rate = 0,
    this.discount = 0,
    this.taxPercent = 0,
  });

  double unitNet() => (rate - discount).clamp(-1e12, 1e12);

  double totalExclusive() {
    final base = unitNet() * quantity;
    final tax = base * (taxPercent / 100.0);
    return base + tax;
  }

  double totalInclusive() {
    final netUnit = unitNet();
    final divisor = 1 + (taxPercent / 100.0);
    final baseUnit = netUnit / divisor;
    final base = baseUnit * quantity;
    final tax = base * (taxPercent / 100.0);
    return base + tax;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'rate': rate,
        'discount': discount,
        'taxPercent': taxPercent,
      };

  factory LineItem.fromMap(Map<String, dynamic> map) => LineItem(
        name: map['name'] ?? '',
        quantity: (map['quantity'] ?? 0).toDouble(),
        rate: (map['rate'] ?? 0).toDouble(),
        discount: (map['discount'] ?? 0).toDouble(),
        taxPercent: (map['taxPercent'] ?? 0).toDouble(),
      );
}

class Quote {
  ClientInfo client;
  List<LineItem> items;
  TaxMode taxMode;
  QuoteStatus status;
  String currencyCode;

  Quote({
    ClientInfo? client,
    List<LineItem>? items,
    this.taxMode = TaxMode.exclusive,
    this.status = QuoteStatus.draft,
    this.currencyCode = 'INR',
  })  : client = client ?? ClientInfo(),
        items = items ?? [LineItem()];

  double subtotal() {
    if (taxMode == TaxMode.exclusive) {
      return items.fold(0.0, (sum, it) => sum + it.totalExclusive());
    } else {
      return items.fold(0.0, (sum, it) => sum + it.totalInclusive());
    }
  }

  String toJson() => jsonEncode({
        'client': client.toMap(),
        'items': items.map((e) => e.toMap()).toList(),
        'taxMode': taxMode.name,
        'status': status.name,
        'currencyCode': currencyCode,
      });

  factory Quote.fromJson(String json) {
    final map = jsonDecode(json);

    return Quote(
      client: ClientInfo.fromMap(map['client']),
      items: (map['items'] as List)
          .map((e) => LineItem.fromMap(e))
          .toList(),
      taxMode:
          map['taxMode'] == 'inclusive' ? TaxMode.inclusive : TaxMode.exclusive,
      status: QuoteStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => QuoteStatus.draft,
      ),
      currencyCode: map['currencyCode'] ?? 'INR',
    );
  }
}
