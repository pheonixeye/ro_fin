class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.symbol,
    this.decimals = 2,
  });

  final String code;
  final String nameAr;
  final String nameEn;
  final String symbol;
  final int decimals;

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;
}

const List<CurrencyOption> supportedCurrencies = <CurrencyOption>[
  CurrencyOption(
    code: 'EGP',
    nameAr: 'جنيه مصري',
    nameEn: 'Egyptian pound',
    symbol: 'ج.م',
  ),
  CurrencyOption(
    code: 'SAR',
    nameAr: 'ريال سعودي',
    nameEn: 'Saudi riyal',
    symbol: 'ر.س',
  ),
  CurrencyOption(
    code: 'AED',
    nameAr: 'درهم إماراتي',
    nameEn: 'UAE dirham',
    symbol: 'د.إ',
  ),
  CurrencyOption(
    code: 'KWD',
    nameAr: 'دينار كويتي',
    nameEn: 'Kuwaiti dinar',
    symbol: 'د.ك',
    decimals: 3,
  ),
  CurrencyOption(
    code: 'QAR',
    nameAr: 'ريال قطري',
    nameEn: 'Qatari riyal',
    symbol: 'ر.ق',
  ),
  CurrencyOption(
    code: 'BHD',
    nameAr: 'دينار بحريني',
    nameEn: 'Bahraini dinar',
    symbol: 'د.ب',
    decimals: 3,
  ),
  CurrencyOption(
    code: 'OMR',
    nameAr: 'ريال عماني',
    nameEn: 'Omani rial',
    symbol: 'ر.ع.',
    decimals: 3,
  ),
  CurrencyOption(
    code: 'JOD',
    nameAr: 'دينار أردني',
    nameEn: 'Jordanian dinar',
    symbol: 'د.أ',
    decimals: 3,
  ),
  CurrencyOption(
    code: 'MAD',
    nameAr: 'درهم مغربي',
    nameEn: 'Moroccan dirham',
    symbol: 'د.م.',
  ),
  CurrencyOption(
    code: 'DZD',
    nameAr: 'دينار جزائري',
    nameEn: 'Algerian dinar',
    symbol: 'د.ج',
  ),
  CurrencyOption(
    code: 'TND',
    nameAr: 'دينار تونسي',
    nameEn: 'Tunisian dinar',
    symbol: 'د.ت',
    decimals: 3,
  ),
  CurrencyOption(
    code: 'LYD',
    nameAr: 'دينار ليبي',
    nameEn: 'Libyan dinar',
    symbol: 'د.ل',
    decimals: 3,
  ),
  CurrencyOption(
    code: 'IQD',
    nameAr: 'دينار عراقي',
    nameEn: 'Iraqi dinar',
    symbol: 'ع.د',
    decimals: 3,
  ),
  CurrencyOption(
    code: 'LBP',
    nameAr: 'ليرة لبنانية',
    nameEn: 'Lebanese pound',
    symbol: 'ل.ل',
  ),
  CurrencyOption(
    code: 'USD',
    nameAr: 'دولار أمريكي',
    nameEn: 'US dollar',
    symbol: r'$',
  ),
  CurrencyOption(
    code: 'EUR',
    nameAr: 'يورو',
    nameEn: 'Euro',
    symbol: '€',
  ),
  CurrencyOption(
    code: 'GBP',
    nameAr: 'جنيه إسترليني',
    nameEn: 'British pound',
    symbol: '£',
  ),
];

CurrencyOption currencyFor(String code) {
  return supportedCurrencies.firstWhere(
    (currency) => currency.code == code,
    orElse: () => supportedCurrencies.first,
  );
}

int currencyDecimals(String code) => currencyFor(code).decimals;

String currencySymbol(String code) => currencyFor(code).symbol;
