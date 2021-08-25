#!/bin/bash

###########################################################################
# Данный скрипт загружает образы из архива и перетегирует
# из для дальнейшего обновления запущенных контейнеров
# Принцип работы:
#  1. смотрим во всех docker-compose.yml файлы и тегиеруем ТЕКУЩИЕ образы как old
#  2. загружаем образы из файла 
#  3. тегиурем загруженные образы как otr
#  4. обновляем только те контейнеры, которые изменились
#  5. infra НЕ перезапускаются автоматически
#
# Предусловия:
#   - папки infra, core, service
#   - каждая папка содержит .env файлы в которых SERVICE_TAG, CORE_TAG, CONSUL_TAG и INFRA_TAG строго указано как otr 
#
# Пример:
# ./load.sh otr_2021-04-14_16.tar.gz
# Результат:
# Старые образы имеют название old, новые otr
# Примерное время: 3 минуты
#
##################################################

set -e

FILE="$1"

CONFIGS=""

CONFIGS="$CONFIGS\n`cd infra && docker-compose config`"
CONFIGS="$CONFIGS\n`cd core && docker-compose config`"
CONFIGS="$CONFIGS\n`cd services && docker-compose config`"

IMAGES=$(echo "$CONFIGS" | grep 'image:'  | cut -d ' ' -f 6 | grep -v redis)
TAG=$(basename "${FILE}" | sed s/\.tar\.gz// | sed s/\.tar//)


for x in $IMAGES; do
  REPO=$(echo "$x" | cut -d ":" -f 1)
  RUNNING_IMAGE="${REPO}:otr"
  CURRENT_IMAGE="${REPO}:old"
  
  docker tag "${RUNNING_IMAGE}" "${CURRENT_IMAGE}" || true
  docker image rm "${RUNNING_IMAGE}" || true
done

echo Loading images from archive....
time docker load -i "${FILE}"

for x in $IMAGES; do
  REPO=$(echo "$x" | cut -d ":" -f 1)
  RUNNING_IMAGE="${REPO}:otr"
  NEW_IMAGE="${REPO}:${TAG}"
  
  docker tag "${NEW_IMAGE}" "${RUNNING_IMAGE}" || true
  docker image rm "${NEW_IMAGE}" || true
done


(cd core && docker-compose up -d)
(cd services && docker-compose up -d)