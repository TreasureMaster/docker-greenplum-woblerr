# Исключения

Здесь описаны исключения раскатки. В реальном проекте нужно доработать.

1. Отключен скрипт `sh 'python3 generate_pxf.py'` в трубе `jks-automatic-pxf`, т.к. отсутствует информация для pxf в `adb-platform/sys_service/configs/load.sys_service.prm_cctn.cfg.sql`.
2. В `jks_greenplum` для трубы `jks-generate-roles-on-adb-prod` добавлены фильтры для схем `('rdv_rudata', 'stg_mkb_inv', 'stg_ofsa', 'stg_rudata')` в файле `role_generator.py` из репо `dwh-service-test`. Это костыль, потом нужно удалить, когда этих схем не будет в коде dwh-gp.