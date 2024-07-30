class Views {
  final String cleanInterval;
  final String viewName;
  final String viewId;

  Views({
    required this.cleanInterval,
    required this.viewName,
    required this.viewId,
  });

  factory Views.fromJson(Map<String, dynamic> json) {
    return Views(
      cleanInterval: json['clean_interval'],
      viewName: json['view_name'],
      viewId: json['view_id'],
    );
  }
}

class Pattern {
  final int pattern;
  final int timer;
  final List<Views> views;

  Pattern({
    required this.pattern,
    required this.timer,
    required this.views,
  });

  factory Pattern.fromJson(Map<String, dynamic> json) {
    var list = json['views'] as List;
    List<Views> viewsList = list.map((i) => Views.fromJson(i)).toList();

    return Pattern(
      pattern: json['pattern'],
      timer: json['timer'],
      views: viewsList,
    );
  }
}

class WashResponse {
  final List<Pattern> data;
  final String status;
  final String remarks;

  WashResponse({
    required this.data,
    required this.status,
    required this.remarks,
  });

  factory WashResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Pattern> patternsList = list.map((i) => Pattern.fromJson(i)).toList();

    return WashResponse(
      data: patternsList,
      status: json['status'],
      remarks: json['remarks'],
    );
  }
}
