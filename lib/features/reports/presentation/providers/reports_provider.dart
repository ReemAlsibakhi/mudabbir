import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportMonthProvider = StateProvider<DateTime>((_) => DateTime.now());
