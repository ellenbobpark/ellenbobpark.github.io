#!/usr/bin/env bash
# 포켓몬 모닝 대시보드 재배포 스크립트
# 사용: bash /workspace/pokemon-morning/redeploy.sh "커밋 메시지"
# 저장소: https://github.com/ellenbobpark/ellenbobpark.github.io (public, 사용자 사이트 저장소 → push 하면 Pages 자동 배포)
set -uo pipefail
REPO="ellenbobpark/ellenbobpark.github.io"
URL="https://ellenbobpark.github.io/"
cd "$(dirname "$0")" || exit 1

# 이 폴더의 index.html 이 원본.
# 워크스페이스 루트의 단일 파일 사본은 이미지 상대경로만 바꿔서 동기화한다.
if [ -f index.html ]; then
  sed 's|\./images/|./pokemon-morning/images/|g' index.html > "../나예-다예-모닝-대시보드.html.tmp" \
    && mv "../나예-다예-모닝-대시보드.html.tmp" "../나예-다예-모닝-대시보드.html"
fi

git add -A
git -c user.name="ellenbobpark" -c user.email="ellenbobpark@users.noreply.github.com" commit -m "${1:-대시보드 업데이트}" || echo "(변경 없음)"
git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$REPO.git"
git push origin main || { echo "FAIL: push 거부됨"; exit 3; }

echo "== Pages 빌드 대기"
for i in $(seq 1 30); do
  st=$(gh api "repos/$REPO/pages/builds/latest" -q '.status' 2>/dev/null)
  code=$(curl -s -o /dev/null -w '%{http_code}' "$URL")
  echo "attempt $i: build=$st http=$code"
  [ "$st" = "built" ] && [ "$code" = "200" ] && { echo "OK: $URL"; exit 0; }
  sleep 10
done
echo "TIMEOUT: $URL 확인 필요"
exit 4
