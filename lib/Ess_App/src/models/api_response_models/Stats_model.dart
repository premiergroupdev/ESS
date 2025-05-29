class StatsModel {
  final int travelCount;
  final int leaveCount;
  final int loanCount;
  final int educationCount;
  final int capexCount;
  final int advanceCount;

  StatsModel({
    required this.travelCount,
    required this.leaveCount,
    required this.loanCount,
    required this.educationCount,
    required this.capexCount,
    required this.advanceCount,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      travelCount: json['travelCount'] ?? 0,
      leaveCount: json['leaveCount'] ?? 0,
      loanCount: json['loanCount'] ?? 0,
      educationCount: json['educationCount'] ?? 0,
      capexCount: json['capexCount'] ?? 0,
      advanceCount: json['advanceCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelCount': travelCount,
      'leaveCount': leaveCount,
      'loanCount': loanCount,
      'educationCount': educationCount,
      'capexCount': capexCount,
      'advanceCount': advanceCount,
    };
  }


  List<Map<String, String>> toCardList() {
    print([
      {'title': 'Travel', 'count': travelCount.toString()},
      {'title': 'Leave', 'count': leaveCount.toString()},
      {'title': 'Loan', 'count': loanCount.toString()},
      {'title': 'Education', 'count': educationCount.toString()},
      {'title': 'Capex', 'count': capexCount.toString()},
      {'title': 'Advance', 'count': advanceCount.toString()},
    ]);
    return [
      {'title': 'Travel', 'count': travelCount.toString()},
      {'title': 'Leave', 'count': leaveCount.toString()},
      {'title': 'Loan', 'count': loanCount.toString()},
      {'title': 'Education', 'count': educationCount.toString()},
      {'title': 'Capex', 'count': capexCount.toString()},
      {'title': 'Advance', 'count': advanceCount.toString()},
    ];

  }
}
