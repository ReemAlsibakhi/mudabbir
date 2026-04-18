// ═══════════════════════════════════════
// MUDABBIR — فئات المصاريف
// ═══════════════════════════════════════

class ExpenseCategory {
  final String id;
  final String nameAr;
  final String icon;
  final int color; // ARGB
  final bool isFixed; // ثابت شهري
  final bool isVariable; // متغير يومي

  const ExpenseCategory({
    required this.id,
    required this.nameAr,
    required this.icon,
    required this.color,
    this.isFixed = false,
    this.isVariable = true,
  });
}

const List<ExpenseCategory> kExpenseCategories = [
  // متغير يومي
  ExpenseCategory(id: 'food',         nameAr: 'طعام وبقالة',        icon: '🛒', color: 0xFF10B981),
  ExpenseCategory(id: 'restaurants',  nameAr: 'مطاعم وكافيهات',    icon: '🍽️', color: 0xFFF59E0B),
  ExpenseCategory(id: 'transport',    nameAr: 'مواصلات وبنزين',    icon: '🚗', color: 0xFFF97316),
  ExpenseCategory(id: 'shopping',     nameAr: 'تسوق وملابس',       icon: '🛍️', color: 0xFFEC4899),
  ExpenseCategory(id: 'health',       nameAr: 'صحة وطب',           icon: '🏥', color: 0xFFEF4444),
  ExpenseCategory(id: 'entertainment',nameAr: 'ترفيه واشتراكات',   icon: '🎬', color: 0xFF8B5CF6),
  ExpenseCategory(id: 'children',     nameAr: 'أطفال ومصروف جيب', icon: '👶', color: 0xFF06B6D4),
  ExpenseCategory(id: 'zakat',        nameAr: 'زكاة وصدقات',       icon: '🌙', color: 0xFFD97706),
  ExpenseCategory(id: 'travel',       nameAr: 'سفر وسياحة',        icon: '✈️', color: 0xFF0EA5E9),
  ExpenseCategory(id: 'gold',         nameAr: 'ذهب ومجوهرات',      icon: '💍', color: 0xFFEAB308),
  ExpenseCategory(id: 'other',        nameAr: 'أخرى',               icon: '📦', color: 0xFF94A3B8),
  // ثابت شهري
  ExpenseCategory(id: 'rent',         nameAr: 'إيجار وسكن',        icon: '🏠', color: 0xFF3B82F6, isFixed: true, isVariable: false),
  ExpenseCategory(id: 'bills',        nameAr: 'فواتير وخدمات',     icon: '📱', color: 0xFF06B6D4, isFixed: true),
  ExpenseCategory(id: 'loans',        nameAr: 'قروض وأقساط',       icon: '💳', color: 0xFF64748B, isFixed: true, isVariable: false),
  ExpenseCategory(id: 'education',    nameAr: 'تعليم ومدارس',      icon: '🎓', color: 0xFF8B5CF6, isFixed: true),
  ExpenseCategory(id: 'jameya',       nameAr: 'جمعية',              icon: '🤝', color: 0xFF059669, isFixed: true, isVariable: false),
  ExpenseCategory(id: 'bnpl',         nameAr: 'تابي وتمارا',       icon: '💰', color: 0xFFDC2626, isFixed: true, isVariable: false),
];

List<ExpenseCategory> get variableCategories =>
    kExpenseCategories.where((c) => c.isVariable).toList();

List<ExpenseCategory> get fixedCategories =>
    kExpenseCategories.where((c) => c.isFixed).toList();

ExpenseCategory getCategoryById(String id) =>
    kExpenseCategories.firstWhere((c) => c.id == id,
        orElse: () => kExpenseCategories.last);
