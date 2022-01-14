
// Заполняет доступные конфигурации источника и приемника
//
// Параметры:
//  Конфигурации - Структура - структура с полями "Конфигурация", "КонфигурацияКорреспондент" для заполнения
//  СписокКонвертаций - СписокЗначений - список конвертаций
//  ЭтоКонвертацияXDTO - Булево - признак конвертации в формате XDTO
//  ОбъектИсточника - СправочникСсылка.Объекты - если заполнен, то выбранный на форме объект источника
//  ОбъектПриемника - СправочникСсылка.Объекты - если заполнен, то выбранный на форме объект приемника
//
Процедура ЗаполнитьКонфигурации(ДоступныеКонфигурации, СписокКонвертаций, ЭтоКонвертацияXDTO, ОбъектИсточника, ОбъектПриемника) Экспорт
	
	ТекстыЗапроса = Новый Массив;
	
	Если ДоступныеКонфигурации.Конфигурация = Неопределено Тогда
		ТекстыЗапроса.Добавить(
			"ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	""Конфигурация"" КАК Ключ,
			|	Конвертации.Конфигурация КАК Конфигурация
			|ИЗ
			|	Справочник.Конвертации КАК Конвертации
			|ГДЕ
			|	Конвертации.Ссылка В(&СписокКонвертаций)");
	КонецЕсли;
	Если НЕ ЭтоКонвертацияXDTO И ДоступныеКонфигурации.КонфигурацияКорреспондент = Неопределено Тогда
		ТекстыЗапроса.Добавить(
			"ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	""КонфигурацияКорреспондент"" КАК Ключ,
			|	Конвертации.КонфигурацияКорреспондент КАК Конфигурация
			|ИЗ
			|	Справочник.Конвертации КАК Конвертации
			|ГДЕ
			|	НЕ &ЭтоКонвертацияXDTO
			|	И Конвертации.Ссылка В(&СписокКонвертаций)");
	КонецЕсли;
	Если ТекстыЗапроса.Количество() > 0 Тогда
		РазделительЗапросов = "
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|";
		
		Запрос = Новый Запрос;
		Запрос.Текст = СтрСоединить(ТекстыЗапроса, РазделительЗапросов);
		Запрос.УстановитьПараметр("ЭтоКонвертацияXDTO", ЭтоКонвертацияXDTO);
		Запрос.УстановитьПараметр("СписокКонвертаций", СписокКонвертаций);
		
		РезультатЗапроса = Запрос.ВыполнитьПакет();
		
		Для Каждого ПакетЗапроса Из РезультатЗапроса Цикл
			ТаблицаКонфигураций = ПакетЗапроса.Выгрузить();
			Если ТаблицаКонфигураций.Количество() > 0 Тогда
				ДоступныеКонфигурации.Вставить(ТаблицаКонфигураций[0].Ключ, ТаблицаКонфигураций.ВыгрузитьКолонку("Конфигурация"));
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОбъектИсточника) И ТипЗнч(ОбъектИсточника) = Тип("СправочникСсылка.Объекты") Тогда
		Конфигурация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ОбъектИсточника, "Владелец");
		// Сейчас можно сделать так, чтобы конфигурация объекта на будет соответствовать конфигурациям конвертаций
		Если ДоступныеКонфигурации.Конфигурация.Найти(Конфигурация) <> Неопределено Тогда
			ДоступныеКонфигурации.Конфигурация = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Конфигурация);
		КонецЕсли;
	КонецЕсли;
	Если НЕ ЭтоКонвертацияXDTO И ЗначениеЗаполнено(ОбъектПриемника) Тогда
		Конфигурация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ОбъектПриемника, "Владелец");
		// Сейчас можно сделать так, чтобы конфигурация объекта на будет соответствовать конфигурациям конвертаций
		Если ДоступныеКонфигурации.КонфигурацияКорреспондент.Найти(Конфигурация) <> Неопределено Тогда
			ДоступныеКонфигурации.КонфигурацияКорреспондент = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Конфигурация);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#Область Индексы_метаданных

Функция ОписаниеМетаданных(Конфигурация, КлючКоллекции, НастройкиКонфигурации = Неопределено, ЗаполнятьПриОтсутствии = Истина) Экспорт
	
	Если НастройкиКонфигурации = Неопределено Тогда
		НастройкиКонфигурации = НастройкиКонфигурации(Конфигурация);
	КонецЕсли;
	
	Если КлючКоллекции = "globalcontext" Тогда
		Возврат ОписаниеГлобальногоКонтекстаПоЗапросу(Конфигурация, НастройкиКонфигурации);
	КонецЕсли;
	
	Если НастройкиКонфигурации.МестоХраненияИндексов = 0 Тогда
		Возврат ПустоеОписаниеМетаданных();
	КонецЕсли;
	
	ОписаниеМетаданных = Неопределено;
	
	Если НастройкиКонфигурации.МестоХраненияИндексов = 2 Тогда
		КлючВладельца = "КД3_" + XMLСтрока(Конфигурация) + "_" + КлючКоллекции;
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ Данные ИЗ РегистрСведений.БезопасноеХранилищеДанных ГДЕ Владелец = &КлючВладельца";
		Запрос.УстановитьПараметр("КлючВладельца", КлючВладельца);
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ОписаниеМетаданных = Выборка.Данные.Получить();
		КонецЕсли;
		
	ИначеЕсли НастройкиКонфигурации.МестоХраненияИндексов = 1 Тогда
		
		ТестФайл = Новый Файл(НастройкиКонфигурации.КаталогИндексов + ПолучитьРазделительПутиСервера() + КлючКоллекции + ".json");
		Если ТестФайл.Существует() Тогда
			ЧтениеТекста = Новый ЧтениеТекста;
			ЧтениеТекста.Открыть(ТестФайл.ПолноеИмя, "UTF-8",,,Ложь);
			ОписаниеМетаданных = ЧтениеТекста.Прочитать();
		КонецЕсли;
	КонецЕсли;
	
	Если ОписаниеМетаданных = Неопределено И ЗаполнятьПриОтсутствии Тогда
		ОписаниеМетаданных = ОписаниеМетаданныхПоЗапросу(Конфигурация, КлючКоллекции, НастройкиКонфигурации);
	КонецЕсли;
	
	Возврат ОписаниеМетаданных;
	
КонецФункции

Процедура ИзменитьОписаниеМетаданных(Конфигурация, КлючКоллекции, ДанныеДляСохранения, НастройкиКонфигурации = Неопределено) Экспорт
	
	Если НастройкиКонфигурации = Неопределено Тогда
		НастройкиКонфигурации = НастройкиКонфигурации(Конфигурация);
	КонецЕсли;
	Если НастройкиКонфигурации.МестоХраненияИндексов = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если НастройкиКонфигурации.МестоХраненияИндексов = 2 Тогда
		КлючВладельца = "КД3_" + XMLСтрока(Конфигурация) + "_" + КлючКоллекции;
		
		Если ТипЗнч(ДанныеДляСохранения) = Тип("Строка") Тогда
			ТекстJSON = ДанныеДляСохранения;
		Иначе
			ТекстJSON = ОбъектВСтрокуJSON(ДанныеДляСохранения);
		КонецЕсли;
		
		МенеджерЗаписи = РегистрыСведений.БезопасноеХранилищеДанных.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Владелец = КлючВладельца;
		МенеджерЗаписи.Данные = Новый ХранилищеЗначения(ТекстJSON, Новый СжатиеДанных(6));
		МенеджерЗаписи.Записать();
		
	ИначеЕсли НастройкиКонфигурации.МестоХраненияИндексов = 1 Тогда
		
		ПолноеИмяФайла = НастройкиКонфигурации.КаталогИндексов + ПолучитьРазделительПутиСервера() + КлючКоллекции + ".json";
		Если ТипЗнч(ДанныеДляСохранения) = Тип("Строка") Тогда
			ЗаписьТекста = Новый ЗаписьТекста;
			ЗаписьТекста.Открыть(ПолноеИмяФайла, "UTF-8");
			ЗаписьТекста.Записать(ДанныеДляСохранения);
			ЗаписьТекста.Закрыть();
		Иначе
			ЗаписьJSON = Новый ЗаписьJSON;
			ЗаписьJSON.ОткрытьФайл(ПолноеИмяФайла);
			ЗаписатьJSON(ЗаписьJSON, ДанныеДляСохранения);
			ЗаписьJSON.Закрыть();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура УдалитьОписаниеМетаданных(Конфигурация, НастройкиКонфигурации = Неопределено) Экспорт
	
	Если НастройкиКонфигурации = Неопределено Тогда
		НастройкиКонфигурации = НастройкиКонфигурации(Конфигурация);
	КонецЕсли;
	
	Если НастройкиКонфигурации.МестоХраненияИндексов = 2 Тогда
		КлючВладельца = "КД3_" + XMLСтрока(Конфигурация);
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ Владелец ИЗ РегистрСведений.БезопасноеХранилищеДанных ГДЕ Владелец ПОДОБНО &КлючВладельца";
		Запрос.УстановитьПараметр("КлючВладельца", КлючВладельца + "%");
		
		МенеджерЗаписи = РегистрыСведений.БезопасноеХранилищеДанных.СоздатьМенеджерЗаписи();
		
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			МенеджерЗаписи.Владелец = Выборка.Владелец;
			МенеджерЗаписи.Удалить();
		КонецЦикла;
		
	ИначеЕсли НастройкиКонфигурации.МестоХраненияИндексов = 1 Тогда
		Попытка
			УдалитьФайлы(НастройкиКонфигурации.КаталогИндексов, "*.json");
		Исключение
			ТекстСообщения = СтрШаблон("Ошибка удаления старых индексов в каталоге ""%1"": %2", НастройкиКонфигурации.КаталогИндексов, ОписаниеОшибки());
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

Функция НастройкиКонфигурации(Конфигурация) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ Данные ИЗ РегистрСведений.БезопасноеХранилищеДанных ГДЕ Владелец = &КлючВладельца";
	Запрос.УстановитьПараметр("КлючВладельца", КлючНастроекКонфигурации(Конфигурация));
	
	Настройки = Новый Структура;
	Настройки.Вставить("МестоХраненияИндексов", 0);
	Настройки.Вставить("КаталогИндексов", "");
	Настройки.Вставить("ЗагружатьМетодыМодулей", Ложь);
	Настройки.Вставить("ЗагружатьИзФайлов", Ложь);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		ЗаполнитьЗначенияСвойств(Настройки, Выборка.Данные.Получить());
	КонецЕсли;
	
	Возврат Настройки;
	
КонецФункции

Процедура ИзменитьНастройкиКонфигурации(Конфигурация, Настройки) Экспорт
	
	МенеджерЗаписи = РегистрыСведений.БезопасноеХранилищеДанных.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Владелец = КлючНастроекКонфигурации(Конфигурация);
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(Настройки, Новый СжатиеДанных(6));
	МенеджерЗаписи.Записать();
	
КонецПроцедуры

Процедура УдалитьНастройкиКонфигурации(Конфигурация) Экспорт
	
	МенеджерЗаписи = РегистрыСведений.БезопасноеХранилищеДанных.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Владелец = КлючНастроекКонфигурации(Конфигурация);
	МенеджерЗаписи.Прочитать();
	Если МенеджерЗаписи.Выбран() Тогда
		МенеджерЗаписи.Удалить();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПустоеОписаниеМетаданных()
	Возврат Новый Структура("count", 0);
КонецФункции

Функция ОписаниеМетаданныхПоЗапросу(Конфигурация, ПолноеИмяМетаданных, НастройкиКонфигурации)
	
	ЧастиИмени = СтрРазделить(ПолноеИмяМетаданных, ".");
	ЭтоМодуль = ЧастиИмени[0] = "module";
	
	Если НастройкиКонфигурации.ЗагружатьИзФайлов Тогда
		Если ЭтоМодуль Тогда
			Если ЧастиИмени.Количество() = 2 Тогда
				ОписаниеМетаданных = ЗагрузитьМодульОбъектаИзФайла(Конфигурация, "module", "общиемодули", ЧастиИмени[1]);
			Иначе
				ОписаниеМетаданных = ЗагрузитьМодульОбъектаИзФайла(Конфигурация, ЧастиИмени[1], ЧастиИмени[2], ЧастиИмени[3]);
			КонецЕсли;
		ИначеЕсли ЧастиИмени.Количество() = 1 Тогда
			ОписаниеМетаданных = ЗагрузитьКоллекциюОбъектовИзФайлов(Конфигурация, ЧастиИмени[0]);
		Иначе
			ОписаниеМетаданных = ЗагрузитьОбъектИзФайла(Конфигурация, ЧастиИмени[0], ЧастиИмени[1]);
		КонецЕсли;
	Иначе
		Если ЭтоМодуль Тогда
			ОписаниеМетаданных = Неопределено;
		ИначеЕсли ЧастиИмени.Количество() = 1 Тогда
			ОписаниеМетаданных = ОписатьКоллекциюОбъектовПоДаннымИБ(Конфигурация, ЧастиИмени[0]);
		Иначе
			ОписаниеМетаданных = ОписатьОбъектПоДаннымИБ(Конфигурация, ЧастиИмени[0], ЧастиИмени[1]);
		КонецЕсли;
	КонецЕсли;
	Если ОписаниеМетаданных = Неопределено Тогда
		ОписаниеМетаданных = ПустоеОписаниеМетаданных(); // Пустое описание метаданных для сохранения в кэше
	КонецЕсли;
	
	Возврат ОбъектВСтрокуJSON(ОписаниеМетаданных);
	
КонецФункции

Функция ОписаниеГлобальногоКонтекстаПоЗапросу(Конфигурация, НастройкиКонфигурации)
	
	ОписаниеОбщихМодулей = Новый Структура("ГлобальныеМодули,ОбщиеМодули");
	Если НастройкиКонфигурации.МестоХраненияИндексов <> 3 Тогда
		ОписаниеОбщихМодулей.ГлобальныеМодули = ОписаниеМетаданных(Конфигурация, "globalfunctions", НастройкиКонфигурации, Ложь);
		ОписаниеОбщихМодулей.ОбщиеМодули = ОписаниеМетаданных(Конфигурация, "commonmodules.items", НастройкиКонфигурации, Ложь);
	КонецЕсли;
	Если ОписаниеОбщихМодулей.ГлобальныеМодули = Неопределено И НастройкиКонфигурации.ЗагружатьИзФайлов Тогда
		ОписаниеОбщихМодулей = ЗагрузитьГлобальныйКонтекстИзФайлов(Конфигурация, НастройкиКонфигурации.ЗагружатьМетодыМодулей);
	КонецЕсли;
	
	Возврат ОписаниеОбщихМодулей;
	
КонецФункции

Функция ОписатьКоллекциюОбъектовПоДаннымИБ(Конфигурация, КорневойТип)
	
	ВсеКорневыеТипы = КД3_МетаданныеПовтИсп.ВсеКорневыеТипы(); 
	СтрокаТипа = ВсеКорневыеТипы.Найти(КорневойТип, "Мн");
	Если СтрокаТипа = Неопределено Тогда
		СтрокаТипа = ВсеКорневыеТипы.Найти(КорневойТип, "console");		
	КонецЕсли;
	Если СтрокаТипа = Неопределено ИЛИ СтрокаТипа.НетВКД3 Тогда
		Возврат Неопределено; // Объекты этого типа нельзя получить из БД
	КонецЕсли;
	ТипОбъекта = Перечисления.ТипыОбъектов[СтрокаТипа.Ед];
	ИмяКоллекции = СтрокаТипа.console;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Объекты.Ссылка КАК Ссылка,
	|	Объекты.Имя КАК Имя
	|ИЗ
	|	Справочник.Объекты КАК Объекты
	|ГДЕ
	|	Объекты.Владелец = &Конфигурация
	|	И Объекты.Тип = &ТипОбъекта
	|	И НЕ Объекты.ПометкаУдаления";
	Запрос.УстановитьПараметр("Конфигурация", Конфигурация);
	Запрос.УстановитьПараметр("ТипОбъекта", ТипОбъекта);
	
	ОписаниеКоллекции = Новый Структура;
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		ОписаниеКоллекции.Вставить(Выборка.Имя, Новый Структура);
	КонецЦикла;
	
	ОписаниеМетаданных = Новый Структура;
	ОписаниеМетаданных.Вставить("path", ИмяКоллекции + ".items");
	ОписаниеМетаданных.Вставить("data", ОписаниеКоллекции);
	ОписаниеМетаданных.Вставить("count", ОписаниеКоллекции.Количество());
	
	Возврат ОписаниеМетаданных;
	
КонецФункции

Функция ОписатьОбъектПоДаннымИБ(Конфигурация, КорневойТип, ИмяОбъекта)
	
	ВсеКорневыеТипы = КД3_МетаданныеПовтИсп.ВсеКорневыеТипы();
	СтрокаТипа = ВсеКорневыеТипы.Найти(КорневойТип, "Мн");
	Если СтрокаТипа = Неопределено Тогда
		СтрокаТипа = ВсеКорневыеТипы.Найти(КорневойТип, "console");		
	КонецЕсли;
	Если СтрокаТипа = Неопределено ИЛИ СтрокаТипа.НетВКД3 Тогда
		Возврат Неопределено; // Объекты этого типа нельзя получить из БД
	КонецЕсли;
	
	ТипОбъекта = Перечисления.ТипыОбъектов[СтрокаТипа.Ед];
	ИмяКоллекции = СтрокаТипа.console;
	
	// Получение объекта
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Объекты.Ссылка КАК Ссылка,
	|	Объекты.Имя КАК Имя,
	|	Объекты.Периодичность КАК Периодичность
	|ИЗ
	|	Справочник.Объекты КАК Объекты
	|ГДЕ
	|	Объекты.Владелец = &Конфигурация
	|	И Объекты.Тип = &ТипОбъекта
	|	И Объекты.Имя = &ИмяОбъекта
	|	И НЕ ПометкаУдаления";
	Запрос.УстановитьПараметр("Конфигурация", Конфигурация);
	Запрос.УстановитьПараметр("ТипОбъекта", ТипОбъекта);
	Запрос.УстановитьПараметр("ИмяОбъекта", ИмяОбъекта);
	
	ВыборкаОбъект = Запрос.Выполнить().Выбрать();
	Если НЕ ВыборкаОбъект.Следующий() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// Получение реального имени объекта, так как в параметре оно в нижнем регистре
	ИмяОбъекта = ВыборкаОбъект.Имя;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Значения.Наименование КАК Наименование,
	|	Значения.Синоним КАК Синоним
	|ИЗ
	|	Справочник.Значения КАК Значения
	|ГДЕ
	|	Значения.Владелец = &Объект
	|	И НЕ Значения.ПометкаУдаления
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Свойства.Ссылка КАК Ссылка,
	|	Свойства.Родитель КАК Родитель,
	|	Свойства.Вид КАК Вид,
	|	Свойства.Наименование КАК Наименование,
	|	Свойства.Синоним КАК Синоним
	|ИЗ
	|	Справочник.Свойства КАК Свойства
	|ГДЕ
	|	Свойства.Владелец = &Объект
	|	И Свойства.Вид В(&ВидыСвойств)
	|	И НЕ ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Свойства.ЭтоГруппа УБЫВ";
	
	ОписаниеРеквизитов = Новый Структура;
	ОписаниеРесурсов = Новый Структура;
	ОписаниеПредопределенных = Новый Структура;
	ОписаниеТабЧастей = Новый Структура;
	
	СтруктураОбъекта = Новый Структура;
	СтруктураОбъекта.Вставить("properties", ОписаниеРеквизитов);
	СтруктураОбъекта.Вставить("predefined", ОписаниеПредопределенных);
	СтруктураОбъекта.Вставить("resources", ОписаниеРесурсов);
	СтруктураОбъекта.Вставить("tabulars", ОписаниеТабЧастей);
	
	ОписаниеМетаданных = Новый Структура;
	ОписаниеМетаданных.Вставить("path", СтрШаблон("%1.items.%2", ИмяКоллекции, ИмяОбъекта));
	ОписаниеМетаданных.Вставить("data", СтруктураОбъекта);
	ОписаниеМетаданных.Вставить("count", 1);
	
	ВидыСвойств = Новый Массив;
	ВидыСвойств.Добавить(Перечисления.ВидыСвойств.Свойство);
	ВидыСвойств.Добавить(Перечисления.ВидыСвойств.Реквизит);
	Если КД3_МетаданныеПовтИсп.КорневойТипРегистра(КорневойТип) Тогда
		ВидыСвойств.Добавить(Перечисления.ВидыСвойств.Измерение);
		ВидыСвойств.Добавить(Перечисления.ВидыСвойств.Ресурс);
	Иначе
		// Стандартное свойство Ссылка
		ОписаниеСвойства = Новый Структура("name", "");
		ДобавитьОписаниеТипаСвойстваПоДаннымИБ(ОписаниеСвойства, ВыборкаОбъект.Ссылка);
		ОписаниеРеквизитов.Вставить("Ссылка", ОписаниеСвойства);
	КонецЕсли;
	Если КД3_МетаданныеПовтИсп.КорневойТипТЧ(КорневойТип) Тогда
		ВидыСвойств.Добавить(Перечисления.ВидыСвойств.ТабличнаяЧасть);
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Объект", ВыборкаОбъект.Ссылка);
	Запрос.УстановитьПараметр("ВидыСвойств", ВидыСвойств);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	СоответствиеТабЧастей = Новый Соответствие;
	
	Если КД3_МетаданныеПовтИсп.КорневойТипЗначений(КорневойТип) Тогда
		ВыборкаЗначений = РезультатЗапроса[0].Выбрать();
		Пока ВыборкаЗначений.Следующий() Цикл
			Если НЕ ПустаяСтрока(ВыборкаЗначений.Наименование) Тогда
				ОписаниеПредопределенных.Вставить(ВыборкаЗначений.Наименование);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ВыборкаСвойств = РезультатЗапроса[1].Выбрать();
	Пока ВыборкаСвойств.Следующий() Цикл
		Если ЗначениеЗаполнено(ВыборкаСвойств.Родитель) Тогда
			КоллекцияДляДобавления = СоответствиеТабЧастей[ВыборкаСвойств.Родитель];
			ОписаниеСвойства = Новый Структура("name", ВыборкаСвойств.Синоним);
			ДобавитьОписаниеТипаСвойстваПоДаннымИБ(ОписаниеСвойства, ВыборкаСвойств.Ссылка);
		Иначе
			КоллекцияДляДобавления = ?(ВыборкаСвойств.Вид = Перечисления.ВидыСвойств.Ресурс, ОписаниеРесурсов, ОписаниеРеквизитов);
			Если ВыборкаСвойств.Вид = Перечисления.ВидыСвойств.ТабличнаяЧасть Тогда
				ОписаниеТабЧасти = Новый Структура;
				ОписаниеТабЧастей.Вставить(ВыборкаСвойств.Наименование, ОписаниеТабЧасти);
				СоответствиеТабЧастей.Вставить(ВыборкаСвойств.Ссылка, ОписаниеТабЧасти);
				
				ОписаниеСвойства = Новый Структура("name", "ТЧ: " + ВыборкаСвойств.Синоним);
			Иначе
				ОписаниеСвойства = Новый Структура("name", ВыборкаСвойств.Синоним);
				ДобавитьОписаниеТипаСвойстваПоДаннымИБ(ОписаниеСвойства, ВыборкаСвойств.Ссылка);
			КонецЕсли;
		КонецЕсли;
		КоллекцияДляДобавления.Вставить(ВыборкаСвойств.Наименование, ОписаниеСвойства);
	КонецЦикла;
	
	Возврат ОписаниеМетаданных;
	
КонецФункции

Процедура ДобавитьОписаниеТипаСвойстваПоДаннымИБ(ОписаниеСвойства, СвойствоСсылка)
	
	Запрос = Новый Запрос("ВЫБРАТЬ Тип.Наименование КАК Тип Из Справочник.Свойства.Типы ГДЕ Ссылка = &Ссылка");
	Запрос.УстановитьПараметр("Ссылка", СвойствоСсылка);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		ПозТочки = СтрНайти(Выборка.Тип, ".");
		Если ПозТочки > 0 Тогда
			КорневойТип = СтрЗаменить(Лев(Выборка.Тип, ПозТочки - 1), "Ссылка", "");
			Имя = Сред(Выборка.Тип, ПозТочки + 1);
			ВсеКорневыеТипы = КД3_МетаданныеПовтИсп.ВсеКорневыеТипы();
			СтрокаТипа = ВсеКорневыеТипы.Найти(КорневойТип, "Ед");
			Если СтрокаТипа <> Неопределено Тогда 
				ОписаниеСвойства.Вставить("ref", СтрокаТипа.console + "." + Имя);
				Прервать;
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры


Функция ИнициализацияПараметровЗагрузкиИзФайла(Конфигурация)
	
	ПараметрыЗагрузки = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Конфигурация, "ИсточникДанных,КаталогЗагрузки,ЕстьРасширения,Расширения");
	
	ПараметрыЗагрузки.Вставить("ЭтоРасширение", Ложь);
	ПараметрыЗагрузки.Вставить("ПутьКФайламРасширения", "");
	ПараметрыЗагрузки.Вставить("ПомещенныеФайлы", Неопределено); // Прямой поиск по файлам
	ПараметрыЗагрузки.Вставить("КД3_ЭтоСервер", Истина);
	ПараметрыЗагрузки.Вставить("КД3_ИспользоватьКонтекстнуюПодсказку", Истина);
	
	Возврат ПараметрыЗагрузки;
	
КонецФункции

Функция ЗагрузитьГлобальныйКонтекстИзФайлов(Конфигурация, ЗагружатьМетодыМодулей)
	
	ПараметрыЗагрузки = ИнициализацияПараметровЗагрузкиИзФайла(Конфигурация);
	ПараметрыЗагрузки.Вставить("КД3_ЗагружатьМетодыМодулей", ЗагружатьМетодыМодулей);
	
	КД3_ЗагрузкаМетаданных.ПодключитьВычислитель(ПараметрыЗагрузки);
	КД3_ЗагрузкаМетаданных.ОбработатьГруппуОбщихМодулей(ПараметрыЗагрузки);
	
	Если ПараметрыЗагрузки.ЕстьРасширения Тогда
		ПараметрыЗагрузки.ЭтоРасширение = Истина;
		ВыборкаРасширение = ПараметрыЗагрузки.Расширения.Выбрать();
		Пока ВыборкаРасширение.Следующий() Цикл
			Если НЕ ПустаяСтрока(ВыборкаРасширение.ИмяКаталогаЗагрузки) Тогда
				ПараметрыЗагрузки.ПутьКФайламРасширения = ВыборкаРасширение.ИмяКаталогаЗагрузки;
				КД3_ЗагрузкаМетаданных.ОбработатьГруппуОбщихМодулей(ПараметрыЗагрузки);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ОписаниеОбщихМодулей = Новый Структура;
	ОписаниеОбщихМодулей.Вставить("ГлобальныеМодули", ОбъектВСтрокуJSON(КД3_ЗагрузкаМетаданных.КоллекцияОбъектов(ПараметрыЗагрузки, "globalfunctions", Истина)));
	ОписаниеОбщихМодулей.Вставить("ОбщиеМодули", ОбъектВСтрокуJSON(КД3_ЗагрузкаМетаданных.КоллекцияОбъектов(ПараметрыЗагрузки, "commonModules.items", Ложь)));
	
	Возврат ОписаниеОбщихМодулей;
	
КонецФункции

Функция ЗагрузитьКоллекциюОбъектовИзФайлов(Конфигурация, ИмяКоллекции)
	
	ПараметрыЗагрузки = ИнициализацияПараметровЗагрузкиИзФайла(Конфигурация);
	
	КлючКоллекции = Неопределено;
	
	КД3_ЗагрузкаМетаданных.ОбработатьГруппуОбъектов(ПараметрыЗагрузки, КлючКоллекции, ИмяКоллекции);
	
	Если ПараметрыЗагрузки.ЕстьРасширения Тогда
		ПараметрыЗагрузки.ЭтоРасширение = Истина;
		ВыборкаРасширение = ПараметрыЗагрузки.Расширения.Выбрать();
		Пока ВыборкаРасширение.Следующий() Цикл
			Если НЕ ПустаяСтрока(ВыборкаРасширение.ИмяКаталогаЗагрузки) Тогда
				ПараметрыЗагрузки.ПутьКФайламРасширения = ВыборкаРасширение.ИмяКаталогаЗагрузки;
				КД3_ЗагрузкаМетаданных.ОбработатьГруппуОбъектов(ПараметрыЗагрузки, КлючКоллекции, ИмяКоллекции);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат КД3_ЗагрузкаМетаданных.КоллекцияОбъектов(ПараметрыЗагрузки, КлючКоллекции, Ложь);
	
КонецФункции

Функция ЗагрузитьОбъектИзФайла(Конфигурация, ИмяКоллекции, ИмяОбъекта)
	
	ПараметрыЗагрузки = ИнициализацияПараметровЗагрузкиИзФайла(Конфигурация);
	
	КлючКоллекции = Неопределено;
	
	КД3_ЗагрузкаМетаданных.ОбработатьОбъект(ПараметрыЗагрузки, КлючКоллекции, ИмяКоллекции, ИмяОбъекта);
	
	Если ПараметрыЗагрузки.ЕстьРасширения Тогда
		ПараметрыЗагрузки.ЭтоРасширение = Истина;
		ВыборкаРасширение = ПараметрыЗагрузки.Расширения.Выбрать();
		Пока ВыборкаРасширение.Следующий() Цикл
			Если НЕ ПустаяСтрока(ВыборкаРасширение.ИмяКаталогаЗагрузки) Тогда
				ПараметрыЗагрузки.ПутьКФайламРасширения = ВыборкаРасширение.ИмяКаталогаЗагрузки;
				КД3_ЗагрузкаМетаданных.ОбработатьОбъект(ПараметрыЗагрузки, КлючКоллекции, ИмяКоллекции, ИмяОбъекта);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат КД3_ЗагрузкаМетаданных.КоллекцияОбъектов(ПараметрыЗагрузки, КлючКоллекции, Ложь);
	
КонецФункции

Функция ЗагрузитьМодульОбъектаИзФайла(Конфигурация, ВидМодуля, КорневойТип, ИмяОбъекта)
	
	ПараметрыЗагрузки = ИнициализацияПараметровЗагрузкиИзФайла(Конфигурация);
	КД3_ЗагрузкаМетаданных.ПодключитьВычислитель(ПараметрыЗагрузки);
	
	КлючКоллекции = Неопределено;
	
	КД3_ЗагрузкаМетаданных.ЗагрузитьМодульОбъекта(ПараметрыЗагрузки, КлючКоллекции, Конфигурация, ВидМодуля, КорневойТип, ИмяОбъекта);
	
	Если ПараметрыЗагрузки.ЕстьРасширения Тогда
		ПараметрыЗагрузки.ЭтоРасширение = Истина;
		ВыборкаРасширение = ПараметрыЗагрузки.Расширения.Выбрать();
		Пока ВыборкаРасширение.Следующий() Цикл
			Если НЕ ПустаяСтрока(ВыборкаРасширение.ИмяКаталогаЗагрузки) Тогда
				ПараметрыЗагрузки.ПутьКФайламРасширения = ВыборкаРасширение.ИмяКаталогаЗагрузки;
				КД3_ЗагрузкаМетаданных.ЗагрузитьМодульОбъекта(ПараметрыЗагрузки, КлючКоллекции, Конфигурация, ВидМодуля, КорневойТип, ИмяОбъекта);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат КД3_ЗагрузкаМетаданных.КоллекцияОбъектов(ПараметрыЗагрузки, КлючКоллекции, Истина);
	
КонецФункции

Функция КлючНастроекКонфигурации(Конфигурация)
	Возврат "КД3_Настройки_" + XMLСтрока(Конфигурация);
КонецФункции

Функция ОбъектВСтрокуJSON(ДанныеОбъекта)
	
	Если ДанныеОбъекта = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ДанныеОбъекта);
	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции

#КонецОбласти