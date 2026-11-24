enum SpaceKind {
  personal('personal'),
  business('business');

  const SpaceKind(this.code);

  final String code;

  static SpaceKind fromCode(String? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => SpaceKind.personal,
    );
  }
}

enum AccountType {
  cash('cash'),
  bank('bank'),
  card('card'),
  wallet('wallet'),
  other('other');

  const AccountType(this.code);

  final String code;

  static AccountType fromCode(String? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => AccountType.other,
    );
  }
}

enum CategoryKind {
  income('income'),
  expense('expense');

  const CategoryKind(this.code);

  final String code;

  static CategoryKind fromCode(String? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => CategoryKind.expense,
    );
  }
}

enum CategoryScope {
  personal('personal'),
  business('business'),
  both('both');

  const CategoryScope(this.code);

  final String code;

  static CategoryScope fromCode(String? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => CategoryScope.both,
    );
  }

  bool appliesTo(SpaceKind spaceKind) {
    return this == CategoryScope.both ||
        (this == CategoryScope.personal && spaceKind == SpaceKind.personal) ||
        (this == CategoryScope.business && spaceKind == SpaceKind.business);
  }
}

enum TxnType {
  income('income'),
  expense('expense'),
  transfer('transfer');

  const TxnType(this.code);

  final String code;

  static TxnType fromCode(String? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => TxnType.expense,
    );
  }

  bool get isTransfer => this == TxnType.transfer;
}

enum RecurringFrequency {
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const RecurringFrequency(this.code);

  final String code;

  static RecurringFrequency fromCode(String? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => RecurringFrequency.monthly,
    );
  }
}

enum ThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const ThemePreference(this.code);

  final String code;

  static ThemePreference fromCode(String? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => ThemePreference.system,
    );
  }
}
