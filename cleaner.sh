#!/bin/bash
source .env

data="`date '+%m%d%y'`"

# Чистим лог от старых записей (Clean old log records from)
echo > $LOG

# Делаем запись даты в лог (The date recorded in the log)
echo >> $LOG1
echo "---------=$data=---------" >> $LOG1
echo >> $LOG1

# бекапим базу на всякий
mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD asteriskcdrdb | gzip -9 > asteriskcdrdb_$data.sql.gz

[[ $? -ne 0 ]] && {
    echo "Что-то пошло не так.."
    exit 1
}

# Чистим asteriskcdrdb.cdr (clean asterisksdrdb.cdr)
if $MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "delete from asteriskcdrdb.cdr where calldate < DATE_SUB(NOW(), interval $NUMBER $TYPE);"; then
    echo >> $LOG1
    echo Старые записи из asteriskcdrdb.cdr успешно удалены >> $LOG1
    echo >> $LOG1
else
    echo Не удалось удалить старые записи из asteriskcdrdb.cdr >> $LOG1
    echo >> $LOG1
    exit 0
fi

# Чистим asteriskcdrdb.cel (clean asteriskcdrdb.cel)
if $MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "delete from asteriskcdrdb.cel where eventtime < DATE_SUB(NOW(), interval $NUMBER $TYPE);"; then
    echo Старые записи из asteriskcdrdb.cel успешно удалены >> $LOG1
    echo >> $LOG1
else
    echo Не удалось удалить старые записи из asteriskcdrdb.cel >> $LOG1
    echo >> $LOG1
    exit 0
fi

# Оптимизируем asteriskcdrdb (optimize asteriskcdrdb table)
if $MYSQLCHECK -u$MYSQL_USER -p$MYSQL_PASSWORD --optimize asteriskcdrdb; then
    echo База asteriskcdrdb успешно оптимизирована >> $LOG1
    echo >> $LOG1
else
    echo Не удалось оптимизировать базу asteriskcdrdb >> $LOG1
    echo >> $LOG1
    exit 0
fi

echo >> $LOG1
echo "----------Были удалены следующие файлы и папки----------" >> $LOG1

# Чистим папки от файлов записи (Records you want to delete, and empty folders)
find /var/spool/asterisk/monitor/ -name "*.wav*" -type f -mtime +$CLEAR_DAYS -print -delete >> $LOG1
find /var/spool/asterisk/monitor/ -type d -empty -print -delete >> $LOG1

# Выводим последние 10 000 записей из постоянного лога и копируем их во временный (Get the last 10,000 records from the permanent log file and copy it to temporary )
grep -A 1000 "$data" $LOG1 > $LOG
