import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/short_script.dart';

class ScriptService {
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';

  Future<ShortScript> generateScript(String topic, {int sceneCount = 3}) async {
    final sceneExamples = List.generate(sceneCount, (i) => '''    {
      "number": ${i + 1},
      "visual": "cinematic description for AI video generation in English, 1-2 sentences",
      "caption": "short punchy caption text for this scene",
      "narration": "voice-over narration for this scene"
    }''').join(',\n');

    final prompt = '''You are an expert viral YouTube Shorts / TikTok / Instagram Reels script writer.

Create a $sceneCount-scene short video script about: "$topic"

Requirements:
- Each scene should be 5-6 seconds of visual content
- Hook must grab attention in first 2 seconds
- Visual prompts must be cinematic, detailed (English only, for AI video generation)
- Captions should be punchy and readable in 3 seconds
- Vertical 9:16 format

Return ONLY valid JSON in this exact format (no markdown, no explanation):
{
  "title": "catchy title for the video",
  "hook": "first 2-3 seconds hook text shown on screen",
  "scenes": [
$sceneExamples
  ],
  "callToAction": "follow/subscribe/comment call to action"
}''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer ${Constants.openaiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': Constants.openAiModel,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text = data['choices'][0]['message']['content'] as String;

    // JSON 파싱
    final jsonStr = _extractJson(text);
    final scriptJson = jsonDecode(jsonStr) as Map<String, dynamic>;

    return ShortScript.fromJson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: topic,
      json: scriptJson,
    );
  }

  String _extractJson(String text) {
    // 마크다운 코드 블록 제거
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = codeBlockRegex.firstMatch(text);
    if (match != null) return match.group(1)!.trim();

    // 중괄호로 시작하는 JSON 직접 추출
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1) {
      return text.substring(start, end + 1);
    }
    return text.trim();
  }
}
