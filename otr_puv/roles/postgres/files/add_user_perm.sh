
# читаем параметры
while [ -n "$1" ]
do
case "$1" in
-host) host_name="$2";;
-port) port_num="$2";;
-database) db_name="$2";;
-user) user_name="$2";;
-access) access_lvl="$2";;
-db_owner) owner_name="$2";;
esac
shift
done


#заполняем дефотные параметры
if [[ "$port_num" == "" ]]; then
  port_num="5432"
fi


#проверяем все ли параметры заданы
if [[ "$host_name" == "" ]]; then
  echo "Не задан параметр host"
  exit 1
elif [[ "$db_name" == "" ]]; then
  echo "Не задан параметр database"
  exit 1
elif [[ "$user_name" == "" ]]; then
  echo "Не задан параметр user"
  exit 1
elif [[ "$access_lvl" == "" ]]; then
  echo "Не задан параметр access"
  exit 1
elif [[ "$owner_name" == "" ]]; then
  echo "Не задан параметр db_owner"
  exit 1
fi


#выводим список введенных параметров (для контроля)
echo
echo

echo "-host" = $host_name
echo "-port" = $port_num
echo "-database" = $db_name
echo "-user" = $user_name
echo "-access" = $access_lvl
echo "-db_owner" = $owner_name

echo
echo

echo --host=$host_name --port=$port_num --username=$owner_name --no-password --dbname=$db_name --filename=run.sql

echo
echo


#меняем параметры в тексте скрипта
var1=s/user_name/"$user_name"/

sed $var1 make_script.txt > make_script_1.txt

if [[ "$access_lvl" == "write" ]]; then
    sed 's/SELECT_tables/SELECT, INSERT, UPDATE, DELETE/' make_script_1.txt > run.sql
elif [[ "$access_lvl" == "read" ]]; then
    sed 's/SELECT_tables/SELECT/' make_script_1.txt > run.sql
else
    echo "Incorrect access level" > run.sql
    exit 1
fi


#запускаем скрипт
psql --host=$host_name --port=$port_num --username=$owner_name --no-password --dbname=$db_name --file=run.sql

echo
echo


#удаляем временные файлы
rm make_script_1.txt
rm run.sql
