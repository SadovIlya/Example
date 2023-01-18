#!/bin/bash

LINE='Про важное'
URL=' https://it.is.mysite.ru'
CODE=$(curl -L --silent $URL | grep -q "$LINE" && echo "сущестует" || echo "не существует")
VAR=$(curl -s -o /dev/null -w "%{http_code}" $URL)

case $VAR in

  200)
    echo -n "На сайте $URL $CODE строка $LINE"
    ;;

  *)
    echo -n "Ошибка"
    ;;
esac