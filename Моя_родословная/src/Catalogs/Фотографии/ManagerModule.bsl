Процедура ОбновитьВсеТегиФотографийВРегистре() Экспорт
	
	МенеджерЗаписи = РегистрыСведений.ТегиФотографий.СоздатьМенеджерЗаписи();
		
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ФотографииПерсоны.Ссылка КАК Фотография,
	|	ФотографииПерсоны.Персона КАК Тег
	|ПОМЕСТИТЬ НовыеТеги
	|ИЗ
	|	Справочник.Фотографии.Персоны КАК ФотографииПерсоны
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ФотографииСемьи.Ссылка,
	|	ФотографииСемьи.Семья
	|ИЗ
	|	Справочник.Фотографии.Семьи КАК ФотографииСемьи
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТегиФотографий.Фотография,
	|	ТегиФотографий.Тег
	|ПОМЕСТИТЬ СтарыеТеги
	|ИЗ
	|	РегистрСведений.ТегиФотографий КАК ТегиФотографий
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕстьNull(НовыеТеги.Фотография, СтарыеТеги.Фотография) Как Фотография,
	|	ЕстьNull(НовыеТеги.Тег, СтарыеТеги.Тег) Как Тег,
	|	Выбор
	|		Когда НовыеТеги.Тег Есть Null
	|			Тогда ""Удалить""
	|		Когда СтарыеТеги.Тег Есть Null
	|			Тогда ""Добавить""
	|		Иначе """"
	|	Конец Как Действие
	|ИЗ
	|	СтарыеТеги КАК СтарыеТеги
	|		ПОЛНОЕ Соединение НовыеТеги КАК НовыеТеги
	|		По СтарыеТеги.Фотография = НовыеТеги.Фотография
	|		И СтарыеТеги.Тег = НовыеТеги.Тег
	|Где
	|	Выбор
	|		Когда НовыеТеги.Тег Есть Null
	|			Тогда ""Удалить""
	|		Когда СтарыеТеги.Тег Есть Null
	|			Тогда ""Добавить""
	|		Иначе """"
	|	Конец <> """"";
	Запрос.УстановитьПараметр("", );
	Выборка = Запрос.Выполнить().Выбрать();
		
	Пока Выборка.Следующий() Цикл
		
		МенеджерЗаписи.Тег = Выборка.Тег;
		МенеджерЗаписи.Фотография = Выборка.Фотография;
		МенеджерЗаписи.Прочитать();
		
		Если Выборка.Действие = "Добавить" Тогда
			
			Если Не МенеджерЗаписи.Выбран() Тогда
				
				МенеджерЗаписи.Тег = Выборка.Тег;
				МенеджерЗаписи.Фотография = Выборка.Фотография;
				МенеджерЗаписи.Записать();
				
			КонецЕсли;	
			
		ИначеЕсли Выборка.Действие = "Удалить" Тогда
			 				
			Если МенеджерЗаписи.Выбран() Тогда
				МенеджерЗаписи.Удалить();
			КонецЕсли;				 				
			 				
		КонецЕсли;		
			
	КонецЦикла;
	
КонецПроцедуры	

Процедура ОбновитьТегиФотографииВРегистре(Фотография) Экспорт
	
	НаборЗаписей = РегистрыСведений.ТегиФотографий.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Фотография.Установить(Фотография);
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ФотографииСемьи.Семья Как Тег
	|ИЗ
	|	Справочник.Фотографии.Семьи КАК ФотографииСемьи
	|ГДЕ
	|	ФотографииСемьи.Ссылка = &Фотография
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ФотографииПерсоны.Персона
	|ИЗ
	|	Справочник.Фотографии.Персоны КАК ФотографииПерсоны
	|ГДЕ
	|	ФотографииПерсоны.Ссылка = &Фотография";
	Запрос.УстановитьПараметр("Фотография", Фотография);
	Выборка = Запрос.Выполнить().Выбрать();
		
	Пока Выборка.Следующий() Цикл
			
		Запись = НаборЗаписей.Добавить();
		Запись.Фотография = Фотография;
		Запись.Тег = Выборка.Тег;
			
	КонецЦикла;
	
	НаборЗаписей.Записать();
		
КонецПроцедуры

Функция ПолучитьКоличествоФотографийПоТегу(Тег) Экспорт
	
	Результат = 0;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Количество(Различные ТегиФотографий.Фотография) Как КоличествоФотографий
	|ИЗ
	|	РегистрСведений.ТегиФотографий КАК ТегиФотографий
	|ГДЕ
	|	ТегиФотографий.Тег = &Тег";
	Запрос.УстановитьПараметр("Тег", Тег);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Результат = Выборка.КоличествоФотографий;
	КонецЕсли;	
	
	Возврат Результат	
	
КонецФункции

Функция ПолучитьМассивФотографийПоТегу(Тег) Экспорт
	
	МассивФотографий = Новый Массив();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ТегиФотографий.Фотография
	|ИЗ
	|	РегистрСведений.ТегиФотографий КАК ТегиФотографий
	|ГДЕ
	|	ТегиФотографий.Тег = &Тег";
	Запрос.УстановитьПараметр("Тег", Тег);
		
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
	
		МассивФотографий.Добавить(Выборка.Фотография);	
			
	КонецЦикла;
	
	Возврат МассивФотографий
	
КонецФункции	

Процедура УстановитьОформлениеГиперссылкиФотографий(ЭлементФормы, СтрокаОписания, Тег) Экспорт
	
	КоличествоФотографий = Справочники.Фотографии.ПолучитьКоличествоФотографийПоТегу(Тег);
	
	Если КоличествоФотографий > 0 Тогда
		СтрокаОписания = "Фотографии (" + Строка(КоличествоФотографий) + ")";
		ЭлементФормы.Видимость = Истина;
	Иначе
		ЭлементФормы.Видимость = Ложь;			
	КонецЕсли;
	
КонецПроцедуры			