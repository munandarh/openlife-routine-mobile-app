class LocalDatabaseConfig {
  const LocalDatabaseConfig.recommended()
    : engine = 'drift',
      supportPackage = 'sqlite3_flutter_libs',
      notes = 'ponytail: lock Drift now; actual schema arrives in Sprint 3.';

  const LocalDatabaseConfig({
    required this.engine,
    required this.supportPackage,
    required this.notes,
  });

  final String engine;
  final String supportPackage;
  final String notes;
}
