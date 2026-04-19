abstract final class Country {
  const Country._();
}

final class CountryData {
  final String id, nameAr, currency, flag, langCode;
  const CountryData({
    required this.id, required this.nameAr, required this.currency,
    required this.flag, required this.langCode,
  });
}

const kCountries = [
  CountryData(id:'sa', nameAr:'السعودية',   currency:'ريال',  flag:'🇸🇦', langCode:'ar-SA'),
  CountryData(id:'ae', nameAr:'الإمارات',   currency:'درهم',  flag:'🇦🇪', langCode:'ar-AE'),
  CountryData(id:'kw', nameAr:'الكويت',     currency:'دينار', flag:'🇰🇼', langCode:'ar-KW'),
  CountryData(id:'bh', nameAr:'البحرين',    currency:'دينار', flag:'🇧🇭', langCode:'ar-BH'),
  CountryData(id:'om', nameAr:'عُمان',      currency:'ريال',  flag:'🇴🇲', langCode:'ar-OM'),
  CountryData(id:'qa', nameAr:'قطر',        currency:'ريال',  flag:'🇶🇦', langCode:'ar-QA'),
  CountryData(id:'jo', nameAr:'الأردن',     currency:'دينار', flag:'🇯🇴', langCode:'ar-JO'),
  CountryData(id:'lb', nameAr:'لبنان',      currency:'ليرة',  flag:'🇱🇧', langCode:'ar-LB'),
  CountryData(id:'iq', nameAr:'العراق',     currency:'دينار', flag:'🇮🇶', langCode:'ar-IQ'),
  CountryData(id:'sy', nameAr:'سوريا',      currency:'ليرة',  flag:'🇸🇾', langCode:'ar-SY'),
  CountryData(id:'ps', nameAr:'فلسطين',     currency:'شيكل', flag:'🇵🇸', langCode:'ar-PS'),
  CountryData(id:'eg', nameAr:'مصر',        currency:'جنيه',  flag:'🇪🇬', langCode:'ar-EG'),
  CountryData(id:'ly', nameAr:'ليبيا',      currency:'دينار', flag:'🇱🇾', langCode:'ar-LY'),
  CountryData(id:'tn', nameAr:'تونس',       currency:'دينار', flag:'🇹🇳', langCode:'ar-TN'),
  CountryData(id:'dz', nameAr:'الجزائر',    currency:'دينار', flag:'🇩🇿', langCode:'ar-DZ'),
  CountryData(id:'ma', nameAr:'المغرب',     currency:'درهم',  flag:'🇲🇦', langCode:'ar-MA'),
  CountryData(id:'mr', nameAr:'موريتانيا',  currency:'أوقية', flag:'🇲🇷', langCode:'ar-MR'),
  CountryData(id:'sd', nameAr:'السودان',    currency:'جنيه',  flag:'🇸🇩', langCode:'ar-SD'),
  CountryData(id:'so', nameAr:'الصومال',    currency:'شلن',   flag:'🇸🇴', langCode:'ar-SO'),
  CountryData(id:'dj', nameAr:'جيبوتي',     currency:'فرنك',  flag:'🇩🇯', langCode:'ar-DJ'),
  CountryData(id:'km', nameAr:'جزر القمر',  currency:'فرنك',  flag:'🇰🇲', langCode:'ar-KM'),
  CountryData(id:'ye', nameAr:'اليمن',      currency:'ريال',  flag:'🇾🇪', langCode:'ar-YE'),
];

CountryData getCountryById(String id) =>
    kCountries.firstWhere((c) => c.id == id, orElse: () => kCountries.first);

String getCurrency(String countryId) => getCountryById(countryId).currency;
