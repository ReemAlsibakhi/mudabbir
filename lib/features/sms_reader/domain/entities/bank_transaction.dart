import 'package:equatable/equatable.dart';

enum TransactionType { debit, credit, unknown }

final class BankTransaction extends Equatable {
  final String          id;
  final TransactionType type;
  final double          amount;
  final String          description;
  final String          merchant;
  final DateTime        date;
  final String          rawSms;
  final bool            isProcessed;

  const BankTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.merchant,
    required this.date,
    required this.rawSms,
    this.isProcessed = false,
  });

  bool get isDebit  => type == TransactionType.debit;
  bool get isCredit => type == TransactionType.credit;

  @override
  List<Object?> get props =>
      [id, type, amount, description, merchant, date, isProcessed];
}
