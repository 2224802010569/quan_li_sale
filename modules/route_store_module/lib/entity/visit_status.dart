enum VisitStatus {
  pending,
  visited,
  skipped;

  factory VisitStatus.fromString(String value) {
    switch (value) {
      case 'visited':
        return VisitStatus.visited;
      case 'skipped':
        return VisitStatus.skipped;
      case 'pending':
      default:
        return VisitStatus.pending;
    }
  }

  String toMap() {
    return name;
  }
}
