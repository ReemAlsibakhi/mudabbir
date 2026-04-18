// ═══════════════════════════════════════
// MUDABBIR — مراحل الحياة
// ═══════════════════════════════════════

enum LifeStage {
  single,    // أعزب
  engaged,   // مخطوب
  married,   // متزوج
  family,    // أسرة مع أطفال
}

extension LifeStageExt on LifeStage {
  String get nameAr {
    switch (this) {
      case LifeStage.single:   return 'أعزب';
      case LifeStage.engaged:  return 'مخطوب';
      case LifeStage.married:  return 'متزوج';
      case LifeStage.family:   return 'أسرة مع أطفال';
    }
  }

  String get icon {
    switch (this) {
      case LifeStage.single:   return '🧑';
      case LifeStage.engaged:  return '💍';
      case LifeStage.married:  return '👫';
      case LifeStage.family:   return '👨‍👩‍👧‍👦';
    }
  }

  String get description {
    switch (this) {
      case LifeStage.single:
        return 'أدر مصاريفك الشخصية ووفّر لأهدافك';
      case LifeStage.engaged:
        return 'خطط لتكاليف زواجك وحقق حلمك';
      case LifeStage.married:
        return 'نسّق ميزانيتك مع شريك حياتك';
      case LifeStage.family:
        return 'أدر مصاريف أسرتك بذكاء واكتمال';
    }
  }

  // هل يظهر هدف الزواج؟
  bool get showMarriageGoal =>
      this == LifeStage.single || this == LifeStage.engaged;

  // هل يظهر تعليم الأبناء؟
  bool get showChildrenGoals =>
      this == LifeStage.family;

  // هل عنده شريك؟
  bool get hasPartner =>
      this == LifeStage.married || this == LifeStage.family;

  // حقل الدخل — اسم الحقل الأول
  String get incomeLabel1 {
    switch (this) {
      case LifeStage.single:
      case LifeStage.engaged:
        return 'راتبك الشهري';
      default:
        return 'دخل الزوج';
    }
  }

  // هل يظهر حقل الدخل الثاني (الزوجة)؟
  bool get showPartnerIncome => hasPartner;

  // أسلوب المخاطبة
  String greet(String name) {
    switch (this) {
      case LifeStage.single:
      case LifeStage.engaged:
        return 'يا $name';
      default:
        return 'أبو $name';
    }
  }
}
