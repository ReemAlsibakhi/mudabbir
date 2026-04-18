import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const bg = Color(0xFF080E1A);
  static const surface1 = Color(0xFF0F1724);
  static const surface2 = Color(0xFF152033);
  static const surface3 = Color(0xFF1A2840);
  static const surface4 = Color(0xFF1F3050);

  // Accents
  static const accent = Color(0xFF2563EB);
  static const accent2 = Color(0xFF0EA5E9);
  static const accent3 = Color(0xFF06D6A0);

  // Semantic
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFF43F5E);
  static const gold = Color(0xFFF59E0B);
  static const orange = Color(0xFFF97316);
  static const purple = Color(0xFF8B5CF6);

  // Text
  static const textPrimary = Color(0xFFE6EDF3);
  static const textSecondary = Color(0xFF8B949E);
  static const textTertiary = Color(0xFF484F58);

  // Border
  static const border = Color(0x14FFFFFF);

  // Gradients
  static const accentGradient = LinearGradient(
    colors: [accent, accent2],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  static const greenGradient = LinearGradient(
    colors: [green, accent3],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  // Category colors
  static const catFood = Color(0xFF10B981);
  static const catRent = Color(0xFF3B82F6);
  static const catTransport = Color(0xFFF97316);
  static const catEducation = Color(0xFF8B5CF6);
  static const catHealth = Color(0xFFEF4444);
  static const catRestaurants = Color(0xFFF59E0B);
  static const catShopping = Color(0xFFEC4899);
  static const catBills = Color(0xFF06B6D4);
  static const catLoans = Color(0xFF64748B);
  static const catZakat = Color(0xFFD97706);
  static const catOther = Color(0xFF94A3B8);
}
