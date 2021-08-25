#!/bin/sh
while IFS= read -r LINE
do
  # Проверка статуса "In development"
  CHECK=$(curl -u "$JIRA_USER":"$JIRA_PASSWD" -X GET --url 'https://job-jira.otr.ru/rest/api/2/issue/'"$LINE"'' | jq '.fields.status.name') 
    echo $LINE " status: " $CHECK
    if [ "$CHECK" = "\"В разработке\"" ]; then
      # Переводим задачу в статус "Ready in build"
      STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" -u "$JIRA_USER":"$JIRA_PASSWD" -X POST --data '{"transition":{"id":"171"}}' -H "Content-Type: application/json" --url 'https://job-jira.otr.ru/rest/api/2/issue/'"$LINE"'/transitions?expand=transitions.fields')
    fi
done < $FILE_TASKS