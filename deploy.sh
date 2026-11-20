#!/usr/bin/env bash
# 포켓몬 모닝 대시보드 GitHub Pages 배포 (저장소가 이미 존재할 때 실행)
# 사용: bash /workspace/pokemon-morning/deploy.sh
set -uo pipefail
REPO="ellenbobpark/pokemon-morning"
URL="https://ellenbobpark.github.io/pokemon-morning/"
cd "$(dirname "$0")" || exit 1

echo "== 1) 원격 확인"
if ! gh api "repos/$REPO" >/dev/null 2>&1; then
  echo "FAIL: $REPO 저장소가 없습니다. github.com/new 에서 public 저장소를 먼저 만들어야 합니다."
  exit 2
fi

echo "== 2) 푸시"
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$REPO.git"
git push -u origin main || { echo "FAIL: push 거부됨"; exit 3; }

echo "== 3) Pages 활성화"
gh api -X POST "repos/$REPO/pages" -f 'source[branch]=main' -f 'source[path]=/' 2>&1 | head -c 500
echo
gh api "repos/$REPO/pages" 2>&1 | head -c 400
echo

echo "== 4) 접속 확인"
for i in $(seq 1 30); do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$URL")
  echo "attempt $i: HTTP $code"
  [ "$code" = "200" ] && { echo "OK: $URL"; exit 0; }
  sleep 10
done
echo "TIMEOUT: $URL 이 아직 200이 아닙니다 (Pages 빌드 지연 또는 Pages 미활성)"
exit 4
