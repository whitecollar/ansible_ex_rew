Может сломаться дерево зависимостей из-за докера на CentOS 8.

Установка GitLab через docker-compose

Для установки GitLab с начало нужно клонировать репозиторий в папку, откуда мы запустим docker-compose.

Переходим в папку, куда склонируем репозиторий:
 cd /opt
 
После клонируем резпоиторий:
 git clone ssh://git@gitlab.otr.ru:2022/puvosp/infra-gitlab.git
 
Переходим в папку с уже склонированным репозиторием:

cd /opt/dpr-gitlab

В корне лежит структура папок, она необходима для монтирование волюмов внутри докер контейнеров, так же в папке certs лежат WL SSL сертификаты, для запуска Gitlab по https.

Далее выполняем команду:
 docker-compose -f ./docker-compose.yml up -d
 
Ждем завершения деплоя контейнеров, их будет 2, gitlab и gitlab-runner, за не надобностью в самом докер файле (docker-compose.yml) можно отредактировать параметры запуска и установки gitlab, задать административный пароль, указать папку для резервной копии , указать данные подключения gitlab-runner.
 
После деплоя контейнеров у нас по адресу https://dpr-gitlab.ot.ru поднялся контейнер с GitLab.

После запуска GitLab появилась возможность хранения своих докер образов в хранилище Gitlab Container Registry.

Перейдя в проект и зайдя во вкладку Packages/Docker Registry можно увидеть следующее сообщение:

There are no container images stored for this project
With the Container Registry, every project can have its own space to store its Docker images. More Information Quick Start If you are not already logged in, you need to authenticate to the Container Registry by using your GitLab username and password. If you have Two-Factor Authentication enabled, use a Personal Access Token instead of a password.

docker login registry-dpr-gitlab.otr.ru:5005


Сообщение говорит нам о том что для этого проекта пока нет никаких образов и с помощью реестра их можно хранить после авторизации.

Если сделать логин в репозиторий у нас появится возможность хранения своих докер образов, так выглядит процесс прохождения авторизации:

docker login registry-dpr-gitlab.otr.ru:5005
Username: user.name@otr.ru
Password: password

WARNING! Your password will be stored unencrypted in /root/.docker/config.json. Configure a credential helper to remove this warning. Seehttps://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

Все, мы авторизовались в реестре контейнеров теперь мы сможем пушить свои контейнеры в проект.

Если зайди во вкладку CI/CD нам станут доступны возможности работы с gitlab-runner для автоматической сборки и тестирования проектов

