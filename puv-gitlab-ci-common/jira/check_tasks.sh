#!/bin/sh
# Выкусымаем все таски, которые были закоммичены с момента предыдущего тега, исключая первый тэг.
if [ "$NUMBER" != "0" ]
then
  git log $(git describe --tags --abbrev=0)..HEAD --oneline | grep -oE "PFRPUV-[0-9]+" | awk '!x[$0]++' | tee $FILE_TASKS
fi
# Дописываем пустую строку в файл(без нее не подхватывается последняя задача из файла) 
echo $FILE_TASKS
set +x
sed -i '$a\' $FILE_TASKS