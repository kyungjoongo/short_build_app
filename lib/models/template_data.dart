class TemplateCategory {
  final String id;
  final String name;
  final String emoji;
  final List<TemplateItem> templates;

  const TemplateCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.templates,
  });
}

class TemplateItem {
  final String topic;
  final String label;
  final int suggestedScenes;

  const TemplateItem({
    required this.topic,
    required this.label,
    this.suggestedScenes = 3,
  });
}

class TemplateData {
  static const List<TemplateCategory> categories = [
    TemplateCategory(
      id: 'food',
      name: '먹방/음식',
      emoji: '🍔',
      templates: [
        TemplateItem(topic: '한국 치킨 맛집 TOP 5', label: '치킨 맛집 TOP 5'),
        TemplateItem(topic: '편의점 신상 라면 리뷰', label: '편의점 신상 라면'),
        TemplateItem(topic: '1만원으로 먹을 수 있는 서울 맛집', label: '1만원 서울 맛집'),
        TemplateItem(topic: '집에서 5분만에 만드는 초간단 파스타', label: '5분 초간단 파스타'),
      ],
    ),
    TemplateCategory(
      id: 'travel',
      name: '여행',
      emoji: '✈️',
      templates: [
        TemplateItem(topic: '서울에서 꼭 가봐야 할 야경 명소 3곳', label: '서울 야경 명소'),
        TemplateItem(topic: '제주도 2박3일 가성비 여행 코스', label: '제주도 가성비 코스'),
        TemplateItem(topic: '일본 오사카 먹방 여행 추천', label: '오사카 먹방 여행'),
        TemplateItem(topic: '혼자 떠나기 좋은 국내 여행지 TOP 5', label: '혼자 여행지 TOP 5'),
      ],
    ),
    TemplateCategory(
      id: 'review',
      name: '제품리뷰',
      emoji: '📦',
      templates: [
        TemplateItem(topic: '아이폰 16 vs 갤럭시 S25 실사용 비교', label: '아이폰 vs 갤럭시'),
        TemplateItem(topic: '가성비 블루투스 이어폰 추천 TOP 3', label: '가성비 이어폰 TOP 3'),
        TemplateItem(topic: '최신 맥북 프로 한달 사용 솔직 후기', label: '맥북 프로 후기'),
      ],
    ),
    TemplateCategory(
      id: 'tips',
      name: '팁/노하우',
      emoji: '💡',
      templates: [
        TemplateItem(topic: '아침에 일어나자마자 해야 할 3가지 습관', label: '아침 3가지 습관'),
        TemplateItem(topic: '인스타 릴스 조회수 올리는 꿀팁', label: '릴스 조회수 꿀팁'),
        TemplateItem(topic: '돈 버는 사람들의 공통 습관 5가지', label: '돈 버는 습관 5가지'),
        TemplateItem(topic: '프레젠테이션 잘하는 법 3단계', label: '프레젠테이션 꿀팁'),
      ],
    ),
    TemplateCategory(
      id: 'daily',
      name: '일상/브이로그',
      emoji: '📹',
      templates: [
        TemplateItem(topic: '직장인의 하루 일과 브이로그', label: '직장인 하루 브이로그'),
        TemplateItem(topic: '카페에서 보내는 감성 일상', label: '카페 감성 일상'),
        TemplateItem(topic: '자취생의 하루 루틴', label: '자취생 하루 루틴'),
      ],
    ),
    TemplateCategory(
      id: 'beauty',
      name: '뷰티/패션',
      emoji: '💄',
      templates: [
        TemplateItem(topic: '데일리 메이크업 5분 완성 튜토리얼', label: '5분 데일리 메이크업'),
        TemplateItem(topic: '봄 코디 추천 OOTD 룩북', label: '봄 코디 룩북'),
        TemplateItem(topic: '피부 좋아지는 스킨케어 루틴', label: '스킨케어 루틴'),
      ],
    ),
    TemplateCategory(
      id: 'fitness',
      name: '운동/헬스',
      emoji: '💪',
      templates: [
        TemplateItem(topic: '집에서 하는 10분 전신 운동', label: '10분 전신 홈트'),
        TemplateItem(topic: '뱃살 빼는 최고의 운동 3가지', label: '뱃살 빼는 운동'),
        TemplateItem(topic: '헬스 초보가 꼭 알아야 할 운동 순서', label: '헬스 초보 가이드'),
      ],
    ),
    TemplateCategory(
      id: 'gaming',
      name: '게임',
      emoji: '🎮',
      templates: [
        TemplateItem(topic: '2025년 꼭 해봐야 할 모바일 게임 TOP 5', label: '모바일 게임 TOP 5'),
        TemplateItem(topic: '게임 실력 올리는 숨은 꿀팁', label: '게임 실력 꿀팁'),
        TemplateItem(topic: '무료 PC 게임 추천 BEST 3', label: '무료 PC 게임 추천'),
      ],
    ),
    TemplateCategory(
      id: 'pet',
      name: '동물/펫',
      emoji: '🐶',
      templates: [
        TemplateItem(topic: '강아지가 좋아하는 간식 TOP 5', label: '강아지 간식 TOP 5'),
        TemplateItem(topic: '고양이와 함께하는 일상 브이로그', label: '고양이 일상 브이로그'),
        TemplateItem(topic: '반려동물 키우기 전 꼭 알아야 할 것들', label: '반려동물 필수 정보'),
      ],
    ),
  ];
}
