# Клинер старых записей в Elastix PBX

- переименовываем `.env.example` в `.env`
- заполняем данные базы и доступа к ней
- проверяем что пути, где лежат записи реально в `/var/spool/asterisk/monitor/`
- дамп базы снимается перед всеми последующими действиями и складывается тут же в папке (не забывайте их подчищать)
- выставите сколько дней хранить записи (`90` по дефолту)
- поставьте задачу на крон, например раз в месяц

пример:

```shell
01 00 * * 1 /srv/cleaner/cleaner.sh
```

### Автор \ Author
- **Vassiliy Yegorov** [vasyakrg](https://github.com/vasyakrg)
- [youtube](https://youtube.com/realmanual)
- [site](https://vk.com/realmanual)
- [telegram](https://t.me/realmanual)
- [any qiestions for my](https://t.me/realmanual_group)
