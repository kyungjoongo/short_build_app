class Constants {
  // Fal.ai API Token (기존 앱과 동일)
  static const String falApiToken = '6e71d7f2-59df-4a42-9e96-54e43d668edb:22de323bd0b5a36e513084a2f0358c99';

  // OpenAI API Key (script generation)
  static const String openaiApiKey = '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';

  // Firestore Collections (기존 앱과 공유)
  static const String usersCollection = 'users2';
  static const String shortsCollection = 'generated_shorts';

  // App
  static const String appName = 'ShortsAI';

  // OpenAI model
  static const String openAiModel = 'gpt-4o';

  // fal.ai text-to-video 모델 (Grok Imagine Video — 음성 자동 포함, 저렴)
  static const String falTextToVideoModel = 'xai/grok-imagine-video/text-to-video';

  // 크레딧 비용
  static const double scriptCreditCost = 1.0;   // 스크립트 생성
  static const double videoCreditCost = 2.0;     // 씬당 비디오 생성
}
