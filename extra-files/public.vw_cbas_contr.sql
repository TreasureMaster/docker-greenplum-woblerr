drop  table if exists public.vw_cbas_contr;

CREATE TABLE public.vw_cbas_contr (
	id text NULL, -- ИД объекта
	create_ts timestamp NULL, -- Дата и время создания записи
	created_by text NULL, -- Пользователь, создавший запись
	update_ts timestamp NULL, -- Дата и время изменения записи
	updated_by text NULL, -- Пользователь, изменивший запись
	validation_errors text NULL, -- Ошибки валидации
	stopfactor text NULL, -- Стопфакторы
	verification_step text NULL, -- Шаг проверки
	type_ text NULL, -- Тип проверки
	contract_id text NULL, -- ИД договора в 3Card для проверок оценки ссуд
	client_id text NULL, -- ИД клиента в 3Card
	bank text NULL, -- Наименование банка (0-СКБ, 1-ГЭБ)
	verification_id text NULL, -- ИД проверки
	batch_id text NULL, -- ИД пакета
	excluded_batch_id text NULL, -- ИД пакета (заполнено, если исключен из проверки)
	active_batch_id text NULL, -- ИД пакета (заполнено, если активный)
	contract_type text NULL, -- Тип объекта
	error_batch_id text NULL, -- ИД ошибочного пакета
	error_message text NULL, -- Текст ошибки
	limit_offer numeric(16) NULL, -- Сумма предложения для клиента
	income_offer numeric(16, 3) NULL, -- Сумма дохода, используемая при расчете предложения
	contracts_topup text NULL, -- Договоры для переворота
	send_state text NULL, -- Состояние отправки предложения в 3Card
	preapprove_set text NULL, -- Факт простановки предлимита
	limit_rate numeric(16, 3) NULL, -- Процентная ставка в предложении клиенту
	contracts_unlim text NULL, -- Договоры, активные на момент расчета лимита
	unlim_flag text NULL, -- Флаг на обнуление лимита
	limit_standard numeric(16, 2) NULL, -- Предварительный рассчитанный лимит
	limit_max numeric(16, 2) NULL, -- Предварительная максимальная сумма на руки
	limit_prod_max numeric(16, 2) NULL, -- Предварительная максимальная сумма по продукту
	loan_scb numeric(16, 2) NULL, -- Текущая задолженность в СКБ+ГЭБ
	loan_mfo numeric(16, 2) NULL, -- Текущая задолженность в МФО
	report_date date NULL, -- Дата, на которую были рассчитаны данные о задолженности в СКБ, ГЭБ, МФО
	limit_standard_2 numeric(16, 2) NULL, -- Финальный рассчитанный лимит
	limit_max_2 numeric(16, 2) NULL, -- Финальная максимальная сумма на руки
	limit_prod_max_2 numeric(16, 2) NULL, -- Финальная максимальная сумма по продукту
	first_name text NULL, -- Имя клиента, по которому происходит проверка
	surname text NULL, -- Фамилия клиента, по которому происходит проверка
	middle_name text NULL, -- Отчество клиента, по которому происходит проверка
	birthdate date NULL, -- Дата рождения клиента, по которому происходит проверка
	spouse_surname text NULL, -- Фамилия супруга/и, по которому происходит проверка
	spouse_first_name text NULL, -- Имя супруга/и, по которому происходит проверка
	spouse_middlename text NULL, -- Отчество супруга/и, по которому происходит проверка
	spouse_birthdate date NULL, -- Дата рождения супруга/и, по которому происходит проверка
	comp_pass text NULL, -- Флаг нахождения клиента в списке некредитуемых паспортов
	stoplist_crit text NULL, -- Флаг нахождения клиента в списках Сигнал
	bankrupt_client text NULL, -- Флаг нахождения клиента в списках банкротств
	weight_negative numeric(16) NULL, -- Негативный вес записи по данному клиенту в списке Сигнал
	vki text NULL, -- Флаг нахождения клиента в списках ВКИ (внутренней кредитной истории)
	report_date_bl date NULL, -- Отчетная дата, на которую рассчитан статус нахождения клиента в черном списке
	spouse_bankrupt_client text NULL, -- Флаг нахождения супруга/и в списках банкротств
	spouse_weight_negative numeric(16) NULL, -- Негативный вес записи по данному/ой супругу/е в списке Сигнал
	spose_stop_list_crit text NULL, -- Флаг нахождения супруга/и в списках сигнал
	spouse_vki text NULL, -- Флаг нахождения супруга/и в списках ВКИ (внутренней кредитной истории)
	spouse_report_date date NULL, -- Отчетная дата, на которую рассчитан статус нахождения супруга/и в черном списке
	fact_of_death text NULL, -- Факт смерти
	registrationdate_card date NULL, -- Дата регистрации клиента в 3Card
	clientidext text NULL, -- Id клиента в банке-партнере
	doc_seria text NULL, -- Серия паспорта
	doc_number text NULL, -- Номер паспорта
	doc_issue_date date NULL, -- Дата выдачи паспорта
	doc_issue_place text NULL, -- Место выдачи паспорта
	doc_issue_code text NULL, -- Код места выдачи паспорта
	reg_region_code text NULL, -- Код региона регистрации
	reg_region text NULL, -- Название региона регистрации
	reg_city text NULL, -- Название города регистрации
	res_regioncode text NULL, -- Код региона проживания
	res_region text NULL, -- Название региона проживания
	res_city text NULL, -- Название города проживания
	spouse_state text NULL, -- Наличие супруги(а) и род занятости
	spouse_fio text NULL, -- ФИО супруги(а)
	empl_inn text NULL, -- ИНН работодателя
	first_contract_date date NULL, -- Дата первого договора клиента
	income_kds text NULL, -- Доход, рассчитанный по зп картам
	income text NULL, -- Доход, используемый для расчета
	expense text NULL, -- Платежи по кредитам со слов клиента
	dependents text NULL, -- Количество иждивенцев
	gender text NULL, -- Пол клиента
	employment text NULL, -- Статус занятости
	last_preapprovedate date NULL, -- Дата установки последнего лимита
	sp_rate text NULL, -- Ставка СП
	acrm_batch text NULL, -- ID батча проверки ACRM
	mdpk text NULL, -- Расчет МДПК (Максимально допустимый платёж клиента)
	omin_client text NULL, -- Остаток дохода клиента для осуществления минимальных потребительских расходов
	omin_family text NULL, -- Итоговый остаток дохода клиента
	payment_cur_scb text NULL, -- Расходы на кредиты SKB
	payment_other text NULL, -- Расход по чужим кредитам в БКИ
	payment_cur_topup text NULL, -- Расчет платежа по кредитам, рефинансируемым по Топ-Ап
	pti text NULL, -- Определение коэффициента предельной долговой нагрузки
	term_mvsk text NULL, -- Срок для расчета МВСК (Максимально возможной суммы кредита)
	rate_mvsk text NULL, -- Ставка для расчета МВСК
	topup_sum text NULL, -- Какая сумма будет перевернута (рефинансирована) в топ-ап
	mvsk text NULL, -- МВСК, после расчета 1 МВСК
	mdpk_final text NULL, -- МДПК, рассчитанный после получения скоринга
	pti_final text NULL, -- PTI, рассчитанный после получения скоринга
	mvsk_final text NULL, -- МВСК, рассчитанный после получения скоринга
	term_mvsk_final text NULL, -- Срок для расчета МВСК, рассчитанный после получения скоринга
	rate_mvsk_final text NULL, -- Ставка для расчета МВСК, рассчитанная после получения скоринга
	risk_status text NULL, -- Статус после оценки скоринга
	risk_range text NULL, -- Риск-диапазон, исходя из скоринга
	date_open_first date NULL, -- Дата открытия первого кредитного договора
	date_open_last date NULL, -- Дата открытия последнего кредитного договора
	result_pmt_string_all text NULL, -- Единая дисциплина платежей по всем кредитам
	inqua_1_7 text NULL, -- Кол-во запросов в БКИ за последние 7 дней
	loans_qua_pc_active text NULL, -- Кол-во активных потреб кредитов во всех банках
	loans_summ_pc_active_skb text NULL, -- Суммарный размер активных потреб кредитов в СКБ
	loans_summ_pc_close_skb text NULL, -- Суммарный размер закрытых потреб кредитов в СКБ
	loans_summ_pc_total text NULL, -- Суммарный размер потреб кредитов во всех банках (вне зависимости от активности)
	loans_summ_total text NULL, -- Суммарный размер всех кредитов за всё время (вне зависимости от активности)
	loans_summ_360_total text NULL, -- Суммарный размер всех кредитов во всех банках за последний год
	outstanding_total text NULL, -- Суммарный остаток по всем активным кредитам
	loans_summ_active text NULL, -- Суммарный размер всех активных кредитов
	loans_summ_cc_active text NULL, -- Суммарный размер всех активных кредитных карт
	loans_summ_cc_total text NULL, -- Суммарный размер всех кредитных карт (вне зависимости от активности)
	loans_summ_avg text NULL, -- Размер среднего лимита по всем кредитам во всех банках
	early_credits text NULL, -- Размер досрочного погашения всех кредитов (кроме кредитных карт)
	delay_credits text NULL, -- Размер просроченного погашения всех кредитов (кроме кредитных карт)
	ml_score text NULL, -- Скоринг, рассчитанный по модели
	ml_rate text NULL, -- Ставка, рассчитанная исходя из скоринга и диапазона
	date_open_first_skb date NULL, -- Дата открытия первого кредита в СКБ
	date_open_last_skb date NULL, -- Дата открытия последнего кредита в СКБ
	date_open_first_noskb date NULL, -- Дата открытия первого  кредита другого банка
	date_open_last_noskb date NULL, -- Дата открытия последнего  кредита другого банка
	qua_limit_30 text NULL, -- Количество выданных лимитов за последние 30 дней
	loans_qua text NULL, -- Всего кредитных договоров
	loans_qua_active text NULL, -- Всего активных кредитных договоров
	loans_qua_mfo_total text NULL, -- Всего договоров МФО
	loans_qua_mortgage_active text NULL, -- Всего активных договоров ипотеки
	summ_limit_close text NULL, -- Сумма закрытых кредитных лимитов
	loans_sum_other_total text NULL, -- Сумма по выданным прочим кредитам
	summ_limit_active_noskb text NULL, -- Сумма активных кредитных лимитов без СКБ
	summ_limit text NULL, -- Сумма кредитных лимитов
	loans_sum_other_active text NULL, -- Сумма лимитов по действующим прочим кредитам
	summ_limit_360 text NULL, -- Сумма выданных лимитов за последний год
	summ_limit_close_noskb text NULL, -- Сумма закрытых кредитных лимитов без СКБ
	summ_limit_active text NULL, -- Сумма активных кредитных лимитов
	loans_sum_cc_active text NULL, -- Cумма лимитов по действующий Кредитным картам
	loans_sum_mortgage_total text NULL, -- Сумма по выданным Ипотечным кредитам
	loans_sum_cc_total text NULL, -- Сумма по выданным Кредитным картам
	loans_sum_auto_total text NULL, -- Сумма по выданным Авто кредитам
	outstanding_cc_skb text NULL, -- Остаток задолженности по своим кредитам типа Кредитная карта
	outstanding_cc_noskb text NULL, -- Остаток задолженности по чужим кредитам типа  Кредитная карта
	outstanding_auto_skb text NULL, -- Остаток задолженности по своим кредитам типа  Автокредит
	outstanding_auto_noskb text NULL, -- Остаток задолженности по чужим кредитам типа  Автокредит
	outstanding_pc_skb text NULL, -- Остаток задолженности по своим кредитам типа  Потребительское кредитование
	outstanding_pc_noskb text NULL, -- Остаток задолженности по чужим кредитам типа  Потребительское кредитование
	outstanding_mortgage_skb text NULL, -- Остаток задолженности по своим кредитам типа Ипотека
	outstanding_mortgage_noskb text NULL, -- Остаток задолженности по чужим кредитам типа Ипотека
	outstanding_mfo_skb text NULL, -- Остаток задолженности по своим кредитам типа  МФО
	outstanding_mfo_noskb text NULL, -- Остаток задолженности по чужим кредитам типа  МФО
	outstanding_other_skb text NULL, -- Остаток задолженности по своим кредитам типа Иное
	outstanding_other_noskb text NULL, -- Остаток задолженности по чужим кредитам типа Иное
	focus_last_statusstring text NULL, -- Статус действия предприятия
	focus_entrepreneurship text NULL, -- Признак предпринимателя/ собственника бизнеса/ их родственника
	focus_code_principal_activity text NULL, -- Код деятельности предприятия
	focus_text_principal_activity text NULL, -- Код деятельности предприятия, расшифрованный
	last_registrationdate date NULL, -- Дата регистрации предприятия
	focus_dissolved text NULL, -- Признак действующей организации
	focus_dissolving text NULL, -- Признак организации, прекращающей деятельность
	focus_reorganizing text NULL, -- Признак организации, находящейся в стадии реорганизации
	min_rule text NULL, -- Худшее правило, сработавшее по данному клиенту/супругу/е
	sum text NULL, -- Сумма всех ИП
	cred_sum text NULL, -- Сумма всех кредитных ИП
	noncred_sum text NULL, -- Сумма всех некредитных ИП
	proceedings_count text NULL, -- Общее кол-во ИП
	credit_proceeding text NULL, -- Открыто ли кредитное производство
	last_credit_proceeding_open_date date NULL, -- Дата открытия последнего кредитного производства
	service_message text NULL, -- Сообщение о результатах проверки
	actual_info_flag text NULL, -- Флаг актуальности информации, взятой из БД ФССП
	all_run_begins_in_table text NULL -- Флаг всех run_begin в БД ФССП по этому клиенту
);
COMMENT ON TABLE public.vw_cbas_contr IS 'Представление, содержащее в себе финальные результаты всех проверок, в тч проверки ссуд, предлимитов и тд';

-- Column comments

COMMENT ON COLUMN public.vw_cbas_contr.id IS 'ИД объекта';
COMMENT ON COLUMN public.vw_cbas_contr.create_ts IS 'Дата и время создания записи';
COMMENT ON COLUMN public.vw_cbas_contr.created_by IS 'Пользователь, создавший запись';
COMMENT ON COLUMN public.vw_cbas_contr.update_ts IS 'Дата и время изменения записи';
COMMENT ON COLUMN public.vw_cbas_contr.updated_by IS 'Пользователь, изменивший запись';
COMMENT ON COLUMN public.vw_cbas_contr.validation_errors IS 'Ошибки валидации';
COMMENT ON COLUMN public.vw_cbas_contr.stopfactor IS 'Стопфакторы';
COMMENT ON COLUMN public.vw_cbas_contr.verification_step IS 'Шаг проверки';
COMMENT ON COLUMN public.vw_cbas_contr.type_ IS 'Тип проверки';
COMMENT ON COLUMN public.vw_cbas_contr.contract_id IS 'ИД договора в 3Card для проверок оценки ссуд';
COMMENT ON COLUMN public.vw_cbas_contr.client_id IS 'ИД клиента в 3Card';
COMMENT ON COLUMN public.vw_cbas_contr.bank IS 'Наименование банка (0-СКБ, 1-ГЭБ)';
COMMENT ON COLUMN public.vw_cbas_contr.verification_id IS 'ИД проверки';
COMMENT ON COLUMN public.vw_cbas_contr.batch_id IS 'ИД пакета';
COMMENT ON COLUMN public.vw_cbas_contr.excluded_batch_id IS 'ИД пакета (заполнено, если исключен из проверки)';
COMMENT ON COLUMN public.vw_cbas_contr.active_batch_id IS 'ИД пакета (заполнено, если активный)';
COMMENT ON COLUMN public.vw_cbas_contr.contract_type IS 'Тип объекта';
COMMENT ON COLUMN public.vw_cbas_contr.error_batch_id IS 'ИД ошибочного пакета';
COMMENT ON COLUMN public.vw_cbas_contr.error_message IS 'Текст ошибки';
COMMENT ON COLUMN public.vw_cbas_contr.limit_offer IS 'Сумма предложения для клиента';
COMMENT ON COLUMN public.vw_cbas_contr.income_offer IS 'Сумма дохода, используемая при расчете предложения';
COMMENT ON COLUMN public.vw_cbas_contr.contracts_topup IS 'Договоры для переворота';
COMMENT ON COLUMN public.vw_cbas_contr.send_state IS 'Состояние отправки предложения в 3Card';
COMMENT ON COLUMN public.vw_cbas_contr.preapprove_set IS 'Факт простановки предлимита';
COMMENT ON COLUMN public.vw_cbas_contr.limit_rate IS 'Процентная ставка в предложении клиенту';
COMMENT ON COLUMN public.vw_cbas_contr.contracts_unlim IS 'Договоры, активные на момент расчета лимита';
COMMENT ON COLUMN public.vw_cbas_contr.unlim_flag IS 'Флаг на обнуление лимита';
COMMENT ON COLUMN public.vw_cbas_contr.limit_standard IS 'Предварительный рассчитанный лимит';
COMMENT ON COLUMN public.vw_cbas_contr.limit_max IS 'Предварительная максимальная сумма на руки';
COMMENT ON COLUMN public.vw_cbas_contr.limit_prod_max IS 'Предварительная максимальная сумма по продукту';
COMMENT ON COLUMN public.vw_cbas_contr.loan_scb IS 'Текущая задолженность в СКБ+ГЭБ';
COMMENT ON COLUMN public.vw_cbas_contr.loan_mfo IS 'Текущая задолженность в МФО';
COMMENT ON COLUMN public.vw_cbas_contr.report_date IS 'Дата, на которую были рассчитаны данные о задолженности в СКБ, ГЭБ, МФО';
COMMENT ON COLUMN public.vw_cbas_contr.limit_standard_2 IS 'Финальный рассчитанный лимит';
COMMENT ON COLUMN public.vw_cbas_contr.limit_max_2 IS 'Финальная максимальная сумма на руки';
COMMENT ON COLUMN public.vw_cbas_contr.limit_prod_max_2 IS 'Финальная максимальная сумма по продукту';
COMMENT ON COLUMN public.vw_cbas_contr.first_name IS 'Имя клиента, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.surname IS 'Фамилия клиента, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.middle_name IS 'Отчество клиента, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.birthdate IS 'Дата рождения клиента, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_surname IS 'Фамилия супруга/и, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_first_name IS 'Имя супруга/и, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_middlename IS 'Отчество супруга/и, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_birthdate IS 'Дата рождения супруга/и, по которому происходит проверка';
COMMENT ON COLUMN public.vw_cbas_contr.comp_pass IS 'Флаг нахождения клиента в списке некредитуемых паспортов';
COMMENT ON COLUMN public.vw_cbas_contr.stoplist_crit IS 'Флаг нахождения клиента в списках Сигнал';
COMMENT ON COLUMN public.vw_cbas_contr.bankrupt_client IS 'Флаг нахождения клиента в списках банкротств';
COMMENT ON COLUMN public.vw_cbas_contr.weight_negative IS 'Негативный вес записи по данному клиенту в списке Сигнал';
COMMENT ON COLUMN public.vw_cbas_contr.vki IS 'Флаг нахождения клиента в списках ВКИ (внутренней кредитной истории)';
COMMENT ON COLUMN public.vw_cbas_contr.report_date_bl IS 'Отчетная дата, на которую рассчитан статус нахождения клиента в черном списке';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_bankrupt_client IS 'Флаг нахождения супруга/и в списках банкротств';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_weight_negative IS 'Негативный вес записи по данному/ой супругу/е в списке Сигнал';
COMMENT ON COLUMN public.vw_cbas_contr.spose_stop_list_crit IS 'Флаг нахождения супруга/и в списках сигнал';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_vki IS 'Флаг нахождения супруга/и в списках ВКИ (внутренней кредитной истории)';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_report_date IS 'Отчетная дата, на которую рассчитан статус нахождения супруга/и в черном списке';
COMMENT ON COLUMN public.vw_cbas_contr.fact_of_death IS 'Факт смерти';
COMMENT ON COLUMN public.vw_cbas_contr.registrationdate_card IS 'Дата регистрации клиента в 3Card';
COMMENT ON COLUMN public.vw_cbas_contr.clientidext IS 'Id клиента в банке-партнере';
COMMENT ON COLUMN public.vw_cbas_contr.doc_seria IS 'Серия паспорта';
COMMENT ON COLUMN public.vw_cbas_contr.doc_number IS 'Номер паспорта';
COMMENT ON COLUMN public.vw_cbas_contr.doc_issue_date IS 'Дата выдачи паспорта';
COMMENT ON COLUMN public.vw_cbas_contr.doc_issue_place IS 'Место выдачи паспорта';
COMMENT ON COLUMN public.vw_cbas_contr.doc_issue_code IS 'Код места выдачи паспорта';
COMMENT ON COLUMN public.vw_cbas_contr.reg_region_code IS 'Код региона регистрации';
COMMENT ON COLUMN public.vw_cbas_contr.reg_region IS 'Название региона регистрации';
COMMENT ON COLUMN public.vw_cbas_contr.reg_city IS 'Название города регистрации';
COMMENT ON COLUMN public.vw_cbas_contr.res_regioncode IS 'Код региона проживания';
COMMENT ON COLUMN public.vw_cbas_contr.res_region IS 'Название региона проживания';
COMMENT ON COLUMN public.vw_cbas_contr.res_city IS 'Название города проживания';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_state IS 'Наличие супруги(а) и род занятости';
COMMENT ON COLUMN public.vw_cbas_contr.spouse_fio IS 'ФИО супруги(а)';
COMMENT ON COLUMN public.vw_cbas_contr.empl_inn IS 'ИНН работодателя';
COMMENT ON COLUMN public.vw_cbas_contr.first_contract_date IS 'Дата первого договора клиента';
COMMENT ON COLUMN public.vw_cbas_contr.income_kds IS 'Доход, рассчитанный по зп картам';
COMMENT ON COLUMN public.vw_cbas_contr.income IS 'Доход, используемый для расчета';
COMMENT ON COLUMN public.vw_cbas_contr.expense IS 'Платежи по кредитам со слов клиента';
COMMENT ON COLUMN public.vw_cbas_contr.dependents IS 'Количество иждивенцев';
COMMENT ON COLUMN public.vw_cbas_contr.gender IS 'Пол клиента';
COMMENT ON COLUMN public.vw_cbas_contr.employment IS 'Статус занятости';
COMMENT ON COLUMN public.vw_cbas_contr.last_preapprovedate IS 'Дата установки последнего лимита';
COMMENT ON COLUMN public.vw_cbas_contr.sp_rate IS 'Ставка СП';
COMMENT ON COLUMN public.vw_cbas_contr.acrm_batch IS 'ID батча проверки ACRM';
COMMENT ON COLUMN public.vw_cbas_contr.mdpk IS 'Расчет МДПК (Максимально допустимый платёж клиента)';
COMMENT ON COLUMN public.vw_cbas_contr.omin_client IS 'Остаток дохода клиента для осуществления минимальных потребительских расходов';
COMMENT ON COLUMN public.vw_cbas_contr.omin_family IS 'Итоговый остаток дохода клиента';
COMMENT ON COLUMN public.vw_cbas_contr.payment_cur_scb IS 'Расходы на кредиты SKB';
COMMENT ON COLUMN public.vw_cbas_contr.payment_other IS 'Расход по чужим кредитам в БКИ';
COMMENT ON COLUMN public.vw_cbas_contr.payment_cur_topup IS 'Расчет платежа по кредитам, рефинансируемым по Топ-Ап';
COMMENT ON COLUMN public.vw_cbas_contr.pti IS 'Определение коэффициента предельной долговой нагрузки';
COMMENT ON COLUMN public.vw_cbas_contr.term_mvsk IS 'Срок для расчета МВСК (Максимально возможной суммы кредита)';
COMMENT ON COLUMN public.vw_cbas_contr.rate_mvsk IS 'Ставка для расчета МВСК';
COMMENT ON COLUMN public.vw_cbas_contr.topup_sum IS 'Какая сумма будет перевернута (рефинансирована) в топ-ап';
COMMENT ON COLUMN public.vw_cbas_contr.mvsk IS 'МВСК, после расчета 1 МВСК';
COMMENT ON COLUMN public.vw_cbas_contr.mdpk_final IS 'МДПК, рассчитанный после получения скоринга';
COMMENT ON COLUMN public.vw_cbas_contr.pti_final IS 'PTI, рассчитанный после получения скоринга';
COMMENT ON COLUMN public.vw_cbas_contr.mvsk_final IS 'МВСК, рассчитанный после получения скоринга';
COMMENT ON COLUMN public.vw_cbas_contr.term_mvsk_final IS 'Срок для расчета МВСК, рассчитанный после получения скоринга';
COMMENT ON COLUMN public.vw_cbas_contr.rate_mvsk_final IS 'Ставка для расчета МВСК, рассчитанная после получения скоринга';
COMMENT ON COLUMN public.vw_cbas_contr.risk_status IS 'Статус после оценки скоринга';
COMMENT ON COLUMN public.vw_cbas_contr.risk_range IS 'Риск-диапазон, исходя из скоринга';
COMMENT ON COLUMN public.vw_cbas_contr.date_open_first IS 'Дата открытия первого кредитного договора';
COMMENT ON COLUMN public.vw_cbas_contr.date_open_last IS 'Дата открытия последнего кредитного договора';
COMMENT ON COLUMN public.vw_cbas_contr.result_pmt_string_all IS 'Единая дисциплина платежей по всем кредитам';
COMMENT ON COLUMN public.vw_cbas_contr.inqua_1_7 IS 'Кол-во запросов в БКИ за последние 7 дней';
COMMENT ON COLUMN public.vw_cbas_contr.loans_qua_pc_active IS 'Кол-во активных потреб кредитов во всех банках';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_pc_active_skb IS 'Суммарный размер активных потреб кредитов в СКБ';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_pc_close_skb IS 'Суммарный размер закрытых потреб кредитов в СКБ';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_pc_total IS 'Суммарный размер потреб кредитов во всех банках (вне зависимости от активности)';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_total IS 'Суммарный размер всех кредитов за всё время (вне зависимости от активности)';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_360_total IS 'Суммарный размер всех кредитов во всех банках за последний год';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_total IS 'Суммарный остаток по всем активным кредитам';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_active IS 'Суммарный размер всех активных кредитов';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_cc_active IS 'Суммарный размер всех активных кредитных карт';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_cc_total IS 'Суммарный размер всех кредитных карт (вне зависимости от активности)';
COMMENT ON COLUMN public.vw_cbas_contr.loans_summ_avg IS 'Размер среднего лимита по всем кредитам во всех банках';
COMMENT ON COLUMN public.vw_cbas_contr.early_credits IS 'Размер досрочного погашения всех кредитов (кроме кредитных карт)';
COMMENT ON COLUMN public.vw_cbas_contr.delay_credits IS 'Размер просроченного погашения всех кредитов (кроме кредитных карт)';
COMMENT ON COLUMN public.vw_cbas_contr.ml_score IS 'Скоринг, рассчитанный по модели';
COMMENT ON COLUMN public.vw_cbas_contr.ml_rate IS 'Ставка, рассчитанная исходя из скоринга и диапазона';
COMMENT ON COLUMN public.vw_cbas_contr.date_open_first_skb IS 'Дата открытия первого кредита в СКБ';
COMMENT ON COLUMN public.vw_cbas_contr.date_open_last_skb IS 'Дата открытия последнего кредита в СКБ';
COMMENT ON COLUMN public.vw_cbas_contr.date_open_first_noskb IS 'Дата открытия первого  кредита другого банка';
COMMENT ON COLUMN public.vw_cbas_contr.date_open_last_noskb IS 'Дата открытия последнего  кредита другого банка';
COMMENT ON COLUMN public.vw_cbas_contr.qua_limit_30 IS 'Количество выданных лимитов за последние 30 дней';
COMMENT ON COLUMN public.vw_cbas_contr.loans_qua IS 'Всего кредитных договоров';
COMMENT ON COLUMN public.vw_cbas_contr.loans_qua_active IS 'Всего активных кредитных договоров';
COMMENT ON COLUMN public.vw_cbas_contr.loans_qua_mfo_total IS 'Всего договоров МФО';
COMMENT ON COLUMN public.vw_cbas_contr.loans_qua_mortgage_active IS 'Всего активных договоров ипотеки';
COMMENT ON COLUMN public.vw_cbas_contr.summ_limit_close IS 'Сумма закрытых кредитных лимитов';
COMMENT ON COLUMN public.vw_cbas_contr.loans_sum_other_total IS 'Сумма по выданным прочим кредитам';
COMMENT ON COLUMN public.vw_cbas_contr.summ_limit_active_noskb IS 'Сумма активных кредитных лимитов без СКБ';
COMMENT ON COLUMN public.vw_cbas_contr.summ_limit IS 'Сумма кредитных лимитов';
COMMENT ON COLUMN public.vw_cbas_contr.loans_sum_other_active IS 'Сумма лимитов по действующим прочим кредитам';
COMMENT ON COLUMN public.vw_cbas_contr.summ_limit_360 IS 'Сумма выданных лимитов за последний год';
COMMENT ON COLUMN public.vw_cbas_contr.summ_limit_close_noskb IS 'Сумма закрытых кредитных лимитов без СКБ';
COMMENT ON COLUMN public.vw_cbas_contr.summ_limit_active IS 'Сумма активных кредитных лимитов';
COMMENT ON COLUMN public.vw_cbas_contr.loans_sum_cc_active IS 'Cумма лимитов по действующий Кредитным картам';
COMMENT ON COLUMN public.vw_cbas_contr.loans_sum_mortgage_total IS 'Сумма по выданным Ипотечным кредитам';
COMMENT ON COLUMN public.vw_cbas_contr.loans_sum_cc_total IS 'Сумма по выданным Кредитным картам';
COMMENT ON COLUMN public.vw_cbas_contr.loans_sum_auto_total IS 'Сумма по выданным Авто кредитам';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_cc_skb IS 'Остаток задолженности по своим кредитам типа Кредитная карта';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_cc_noskb IS 'Остаток задолженности по чужим кредитам типа  Кредитная карта';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_auto_skb IS 'Остаток задолженности по своим кредитам типа  Автокредит';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_auto_noskb IS 'Остаток задолженности по чужим кредитам типа  Автокредит';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_pc_skb IS 'Остаток задолженности по своим кредитам типа  Потребительское кредитование';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_pc_noskb IS 'Остаток задолженности по чужим кредитам типа  Потребительское кредитование';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_mortgage_skb IS 'Остаток задолженности по своим кредитам типа Ипотека';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_mortgage_noskb IS 'Остаток задолженности по чужим кредитам типа Ипотека';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_mfo_skb IS 'Остаток задолженности по своим кредитам типа  МФО';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_mfo_noskb IS 'Остаток задолженности по чужим кредитам типа  МФО';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_other_skb IS 'Остаток задолженности по своим кредитам типа Иное';
COMMENT ON COLUMN public.vw_cbas_contr.outstanding_other_noskb IS 'Остаток задолженности по чужим кредитам типа Иное';
COMMENT ON COLUMN public.vw_cbas_contr.focus_last_statusstring IS 'Статус действия предприятия';
COMMENT ON COLUMN public.vw_cbas_contr.focus_entrepreneurship IS 'Признак предпринимателя/ собственника бизнеса/ их родственника';
COMMENT ON COLUMN public.vw_cbas_contr.focus_code_principal_activity IS 'Код деятельности предприятия';
COMMENT ON COLUMN public.vw_cbas_contr.focus_text_principal_activity IS 'Код деятельности предприятия, расшифрованный';
COMMENT ON COLUMN public.vw_cbas_contr.last_registrationdate IS 'Дата регистрации предприятия';
COMMENT ON COLUMN public.vw_cbas_contr.focus_dissolved IS 'Признак действующей организации';
COMMENT ON COLUMN public.vw_cbas_contr.focus_dissolving IS 'Признак организации, прекращающей деятельность';
COMMENT ON COLUMN public.vw_cbas_contr.focus_reorganizing IS 'Признак организации, находящейся в стадии реорганизации';
COMMENT ON COLUMN public.vw_cbas_contr.min_rule IS 'Худшее правило, сработавшее по данному клиенту/супругу/е';
COMMENT ON COLUMN public.vw_cbas_contr.sum IS 'Сумма всех ИП';
COMMENT ON COLUMN public.vw_cbas_contr.cred_sum IS 'Сумма всех кредитных ИП';
COMMENT ON COLUMN public.vw_cbas_contr.noncred_sum IS 'Сумма всех некредитных ИП';
COMMENT ON COLUMN public.vw_cbas_contr.proceedings_count IS 'Общее кол-во ИП';
COMMENT ON COLUMN public.vw_cbas_contr.credit_proceeding IS 'Открыто ли кредитное производство';
COMMENT ON COLUMN public.vw_cbas_contr.last_credit_proceeding_open_date IS 'Дата открытия последнего кредитного производства';
COMMENT ON COLUMN public.vw_cbas_contr.service_message IS 'Сообщение о результатах проверки';
COMMENT ON COLUMN public.vw_cbas_contr.actual_info_flag IS 'Флаг актуальности информации, взятой из БД ФССП';
COMMENT ON COLUMN public.vw_cbas_contr.all_run_begins_in_table IS 'Флаг всех run_begin в БД ФССП по этому клиенту';

INSERT INTO public.vw_cbas_contr (id,create_ts,created_by,update_ts,updated_by,validation_errors,stopfactor,verification_step,type_,contract_id,client_id,bank,verification_id,batch_id,excluded_batch_id,active_batch_id,contract_type,error_batch_id,error_message,limit_offer,income_offer,contracts_topup,send_state,preapprove_set,limit_rate,contracts_unlim,unlim_flag,limit_standard,limit_max,limit_prod_max,loan_scb,loan_mfo,report_date,limit_standard_2,limit_max_2,limit_prod_max_2,spouse_surname,spouse_first_name,spouse_middlename,spouse_birthdate,comp_pass,stoplist_crit,bankrupt_client,weight_negative,vki,report_date_bl,spouse_bankrupt_client,spouse_weight_negative,spose_stop_list_crit,spouse_vki,spouse_report_date,fact_of_death,registrationdate_card,clientidext,reg_region_code,reg_region,reg_city,res_regioncode,res_region,res_city,spouse_state,spouse_fio,empl_inn,first_contract_date,income_kds,income,expense,dependents,gender,employment,last_preapprovedate,sp_rate,acrm_batch,mdpk,omin_client,omin_family,payment_cur_scb,payment_other,payment_cur_topup,pti,term_mvsk,rate_mvsk,topup_sum,mvsk,mdpk_final,pti_final,mvsk_final,term_mvsk_final,rate_mvsk_final,risk_status,risk_range,date_open_first,date_open_last,result_pmt_string_all,inqua_1_7,loans_qua_pc_active,loans_summ_pc_active_skb,loans_summ_pc_close_skb,loans_summ_pc_total,loans_summ_total,loans_summ_360_total,outstanding_total,loans_summ_active,loans_summ_cc_active,loans_summ_cc_total,loans_summ_avg,early_credits,delay_credits,ml_score,ml_rate,date_open_first_skb,date_open_last_skb,date_open_first_noskb,date_open_last_noskb,qua_limit_30,loans_qua,loans_qua_active,loans_qua_mfo_total,loans_qua_mortgage_active,summ_limit_close,loans_sum_other_total,summ_limit_active_noskb,summ_limit,loans_sum_other_active,summ_limit_360,summ_limit_close_noskb,summ_limit_active,loans_sum_cc_active,loans_sum_mortgage_total,loans_sum_cc_total,loans_sum_auto_total,outstanding_cc_skb,outstanding_cc_noskb,outstanding_auto_skb,outstanding_auto_noskb,outstanding_pc_skb,outstanding_pc_noskb,outstanding_mortgage_skb,outstanding_mortgage_noskb,outstanding_mfo_skb,outstanding_mfo_noskb,outstanding_other_skb,outstanding_other_noskb,focus_last_statusstring,focus_entrepreneurship,focus_code_principal_activity,focus_text_principal_activity,last_registrationdate,focus_dissolved,focus_dissolving,focus_reorganizing,min_rule,sum,cred_sum,noncred_sum,proceedings_count,credit_proceeding,last_credit_proceeding_open_date,service_message,actual_info_flag,all_run_begins_in_table) VALUES
	 ('24cce7b0-e62f-c688-670f-bd8abcfd3fb0','2026-06-29 07:14:43.286',NULL,'2026-06-29 07:15:54.432','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'7811721','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','398e55ec-d0cb-97fa-afdc-ab548e975378','398e55ec-d0cb-97fa-afdc-ab548e975378',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('7dbcd75b-583f-5f65-a32a-7b1c0dec9cf4','2026-06-29 07:14:44.544',NULL,'2026-06-29 07:16:10.338','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'11782986','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','45f172e9-f273-0f3a-3bd6-e09fa3ccc953','45f172e9-f273-0f3a-3bd6-e09fa3ccc953',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'9307776',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('5e76f049-2507-c143-e8bd-d431668a23d3','2026-06-29 07:14:50.215',NULL,'2026-06-29 07:18:51.222','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'7920269','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','35828361-826c-5ff4-d962-88e6e7c8ac0d','35828361-826c-5ff4-d962-88e6e7c8ac0d',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'9738095',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('c900f63b-665c-48bf-d4d6-f8163f3804ac','2026-06-29 07:14:52.626','admin','2026-06-29 07:19:29.487','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'8306568','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','3857da7f-6ae8-d050-19e9-a1008a7934ac','3857da7f-6ae8-d050-19e9-a1008a7934ac',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'9407215',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('439effe5-2c74-f2cd-394d-0c006d9f3e72','2026-06-29 07:14:53.313',NULL,'2026-06-29 07:19:41.674','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'11990772','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','4ae4d105-837f-5b05-18af-5b78a2536440','4ae4d105-837f-5b05-18af-5b78a2536440',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'9378352',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('403c659a-b1dc-1144-bd02-24c1af2f8b30','2026-06-29 07:14:55.343',NULL,'2026-06-29 07:17:09.921','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'5117250','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','0f3788f6-f091-64ed-6dae-5199fc42be0f','0f3788f6-f091-64ed-6dae-5199fc42be0f',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('cb26a563-61d9-70df-28a3-f92e269d4d29','2026-06-29 07:14:58.192',NULL,'2026-06-29 07:17:55.130','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'12972848','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','861110e7-155b-7cc1-d871-813f5eea70e6','861110e7-155b-7cc1-d871-813f5eea70e6',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('81359113-cacc-a943-f076-e3c97d43cd22','2026-06-29 07:14:58.947','admin','2026-06-29 07:18:07.989','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'8623404','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','63c6363f-e1d1-c411-5abe-d103d1a7b33d','63c6363f-e1d1-c411-5abe-d103d1a7b33d',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'9107030',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('b386eb02-6132-c610-7314-cfb5b272b6e2','2026-06-29 07:15:01.850',NULL,'2026-06-29 07:20:42.882','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'5331087','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','7f0e7440-3889-606a-5631-0882b533c45f','7f0e7440-3889-606a-5631-0882b533c45f',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'9104437',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 ('c57caeac-736a-789b-9745-fe0721975d22','2026-06-29 07:15:02.452',NULL,'2026-06-29 07:20:52.976','admin','CONSENT_PERIOD','CL.999','FINISH','CH_PACKAGE_REQUEST_TRIGGER_200',NULL,'8957659','0','57b1cca5-a6e2-bca1-8e12-45c8efd52e7b','00478868-2698-976f-efd6-bfbe74666fda','00478868-2698-976f-efd6-bfbe74666fda',NULL,'COMMON',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'9088486',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
