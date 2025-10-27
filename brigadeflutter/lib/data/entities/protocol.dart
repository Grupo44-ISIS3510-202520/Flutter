class Protocol {
  final String id;
  final String name;
  final String url;
  final String version;
  final DateTime? lastUpdate;

  Protocol({
    required this.id,
    required this.name,
    required this.url,
    required this.version,
    this.lastUpdate,
  });
}
