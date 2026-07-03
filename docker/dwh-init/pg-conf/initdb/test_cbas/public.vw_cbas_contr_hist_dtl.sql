drop table if exists public.vw_cbas_contr_hist_dtl;

CREATE TABLE public.vw_cbas_contr_hist_dtl (
	contract_id text NULL, -- ИД объекта CBAS
	client_id text NULL, -- ИД клиента в 3Card
	create_ts timestamp NULL, -- Дата и время создания
	hist_id text NULL, -- ИД записи в history
	verification_step text NULL, -- Шаг проверки
	id_lv2 text NULL, -- ИД 2 уровня в поле records из подраздела leaderRecord
	rsp_src text NULL, -- Источник ответа, FSSP_WAIT, из разбора records
	ipnum text NULL, -- Номер исполнительного производства
	ipdate date NULL, -- Дата начала исполнительного производства
	ipclosedate date NULL, -- Дата окончания исполнительного производства
	ipclosereason text NULL, -- Причина закрытия исполнительного производства
	idrequisites text NULL, -- Документ о начале исполнительного производства
	spi text NULL, -- Пристав, начавший исполнительное производство
	ipdebt text NULL, -- Сумма задолженности по исполнительному производству
	idsubjname text NULL, -- Предмет исполнительного производства
	"name" text NULL, -- ФИО, по которому ведется исполнительное производство
	birthdate date NULL, -- ДР, по которому ведется исполнительное производство
	address text NULL -- Адрес того, по кому ведется исполнительное производство
);
COMMENT ON TABLE public.vw_cbas_contr_hist_dtl IS 'Представление собирает поля из verification_step in ("FSSP_WAIT"), таблицы cbas_contract_history и cbas_contract';

-- Column comments

COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.contract_id IS 'ИД объекта CBAS';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.client_id IS 'ИД клиента в 3Card';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.create_ts IS 'Дата и время создания';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.hist_id IS 'ИД записи в history';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.verification_step IS 'Шаг проверки';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.id_lv2 IS 'ИД 2 уровня в поле records из подраздела leaderRecord';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.rsp_src IS 'Источник ответа, FSSP_WAIT, из разбора records';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.ipnum IS 'Номер исполнительного производства';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.ipdate IS 'Дата начала исполнительного производства';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.ipclosedate IS 'Дата окончания исполнительного производства';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.ipclosereason IS 'Причина закрытия исполнительного производства';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.idrequisites IS 'Документ о начале исполнительного производства';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.spi IS 'Пристав, начавший исполнительное производство';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.ipdebt IS 'Сумма задолженности по исполнительному производству';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.idsubjname IS 'Предмет исполнительного производства';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl."name" IS 'ФИО, по которому ведется исполнительное производство';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.birthdate IS 'ДР, по которому ведется исполнительное производство';
COMMENT ON COLUMN public.vw_cbas_contr_hist_dtl.address IS 'Адрес того, по кому ведется исполнительное производство';