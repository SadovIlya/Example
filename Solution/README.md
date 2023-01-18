- 1. Напишите демон systemd, который будет поддерживать работу процесса и перезапускаться в случае выхода из строя процесса. Процесс любой

#### Создадим скрипт который мы будем запускать как службу. 
> Скрипт будет записывать текущую дату в директорию tmp раз в минуту
``` sh
sudo nano /opt/script.sh 
```

```sh
#!/bin/bash
while :
do
  touch /tmp/"$(date +"%d-%m-%Y-%r")"
  sleep 60
done
```
#### Разрешаем запуск нашего скрипта
``` sh 
sudo chmod +x /opt/script.sh
```

#### Создадим Unit файл в /etc/systemd/system
``` sh 
sudo nano /etc/systemd/system/script.service
```

#### Создаём Unit
``` sh 
[Unit]
Description=Script
After=default.target

[Service]
User=admin
Restart=on-failure
ExecStart=/opt/script.sh
RestartSec=10s

[Install]
WantedBy=default.target
```

#### Запускаем наш сервис
``` sh 
sudo systemctl status script.service
```
#### Проверяем что всё работает 
``` sh 
sudo systemctl status script.service
```
#### Добавляем сервис в автозагрузку
``` sh 
sudo systemctl enable script.service
```
#### Проверим что сервис перезапустится при ошибке
``` sh
sudo kill -KILL 776
```
#### Через 10 секунд сервис перезапущен

``` sh 

admin@ip-172-31-86-162:~$ sudo systemctl status script.service
● script.service - Script
     Loaded: loaded (/etc/systemd/system/script.service; enabled; vendor preset: enabled)
     Active: activating (auto-restart) (Result: signal) since Tue 2023-01-17 22:58:57 UTC; 9s ago
    Process: 544 ExecStart=/opt/script.sh (code=killed, signal=KILL)
   Main PID: 544 (code=killed, signal=KILL)
        CPU: 5ms
admin@ip-172-31-86-162:~$ sudo systemctl status script.service
● script.service - Script
     Loaded: loaded (/etc/systemd/system/script.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2023-01-17 22:59:07 UTC; 65ms ago
   Main PID: 628 (script.sh)
      Tasks: 2 (limit: 1148)
     Memory: 532.0K
        CPU: 4ms
     CGroup: /system.slice/script.service
             ├─628 /bin/bash /opt/script.sh
             └─631 sleep 60
```
- 2. Перепишите Dockerfile

```dockerfile
FROM node:16

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY ./src .

ENTRYPOINT ["npm", "run"]

CMD ["prod"]
```

3. Напишите простой ansible-скрипт по развороту prometheus сервера с БД postgres на debian 11 c комментариями для выбранных шагов
```yaml
- name: ansible
  hosts: all
  become: true
  tasks:

    - name: Install docker #Устанавливаем Docker, Docker-compose
      ansible.builtin.include_tasks: 
        file: install-docker.yml

    - name: Create folders #Создаём папки в которых будет Docker-compose и конфиги
      ansible.builtin.include_tasks: 
        file: create-folders.yml

    - name: Create files #Копируем файлы на удалённый узел
      ansible.builtin.include_tasks: 
        file: create-files.yml

    - name: docker compose #Запускаем всё в Docker-compose
      docker_compose:
        project_src: /opt/dockercompose
        state: present
        restarted: true
      tags: dockercompose
```

4. Напишите bash-скрипт с обработкой статусов и ошибок, который проверить, что на странице https://it.is.mysite.ru есть текст "Про важное". Прокомментировать команды скрипта.
```sh
#!/bin/bash

LINE='Про важное' #Переменная со строкой которую ищем
URL=' https://it.is.mysite.ru' #url по которому ищем
CODE=$(curl -L --silent $URL | grep -q "$LINE" && echo "сущестует" || echo "не существует")#Запрос для поиска строки на сайте
VAR=$(curl -s -o /dev/null -w "%{http_code}" $URL) #Запрос кода ответа сайта

case $VAR in #Проверяем содержит ли код ответа 200, если да то парсим страницу, если нет то ошибка.

  200)
    echo -n "На сайте $URL $CODE строка $LINE"
    ;;

  *)
    echo -n "Ошибка"
    ;;
esac
```