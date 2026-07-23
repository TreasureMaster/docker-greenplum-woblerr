--dbo SCHEMA
--1
DO
$do$
BEGIN
    IF NOT EXISTS(
        SELECT schema_Name
          FROM information_schema.schemata
          WHERE schema_Name = 'dbo'
      )
    THEN
      EXECUTE 'CREATE SCHEMA dbo';
      
    END IF;
END
$do$;

--DESCRIPTION Схема для данных - dbo

drop table if exists  dbo.tCurrency;

CREATE TABLE dbo.tcurrency (
  "CurrencyID" numeric(15) NULL,
  "Name" varchar(255) NULL,
  "Brief" char(25) NULL,
  "Number" char(10) NULL,
  "ISONumber" char(10) NULL,
  "CashBrief" char(10) NULL,
  "Scale" int4 NULL,
  "CountDayYear" int4 NULL,
  "NameHi1" char(30) NULL,
  "NameHi24" char(30) NULL,
  "NameHi5" char(30) NULL,
  "NameLo1" char(30) NULL,
  "NameLo24" char(30) NULL,
  "NameLo5" char(30) NULL,
  "Flags" int4 NULL,
  "InstrumentID" numeric(15) NULL
  );


comment on table dbo.tcurrency is 'Справочник валют';

comment on column dbo.tcurrency."CurrencyID" is 'идентификатор валюты';
comment on column dbo.tcurrency."Name" is 'Наименование валюты';
comment on column dbo.tcurrency."Brief" is 'Сокращение валюты';
comment on column dbo.tcurrency."Number" is 'Альтернативный код валюты';
comment on column dbo.tcurrency."ISONumber" is 'Код ISO валюты';
comment on column dbo.tcurrency."CashBrief" is 'Альтернативное наименование для сделок с наличной валютой';
comment on column dbo.tcurrency."Scale" is 'Количество знаков после запятой';
comment on column dbo.tcurrency."CountDayYear" is 'Число дней в году';
comment on column dbo.tcurrency."NameHi1" is 'Имя целой части для 1';
comment on column dbo.tcurrency."NameHi24" is 'Имя целой части для 2-4';
comment on column dbo.tcurrency."NameHi5" is 'Имя целой части для 5';
comment on column dbo.tcurrency."NameLo1" is 'Имя дробной части для 1';
comment on column dbo.tcurrency."NameLo24" is 'Имя дробной части для 2-4';
comment on column dbo.tcurrency."NameLo5" is 'Имя дробной части для 5';
comment on column dbo.tcurrency."Flags" is 'Флаги';
comment on column dbo.tcurrency."InstrumentID" is 'Идентификатор финансовой операции';


INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000059, 'Нидерландский антильский гульден                            ', 'ANG                      ', '532       ', '532       ', 'ANG       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000035, 'НОВЫЕ ТУРЕЦКИЕ ЛИРЫ                                         ', 'TRY                      ', '949       ', '949       ', 'TRY       ', 2, 360, 'НОВЫЕ ТУРЕЦКИЕ ЛИРЫ           ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000019, 'УЗБЕКСКИЙ СУМ                                               ', 'UZS                      ', '860       ', '860       ', 'UZS       ', 2, 360, 'УЗБЕКСКИЙ СУМ                 ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001302, 'Японские иены', 'JPY                      ', '392       ', '392       ', '90001302  ', 0, 360, 'японская йена                 ', 'японских йены                 ', 'японских йен                  ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001632, 'Польский злотый', 'PZL                      ', '098       ', '098       ', '90001632  ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(280, 'Немецкие марки', 'DEM1                     ', '280       ', '280       ', 'DEC       ', 2, 360, 'марка                         ', 'марки                         ', 'марок                         ', 'пфенинг                       ', 'пфенинга                      ', 'пфенингов                     ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000032, 'ИНДИЙСКИЕ РУПИИ ПО КРЕДИТАМ                                 ', 'C56                      ', 'C56       ', 'C56       ', 'C56       ', 2, 360, 'ИНДИЙСКИЕ РУПИИ ПО КРЕДИТАМ   ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001306, 'Испанские песеты', 'ESP                      ', '724       ', '724       ', '90001306  ', 2, 360, 'испанская песета              ', 'испанских песеты              ', 'испанских песет               ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000031, 'ЛИТОВСКИЕ ЛИТЫ                                              ', 'LTL                      ', '440       ', '440       ', 'LTL       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000036, 'БРАЗИЛЬСКИЕ РЕАЛЫ                                           ', 'BRL                      ', '986       ', '986       ', 'BRL       ', 2, 360, 'БРАЗИЛЬСКИЕ РЕАЛЫ             ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000025, 'ВЕНГЕРСКИЕ ФОРИНТЫ                                          ', 'HUF                      ', '348       ', '348       ', 'HUF       ', 2, 360, 'ВЕНГЕРСКИЕ ФОРИНТЫ            ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000041, 'МЕКСИКАНСКОЕ ПЕСО                                           ', 'MXN                      ', '484       ', '484       ', 'MXN       ', 2, 360, 'МЕКСИКАНСКОЕ ПЕСО             ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000010, 'КИПРСКИЕ ФУНТЫ                                              ', 'CYP                      ', '196       ', '196       ', 'CYP       ', 2, 360, 'КИПРСКИЕ ФУНТЫ                ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000058, 'Катарский Риал                                              ', 'QAR                      ', '634       ', '634       ', 'QAR       ', 0, 360, 'Катарский Риал                ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001303, 'Австрийские шиллинги', 'ATS                      ', '040       ', '040       ', '90001303  ', 2, 360, 'австрийский шиллинг           ', 'австрийских шиллинга          ', 'австрийских шиллингов         ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000027, 'СДР                                                         ', 'XDR                      ', '960       ', '960       ', 'XDR       ', 2, 360, 'СДР                           ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90003484, 'Палладий                                                    ', 'PLD                      ', 'A33       ', 'XPD       ', 'Палладий  ', 1, 360, 'грамм                         ', 'грамма                        ', 'граммов                       ', '                              ', '                              ', '                              ', 1, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001669, 'Казахские тенге                                             ', 'KZT                      ', '398       ', '398       ', 'KZN       ', 2, 365, 'казахский тенге               ', 'казахских тенге               ', 'казахских тенге               ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001308, 'Белорусский рубль', 'BYR                      ', '974       ', '974       ', '90001308  ', 0, 360, 'белорусский рубль             ', 'белорусских рубля             ', 'белорусских рублей            ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000013, 'НОВОЗЕЛАНДСКИЕ ДОЛЛАРЫ                                      ', 'NZD                      ', '554       ', '554       ', 'NZD       ', 2, 360, 'НОВОЗЕЛАНДСКИЕ ДОЛЛАРЫ        ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90003427, 'Ирландский фунт', 'IEP                      ', '372       ', '372       ', '          ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000007, 'СИНГАПУРСКИЕ ДОЛЛАРЫ                                        ', 'SGD                      ', '702       ', '702       ', 'SGD       ', 2, 360, 'СИНГАПУРСКИЕ ДОЛЛАРЫ          ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000048, 'ЧЕШСКИЕ КРОНЫ                                               ', 'CZK                      ', '203       ', '203       ', 'CZK       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000038, 'СИРИЙСКИЙ ФУНТ СОГЛ. 29.05.05                               ', 'E36                      ', 'E36       ', 'E36       ', 'E36       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000003, 'Пункты (для индексов)                                       ', 'PKT                      ', '988       ', '988       ', '          ', 2, 360, 'пункт                         ', 'пункта                        ', 'пунктов                       ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000057, 'Египетский Фунт                                             ', 'EGP                      ', '818       ', '818       ', 'EGP       ', 0, 360, 'Египетский Фунт               ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90003478, 'Единицы складского учета', 'ЕД                       ', 'ЕД        ', '          ', '          ', 0, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000001, 'ИНДИЙСКАЯ РУПИЯ                                             ', 'INR                      ', '356       ', '356       ', 'INR       ', 2, 360, 'индийская рупия               ', 'индийские рупии               ', 'индийских рупий               ', 'пайса                         ', 'пайсы                         ', 'пайс                          ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000055, 'Грузинский Лари                                             ', 'GEL                      ', '981       ', '981       ', 'GEL       ', 0, 360, 'Грузинский Лари               ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000060, 'Доллар Островов Кайман                                      ', 'KYD                      ', '136       ', '136       ', 'KYD       ', 0, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001305, 'Бельгийские франки', 'BEF                      ', '056       ', '056       ', '90001305  ', 2, 360, 'бельгийский франк             ', 'бельгийских франка            ', 'бельгийских франков           ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001293, 'Шведские кроны', 'SEK                      ', '752       ', '752       ', '90001293  ', 2, 360, 'шведская крона                ', 'шведские кроны                ', 'шведских крон                 ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000006, 'ИСЛАНДСКИЕ КРОНЫ                                            ', 'ISK                      ', '352       ', '352       ', 'ISK       ', 2, 360, 'ИСЛАНДСКИЕ КРОНЫ              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001301, 'Канадские доллары', 'CAD                      ', '124       ', '124       ', '90001301  ', 2, 360, 'канадский доллар              ', 'канадских доллара             ', 'канадских долларов            ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000046, 'ПОЛЬСКИЙ ЗЛОТЫЙ                                             ', 'PLN                      ', '985       ', '985       ', 'PLN       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000018, 'ВЬЕТНАМСКИЕ ДОНГИ (ДРВ)                                     ', 'VND                      ', '704       ', '704       ', 'VND       ', 2, 360, 'ВЬЕТНАМСКИЕ ДОНГИ (ДРВ)       ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(0, 'Многовалютный учет', '                         ', '          ', 'Многовалют', '1         ', 0, 0, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(276, 'Немецкие марки', 'DEM                      ', '276       ', '276       ', '1000000007', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000050, 'Родий                                                       ', 'A30                      ', 'A30       ', 'A30       ', 'Родий     ', 3, 360, 'грамм                         ', 'грамма                        ', 'граммов                       ', '                              ', '                              ', '                              ', 1, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001292, 'Швейцарские франки                                          ', 'CHF                      ', '756       ', '756       ', 'CHN       ', 2, 360, 'швейцарский франк             ', 'швейцарских франка            ', 'швейцарских франков           ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001295, 'Французские франки', 'FRF                      ', '250       ', '250       ', '90001295  ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(1, 'Доллары США                                                 ', 'USD                      ', '840       ', '840       ', 'USN       ', 2, 360, 'доллар США                    ', 'доллара США                   ', 'долларов США                  ', 'цент                          ', 'цента                         ', 'центов                        ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000052, 'Новый тайваньский доллар                                    ', 'TWD                      ', '901       ', '901       ', 'TWD       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000012, 'СИРИЙСКИЕ ФУНТЫ                                             ', 'SYP                      ', '760       ', '760       ', 'SYP       ', 2, 360, 'СИРИЙСКИЕ ФУНТЫ               ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000024, 'ЮЖНО-АФРИКАНСКОЙ РЕСПУБЛИКИ РЭ                              ', 'ZAR                      ', '710       ', '710       ', 'ZAR       ', 2, 360, 'ЮЖНО-АФРИКАНСКОЙ РЕСПУБЛИКИ РЭ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001304, 'Австралийский доллар', 'AUD                      ', '036       ', '036       ', '90001304  ', 2, 360, 'австралийский доллар          ', 'австралийских доллара         ', 'австралийских долларов        ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001300, 'Датские кроны', 'DKK                      ', '208       ', '208       ', '90001300  ', 2, 360, 'Датская крона                 ', 'Датских крон                  ', 'Датских крон                  ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001297, 'Норвежские кроны', 'NOK                      ', '578       ', '578       ', '90001297  ', 2, 360, 'Норвежская крона              ', 'Норвежские кроны              ', 'Норвежских крон               ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000042, 'АРМЯНСКИХ ДРАМОВ                                            ', 'AMD                      ', '051       ', '051       ', 'AMD       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90003482, 'Золото                                                      ', 'GLD                      ', 'A98       ', 'XAU       ', 'Золото    ', 1, 360, 'грамм                         ', 'грамма                        ', 'граммов                       ', '                              ', '                              ', '                              ', 1, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001307, 'Украинские гривны', 'UAH                      ', '980       ', '980       ', '90001307  ', 2, 360, 'украинская гривна             ', 'украинских гривны             ', 'украинских гривен             ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90003483, 'Серебро                                                     ', 'SLV                      ', 'A99       ', 'XAG       ', 'Серебро   ', 0, 360, 'грамм                         ', 'грамма                        ', 'граммов                       ', '                              ', '                              ', '                              ', 1, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(3, 'Штуки                                                       ', 'ШТ.                      ', '999       ', '999       ', '          ', 7, 360, 'штука                         ', 'штуки                         ', 'штук                          ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000056, 'Индонезийская Рупия                                         ', 'IDR                      ', '360       ', '360       ', 'IDR       ', 0, 360, 'Индонезийская Рупия           ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90003442, 'Цена в процентах', 'PCT                      ', '998       ', '          ', '          ', 0, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90003485, 'Платина                                                     ', 'PLT                      ', 'A76       ', 'XPT       ', 'Платина   ', 1, 360, 'грамм                         ', 'грамма                        ', 'граммов                       ', '                              ', '                              ', '                              ', 1, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000017, 'БОЛГАРСКИЕ ЛЕВЫ                                             ', 'BGN                      ', '975       ', '975       ', 'BGN       ', 2, 360, 'БОЛГАРСКИЕ ЛЕВЫ               ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000054, 'Сербские Динары                                             ', 'RSD                      ', '941       ', '941       ', 'RSD       ', 0, 360, 'Сербские Динары               ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001294, 'Итальянские лиры', 'ITL                      ', '380       ', '380       ', '90001294  ', 0, 360, 'итальянская лира              ', 'е лиры              итальянски', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001290, 'Фунты стерлингов', 'GBP                      ', '826       ', '826       ', '90001290  ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000047, 'ТАДЖИКСКИХ СОМОНИ                                           ', 'TJS                      ', '972       ', '972       ', 'TJS       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000040, 'АЗЕРБАЙДЖАНСКИЙ МАНАТ                                       ', 'AZN                      ', '944       ', '944       ', 'AZN       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000026, 'ДОЛЛАРЫ США/С ИНДИЕЙ                                        ', 'C95                      ', 'C95       ', 'C95       ', 'C95       ', 2, 360, 'ДОЛЛАРЫ США/С ИНДИЕЙ          ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000053, 'Таиландский бат                                             ', 'THB                      ', '764       ', '764       ', 'THB       ', 0, 365, 'Таиландский бат               ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000011, 'ПОРТУГАЛЬСКИЕ ЭСКУДО                                        ', 'PTE                      ', '620       ', '620       ', 'PTE       ', 2, 360, 'ПОРТУГАЛЬСКИЕ ЭСКУДО          ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001296, 'Финляндские марки', 'FIM                      ', '246       ', '246       ', '90001296  ', 2, 360, 'финляндская марка             ', 'финляндских марки             ', 'финляндских марок             ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000015, 'ВОН РЕСПУБЛИКИ КОРЕЯ                                        ', 'KRW                      ', '410       ', '410       ', 'KRW       ', 2, 360, 'ЮЖНОЙ КОРЕИ ВОНЫ              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000029, 'МОЛДАВСКИЕ ЛЕИ                                              ', 'MDL                      ', '498       ', '498       ', 'MDL       ', 2, 360, 'МОЛДАВСКИЕ ЛЕИ                ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000005, 'ЭКЮ - ЕВРОПЕЙСКАЯ ВАЛЮТА                                    ', 'XEU                      ', '954       ', '954       ', 'XEU       ', 2, 360, 'ЭКЮ - ЕВРОПЕЙСКАЯ ВАЛЮТА      ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001299, 'Евро                                                        ', 'EUR                      ', '978       ', '978       ', 'EUN       ', 2, 360, 'евро                          ', 'евро                          ', 'евро                          ', 'цент                          ', 'цента                         ', 'центов                        ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000014, 'ФИЛИППИНСКИЕ ПЕСО                                           ', 'PHP                      ', '608       ', '608       ', 'PHP       ', 2, 360, 'ФИЛИППИНСКИЕ ПЕСО             ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001291, 'Голландские гульдены', 'NLG                      ', '528       ', '528       ', '90001291  ', 2, 360, 'голландский гульден           ', 'голландских гульдена          ', 'голландских гульденов         ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000033, 'ДОЛЛ. США ПО РАСЧ. С ВЬЕТНАМОМ                              ', 'P25                      ', 'P25       ', 'P25       ', 'P25       ', 2, 360, 'ДОЛЛ. США ПО РАСЧ. С ВЬЕТНАМОМ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000008, 'ГРЕЧЕСКИЕ ДРАХМЫ                                            ', 'GRD                      ', '300       ', '300       ', 'GRD       ', 2, 360, 'ГРЕЧЕСКИЕ ДРАХМЫ              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000030, 'ДОЛЛАРЫ США/С КИТАЕМ                                        ', 'A50                      ', 'A50       ', 'A50       ', 'A50       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000023, 'ДОЛЛАРЫ США/С ИНДИЕЙ КРОМЕ С95                              ', 'C44                      ', 'C44       ', 'C44       ', 'C44       ', 2, 360, 'ДОЛЛАРЫ США/С ИНДИЕЙ КРОМЕ С95', '                              ', '                              ', 'ЦЕНТ                          ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(90001771, 'Пакистанская рупия', 'PKR                      ', '586       ', '586       ', '90001771  ', 2, 360, 'пакистанская рупия            ', 'пакистанских рупии            ', 'пакистанских рупий            ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000021, 'КЛИРИНГОВЫЕ ИНДИЙСКИЕ РУПИИ                                 ', 'C45                      ', 'C45       ', 'C45       ', 'C45       ', 2, 360, 'КЛИРИНГОВЫЕ ИНДИЙСКИЕ РУПИИ   ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000045, 'НОВЫЙ ТУРКМЕНСКИЙ МАНАТ                                     ', 'TMT                      ', '934       ', '934       ', 'TMT       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000009, 'ТУРЕЦКИЕ ЛИРЫ                                               ', 'TRL                      ', '792       ', '792       ', 'TRL       ', 2, 360, 'ТУРЕЦКИЕ ЛИРЫ                 ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000028, 'ГРУЗИНСКИЕ ЛАРИ                                             ', 'GEK                      ', '268       ', '268       ', 'GEK       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000061, 'Бахреейнский динар                                          ', 'BHD                      ', '048       ', '048       ', 'BHD       ', 0, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000020, 'ИРАКСКИЙ ДИНАР                                              ', 'IQD                      ', '368       ', '368       ', 'IQD       ', 2, 360, 'ИРАКСКИЙ ДИНАР                ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000002, 'ЛАТВИЙСКИЙ ЛАТ                                              ', 'LVL                      ', '428       ', '428       ', 'LVL       ', 2, 360, 'лат                           ', 'лата                          ', 'латов                         ', 'сантим                        ', 'сантима                       ', 'сантимов                      ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000037, 'КОНВЕРТИРУЕМЫЕ КУБИНСКИЕ ПЕСО                               ', 'CUC                      ', '931       ', '931       ', 'CUC       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000044, 'НОВЫЙ РУМЫНСКИЙ ЛЕЙ                                         ', 'RON                      ', '946       ', '946       ', 'RON       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000039, 'БЕЛОРУССКИЙ РУБЛЬ                                           ', 'BYN                      ', '933       ', '933       ', 'BYN       ', 2, 360, 'БЕЛОРУССКИЙ РУБЛЬ             ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000034, 'КЛИРИНГОВЫЕ ПАКИСТАНСКИЕ РУПИИ                              ', 'E69                      ', 'E69       ', 'E69       ', 'E69       ', 2, 360, 'КЛИРИНГОВЫЕ ПАКИСТАНСКИЕ РУПИИ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000049, 'ЭСТОНСКИХ КРОН                                              ', 'EEK                      ', '233       ', '233       ', 'EEK       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(2, 'Российские рубли                                            ', 'RUB                      ', '810       ', '643       ', 'RUN       ', 2, 365, 'рубль                         ', 'рубля                         ', 'рублей                        ', 'копейка                       ', 'копейки                       ', 'копеек                        ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000000, 'Китайский юань                                              ', 'CNY                      ', '156       ', '156       ', 'CNY       ', 2, 360, 'юань                          ', 'юаня                          ', 'юаней                         ', 'фэнь                          ', 'фэни                          ', 'фэней                         ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000004, 'Гонконгский доллар                                          ', 'HKD                      ', '344       ', '344       ', 'HKD       ', 2, 360, 'гонконгский доллар            ', 'гонконгских доллара           ', 'гонконгских долларов          ', 'гонконгский цент              ', 'гонконгских цента             ', 'гонконгских центов            ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000016, 'ИЗРАИЛЬСКИЕ ШЕКЕЛИ                                          ', 'ILS                      ', '376       ', '376       ', 'ILS       ', 2, 360, 'ИЗРАИЛЬСКИЕ ШЕКЕЛИ            ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000051, 'Дирхам (ОАЭ)                                                ', 'AED                      ', '784       ', '784       ', 'AED       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000043, 'КИРГИЗСКИХ СОМОВ                                            ', 'KGS                      ', '417       ', '417       ', 'KGS       ', 2, 360, '                              ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);
INSERT INTO dbo.tcurrency
("CurrencyID", "Name", "Brief", "Number", "ISONumber", "CashBrief", "Scale", "CountDayYear", "NameHi1", "NameHi24", "NameHi5", "NameLo1", "NameLo24", "NameLo5", "Flags", "InstrumentID")
VALUES(10000000022, 'ДОЛЛАРЫ США/ С БАНГЛАДЕШ                                    ', 'E70                      ', 'E70       ', 'E70       ', 'E70       ', 2, 360, 'ДОЛЛАРЫ США/ С БАНГЛАДЕШ      ', '                              ', '                              ', '                              ', '                              ', '                              ', 0, 1930);