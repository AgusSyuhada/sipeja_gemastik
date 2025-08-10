class Report {
  final ReporterInfo reporterInfo;
  final String address1;
  final AddressInfo address2;
  final String roadImageUrl;
  final int status;
  final String id;
  final String? description;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int aiPrediction;
  int upvotes;
  bool hasVoted;

  Report({
    required this.reporterInfo,
    required this.address1,
    required this.address2,
    required this.roadImageUrl,
    required this.upvotes,
    required this.status,
    required this.id,
    this.description,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.aiPrediction,
    this.hasVoted = false,
  });
}

class ReporterInfo {
  final String userId;
  final String name;
  final String profileUrl;

  ReporterInfo({
    required this.userId,
    required this.name,
    required this.profileUrl,
  });
}

class AddressInfo {
  final String villageSubdistrict;
  final String district;
  final String cityRegency;

  AddressInfo({
    required this.villageSubdistrict,
    required this.district,
    required this.cityRegency,
  });
}
