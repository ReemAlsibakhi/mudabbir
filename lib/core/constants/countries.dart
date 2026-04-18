// ═══════════════════════════════════════
// MUDABBIR — 22 دولة عربية
// ═══════════════════════════════════════

class Country {
  final String id;
  final String nameAr;
  final String currency;
  final String flag;
  final String langCode;
  final String dialCode;

  const Country({
    required this.id,
    required this.nameAr,
    required this.currency,
    required this.flag,
    required this.langCode,
    required this.dialCode,
  });
}

const List<Country> kCountries = [
  // الخليج
  Country(id: 'sa', nameAr: 'السعودية',    currency: 'ريال',  flag: '🇸🇦', langCode: 'ar-SA', dialCode: '+966'),
  Country(id: 'ae', nameAr: 'الإمارات',    currency: 'درهم',  flag: '🇦🇪', langCode: 'ar-AE', dialCode: '+971'),
  Country(id: 'kw', nameAr: 'الكويت',      currency: 'دينار', flag: '🇰🇼', langCode: 'ar-KW', dialCode: '+965'),
  Country(id: 'bh', nameAr: 'البحرين',     currency: 'دينار', flag: '🇧🇭', langCode: 'ar-BH', dialCode: '+973'),
  Country(id: 'om', nameAr: 'عُمان',       currency: 'ريال',  flag: '🇴🇲', langCode: 'ar-OM', dialCode: '+968'),
  Country(id: 'qa', nameAr: 'قطر',         currency: 'ريال',  flag: '🇶🇦', langCode: 'ar-QA', dialCode: '+974'),
  // المشرق
  Country(id: 'jo', nameAr: 'الأردن',      currency: 'دينار', flag: '🇯🇴', langCode: 'ar-JO', dialCode: '+962'),
  Country(id: 'lb', nameAr: 'لبنان',       currency: 'ليرة',  flag: '🇱🇧', langCode: 'ar-LB', dialCode: '+961'),
  Country(id: 'iq', nameAr: 'العراق',      currency: 'دينار', flag: '🇮🇶', langCode: 'ar-IQ', dialCode: '+964'),
  Country(id: 'sy', nameAr: 'سوريا',       currency: 'ليرة',  flag: '🇸🇾', langCode: 'ar-SY', dialCode: '+963'),
  Country(id: 'ps', nameAr: 'فلسطين',      currency: 'شيكل', flag: '🇵🇸', langCode: 'ar-PS', dialCode: '+970'),
  // شمال أفريقيا
  Country(id: 'eg', nameAr: 'مصر',         currency: 'جنيه',  flag: '🇪🇬', langCode: 'ar-EG', dialCode: '+20'),
  Country(id: 'ly', nameAr: 'ليبيا',       currency: 'دينار', flag: '🇱🇾', langCode: 'ar-LY', dialCode: '+218'),
  Country(id: 'tn', nameAr: 'تونس',        currency: 'دينار', flag: '🇹🇳', langCode: 'ar-TN', dialCode: '+216'),
  Country(id: 'dz', nameAr: 'الجزائر',     currency: 'دينار', flag: '🇩🇿', langCode: 'ar-DZ', dialCode: '+213'),
  Country(id: 'ma', nameAr: 'المغرب',      currency: 'درهم',  flag: '🇲🇦', langCode: 'ar-MA', dialCode: '+212'),
  Country(id: 'mr', nameAr: 'موريتانيا',   currency: 'أوقية', flag: '🇲🇷', langCode: 'ar-MR', dialCode: '+222'),
  // أفريقيا
  Country(id: 'sd', nameAr: 'السودان',     currency: 'جنيه',  flag: '🇸🇩', langCode: 'ar-SD', dialCode: '+249'),
  Country(id: 'so', nameAr: 'الصومال',     currency: 'شلن',   flag: '🇸🇴', langCode: 'ar-SO', dialCode: '+252'),
  Country(id: 'dj', nameAr: 'جيبوتي',      currency: 'فرنك',  flag: '🇩🇯', langCode: 'ar-DJ', dialCode: '+253'),
  Country(id: 'km', nameAr: 'جزر القمر',   currency: 'فرنك',  flag: '🇰🇲', langCode: 'ar-KM', dialCode: '+269'),
  Country(id: 'ye', nameAr: 'اليمن',       currency: 'ريال',  flag: '🇾🇪', langCode: 'ar-YE', dialCode: '+967'),
];

Country getCountryById(String id) =>
    kCountries.firstWhere((c) => c.id == id, orElse: () => kCountries.first);

Country? detectCountryFromLocale(String locale) {
  final lower = locale.toLowerCase();
  try {
    return kCountries.firstWhere(
      (c) => lower == c.langCode.toLowerCase() ||
             lower.startsWith(c.langCode.toLowerCase()),
    );
  } catch (_) {
    return null;
  }
}
