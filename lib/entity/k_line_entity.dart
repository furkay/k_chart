import 'dart:convert';

import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  double open;
  double high;
  double low;
  double close;
  double vol;
  double change;
  double ratio;
  DateTime dateTime;

  KLineEntity({
    this.open,
    this.high,
    this.low,
    this.close,
    this.vol,
    this.change,
    this.ratio,
    int time,
  }) {
    dateTime = DateTime.fromMillisecondsSinceEpoch(time);
  }

  Map<String, dynamic> toMap() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'vol': vol,
      'change': change,
      'ratio': ratio,
      'time': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory KLineEntity.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return KLineEntity(
      open: map['open'],
      high: map['high'],
      low: map['low'],
      close: map['close'],
      vol: map['vol'],
      change: map['change'],
      ratio: map['ratio'],
      time: map['time'],
    );
  }

  String toJson() => json.encode(toMap());

  factory KLineEntity.fromJson(String source) =>
      KLineEntity.fromMap(json.decode(source));
}
