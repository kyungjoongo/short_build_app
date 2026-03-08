#!/bin/bash
set -e

# ── ShortsAI 빌드 & Google Drive 배포 스크립트 ──────────────────────────────

FLUTTER="/Users/gilzako/Downloads/flutter/bin/flutter"
PROJECT_DIR="/Users/gilzako/WebstormProjects/short_build_app"
APK_DIR="$PROJECT_DIR/build/app/outputs/flutter-apk"
GDRIVE_FOLDER="ShortsAI"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
APK_NAME="shortsai_${TIMESTAMP}.apk"

echo "══════════════════════════════════════════"
echo "  ShortsAI 빌드 & 배포"
echo "══════════════════════════════════════════"

# 1. 릴리즈 빌드
echo ""
echo "▶ [1/3] 릴리즈 APK 빌드 중..."
cd "$PROJECT_DIR"
$FLUTTER build apk --release

# 2. 타임스탬프 파일명으로 Google Drive 업로드
echo ""
echo "▶ [2/3] Google Drive 업로드 중... (gdrive:/$GDRIVE_FOLDER/$APK_NAME)"
rclone mkdir "gdrive:$GDRIVE_FOLDER"
rclone copyto "$APK_DIR/app-release.apk" "gdrive:$GDRIVE_FOLDER/$APK_NAME"

# 3. 최신 버전도 덮어쓰기 (항상 같은 이름으로 접근 가능)
rclone copyto "$APK_DIR/app-release.apk" "gdrive:$GDRIVE_FOLDER/shortsai_latest.apk"

echo ""
echo "══════════════════════════════════════════"
echo "  ✅ 배포 완료!"
echo "  📁 gdrive:/$GDRIVE_FOLDER/$APK_NAME"
echo "  📁 gdrive:/$GDRIVE_FOLDER/shortsai_latest.apk"
echo "══════════════════════════════════════════"
