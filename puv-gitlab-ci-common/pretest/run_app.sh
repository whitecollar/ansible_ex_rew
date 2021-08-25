#!/bin/sh

# Запускаем БД
docker run -it -d --name $CI_PROJECT_NAME-$DB_IMAGE -p $DB_PORT:5432 $REPO_IMAGE:$DB_IMAGE
# Запускаем контейнер с приложением
docker run -it -d --name $CI_PROJECT_NAME -p $HOST_PORT:18080 -e DB_UFOS_HOST_PROP=$DB_UFOS_HOST_PROP -e DB_UFOS_PASS=$DB_UFOS_PASS -e DB_UFOS_USER=$DB_UFOS_USER $IMAGE_TAG_PRETEST

# Логинимся в веб-интерфейс, получаем код ответа
STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" -d '{"login": "ic","password": "l12345"}' -H "Content-Type: application/json" -X POST http://puv-dev-gitlab-runner.otr.ru:$HOST_PORT/services/rest-api/auth/authorization)
# Счётчик
count=0
# Код ответа для завершения джобы
ret=0
# Пока код ответа не придёт 200 выполняем проверку
until [ "$STATUS" = "200" ]; do
    echo "Waiting for UFOS pre-jetty to come up"
    # Логинимся в веб-интерфейс, получаем код ответа
    STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" -d '{"login": "ic","password": "l12345"}' -H "Content-Type: application/json" -X POST http://puv-dev-gitlab-runner.otr.ru:$HOST_PORT/services/rest-api/auth/authorization)
    # Увеличиваем счётчик
    count=$((count+1))
    # Как только счётчик станет больше 20, завершаем цикл и считаем, что предтест не завёлся.
    if [ $count -gt 20 ]; then
        # Делаем код ответа ошибочным
        ret=1
        echo "UFOS startup timed out!!!"
        # Прерываем цикл.
        break
    fi
    # Ждём 30 секунд перед следующим запросом
    sleep 30
done

# Выводим код ответа УФОС
echo "STATUS = " $STATUS

# Выходим с кодом ответа для джобы
exit $ret