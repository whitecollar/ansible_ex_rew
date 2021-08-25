#!/bin/bash

##################################################
# Данный скрипт создает архив актуальных образов
# для дальнейшей передачи в виде архива в ДМЗ 
# Принцип работы:
#  1. смотрим во всех docker-compose.yml файлы и пулим новейшие образы
#  2. тэгируем их текущей датой и сохраняем всё в архив
# 
# Пример:
# ./save.sh
# Результат:
# otr_2021-04-14_16.tar.gz
# Примерное время: 6 минут
#
##################################################



set -e

CONFIGS=""

CONFIGS="$CONFIGS\n`cd infra && docker-compose config`"
CONFIGS="$CONFIGS\n`cd core && docker-compose config`"
CONFIGS="$CONFIGS\n`cd services && docker-compose config`"

IMAGES=$(echo "$CONFIGS" | grep 'image:'  | cut -d ' ' -f 6 | grep -v redis)
TAG=$(date +"%Y-%m-%d_%H")

BUNDLE=""

for x in $IMAGES; do
  REPO=$(echo "$x" | cut -d ":" -f 1)
  RELEASE_IMAGE="${REPO}:otr_${TAG}"
  
  docker pull "$x"
  docker tag "$x" "${RELEASE_IMAGE}"
  BUNDLE="${BUNDLE} ${RELEASE_IMAGE}"
done

echo Saving images to archive...
time docker save ${BUNDLE} | gzip > otr_${TAG}.tar.gz

