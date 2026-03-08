class SceneScript {
  final int number;
  final String visualPrompt;  // fal.ai 에 넘길 영어 프롬프트
  final String caption;       // 화면에 표시할 자막
  final String narration;     // 보이스오버 텍스트
  String? videoUrl;           // 생성 후 채워짐

  SceneScript({
    required this.number,
    required this.visualPrompt,
    required this.caption,
    required this.narration,
    this.videoUrl,
  });

  SceneScript copyWith({
    String? visualPrompt,
    String? caption,
    String? narration,
    String? videoUrl,
  }) {
    return SceneScript(
      number: number,
      visualPrompt: visualPrompt ?? this.visualPrompt,
      caption: caption ?? this.caption,
      narration: narration ?? this.narration,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  factory SceneScript.fromJson(Map<String, dynamic> json, int index) {
    return SceneScript(
      number: (json['number'] as int?) ?? (index + 1),
      visualPrompt: json['visual'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      narration: json['narration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'visualPrompt': visualPrompt,
      'caption': caption,
      'narration': narration,
      'videoUrl': videoUrl,
    };
  }
}

class ShortScript {
  final String id;
  final String topic;
  final String title;
  final String hook;
  final List<SceneScript> scenes;
  final String callToAction;
  final DateTime createdAt;

  ShortScript({
    required this.id,
    required this.topic,
    required this.title,
    required this.hook,
    required this.scenes,
    required this.callToAction,
    required this.createdAt,
  });

  bool get allVideosGenerated => scenes.every((s) => s.videoUrl != null);
  int get generatedCount => scenes.where((s) => s.videoUrl != null).length;

  factory ShortScript.fromJson({
    required String id,
    required String topic,
    required Map<String, dynamic> json,
  }) {
    final scenesJson = json['scenes'] as List<dynamic>? ?? [];
    return ShortScript(
      id: id,
      topic: topic,
      title: json['title'] as String? ?? topic,
      hook: json['hook'] as String? ?? '',
      scenes: scenesJson
          .asMap()
          .entries
          .map((e) => SceneScript.fromJson(e.value as Map<String, dynamic>, e.key))
          .toList(),
      callToAction: json['callToAction'] as String? ?? '',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'title': title,
      'hook': hook,
      'scenes': scenes.map((s) => s.toMap()).toList(),
      'callToAction': callToAction,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
