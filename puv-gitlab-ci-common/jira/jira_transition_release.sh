#!/bin/sh
while IFS= read -r LINE
do
  # Проверка статуса "Ready in build"
  CHECK=$(curl -u "$JIRA_USER":"$JIRA_PASSWD" -X GET --url 'https://job-jira.otr.ru/rest/api/2/issue/'"$LINE"'' | jq '.fields.status.name') 
    echo $LINE " status: " $CHECK
    if [ "$CHECK" = "\"Ready in build\"" ]; then
      # Переводим задачу в статус "На тестирование"
      STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" -u "$JIRA_USER":"$JIRA_PASSWD" -X POST --data '{"transition":{"id":"161"}}' -H "Content-Type: application/json" --url 'https://job-jira.otr.ru/rest/api/2/issue/'"$LINE"'/transitions?expand=transitions.fields')
      echo "transition issue: " $LINE " status: " $STATUS
      if [ "$STATUS" = "204" ]; then
        # Проставляем задаче версию
        RESULT=$(curl -u "$JIRA_USER":"$JIRA_PASSWD" -X PUT --data "{\"fields\":{\"fixVersions\":[{\"name\": \"pfrpuv-${TAG_VERSION}\"}]}}" -H "Content-Type: application/json" --url 'https://job-jira.otr.ru/rest/api/2/issue/'"$LINE")
        echo "Upgrade release result: " $LINE 
      fi
    fi
done < $FILE_TASKS