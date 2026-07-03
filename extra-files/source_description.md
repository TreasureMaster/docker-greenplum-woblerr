# Описание таблиц для источников

Итого предлагаю остановится на таких примерах:

В тестовой базе `test_ds` будет 2 таблицы в схеме `dbo`:
- `dbo.tcountry` - Справочник стран
- `dbo.tcurrency` - Справочник валют

В тестовой базе `test_cbas` будет 3 таблицы в схеме `public`:

- `public.vw_cbas_contr` - Представление, содержащее в себе финальные результаты всех проверок
- `public.vw_cbas_contr_hist_dtl` - Представление собирает поля из `verification_step` in ("FSSP_WAIT"), таблицы `cbas_contract_history` и `cbas_contract`
- `public.vw_cbas_contr_history` - Представление, содержащее в себе историю обработки по объектам
