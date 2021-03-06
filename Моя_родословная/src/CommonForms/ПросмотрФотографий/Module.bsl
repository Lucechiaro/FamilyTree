

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// сделаем загрузку фотографий в зависимости от персоны или тега
	// пока покажем все фотографии
	// возможно, сделаем хранение списка фотографий во временном хранилище, но пока отразим его на форме
	Запрос = Новый Запрос;
	
	Если Параметры.Свойство("Тэг") Тогда
		
		Запрос.Текст = "ВЫБРАТЬ
		|	ФотографииПерсоны.Ссылка КАК СсылкаНаФотографию
		|ИЗ
		|	Справочник.Фотографии.Персоны КАК ФотографииПерсоны
		|ГДЕ
		|	ФотографииПерсоны.Персона = &Тэг
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ФотографииСемьи.Ссылка
		|ИЗ
		|	Справочник.Фотографии.Семьи КАК ФотографииСемьи
		|ГДЕ
		|	ФотографииСемьи.Семья = &Тэг";
		Запрос.УстановитьПараметр("Тэг", Параметры.Тэг);
		
		// установим заголовок по тэгу
		Заголовок = "Фотографии: " + Строка(Параметры.Тэг);
		
	Иначе	
	
		Запрос.Текст = "ВЫБРАТЬ
		|	Фотографии.Ссылка Как СсылкаНаФотографию
		|ИЗ
		|	Справочник.Фотографии КАК Фотографии";
		
		Заголовок = "Фотографии";
	
	КонецЕсли;
	
	ТаблицаФотографий.Загрузить(Запрос.Выполнить().Выгрузить());
	ПутьККаталогуСФотографиями = Константы.ПутьККаталогуСФотографиями.Получить();
		 
	
КонецПроцедуры

&НаКлиенте
Процедура ЛистатьВперед(Команда)
	
	// проверим, что список не закончился
	Если ИндексТекущейФотографии < ТаблицаФотографий.Количество() - 1 Тогда
		
		ИндексТекущейФотографии = ИндексТекущейФотографии + 1;
		ПрочитатьФотографию(ИндексТекущейФотографии);
		УстановитьДоступностьКнопокЛистания(ИндексТекущейФотографии);
		
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ЛистатьНазад(Команда)
	
	// проверим, что список не закончился
	Если ИндексТекущейФотографии > 0 Тогда
		
		ИндексТекущейФотографии = ИндексТекущейФотографии - 1;
		ПрочитатьФотографию(ИндексТекущейФотографии);
		УстановитьДоступностьКнопокЛистания(ИндексТекущейФотографии);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьФотографию(ИндексФотографии)
	
	СтрокаФотографии = ТаблицаФотографий[ИндексФотографии];
	
	Если ПустаяСтрока(СтрокаФотографии.ПутьКФотографии) Тогда
		
		//УИД = ПолучитьУИДФотографии(СтрокаФотографии.СсылкаНаФотографию);
		ДанныеФотографии = ПолучитьДанныеФотографии(СтрокаФотографии.СсылкаНаФотографию);
		ФайлыФотографий = НайтиФайлы(ПутьККаталогуСФотографиями, "*" + ДанныеФотографии.УИД + "*", Истина);
		
		Для Каждого Файл Из ФайлыФотографий Цикл
			
			Если СтрНайти(Файл.Имя, ДанныеФотографии.УИД) > 0 Тогда
				
				СтрокаФотографии.ПутьКФотографии = Файл.ПолноеИмя;
				СтрокаФотографии.АдресВременногоХранилища = ПоместитьФотографиюВоВременноеХранилище(СтрокаФотографии.ПутьКФотографии);
				ЗаполнитьЗначенияСвойств(СтрокаФотографии, ДанныеФотографии);
				Прервать;
								
			КонецЕсли;	
			
		КонецЦикла;
		
	КонецЕсли;
		
	АдресФотографии = СтрокаФотографии.АдресВременногоХранилища;
	ЗаполнитьЗначенияСвойств(ЭтаФорма, СтрокаФотографии, "Дата,Место,Описание");	
	
КонецПроцедуры	

//&НаСервереБезКонтекста
//Функция ПолучитьУИДФотографии(Фотография)
	
	//Возврат XMLСтрока(Фотография);
	
//КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьДанныеФотографии(Фотография)
	
	Результат = Новый Структура("Место,Дата,Описание,УИД", "","","","");
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Фотографии.Место.Представление Как Место,
	|	Фотографии.ДатаФото Как Дата,
	|	Фотографии.Описание
	|ИЗ
	|	Справочник.Фотографии КАК Фотографии
	|ГДЕ
	|	Фотографии.Ссылка = &Фотография";
	Запрос.УстановитьПараметр("Фотография", Фотография);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	ЗаполнитьЗначенияСвойств(Результат, Выборка);
	Результат.УИД = XMLСтрока(Фотография);
		
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ТаблицаФотографий.Количество() > 0 Тогда
		
		ПрочитатьФотографию(ИндексТекущейФотографии);
		УстановитьДоступностьКнопокЛистания(ИндексТекущейФотографии);
		
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Функция ПоместитьФотографиюВоВременноеХранилище(ПутьКФотографии)
	
	Возврат ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ПутьКФотографии), УникальныйИдентификатор)
	
КонецФункции	

&НаКлиенте
Процедура УстановитьДоступностьКнопокЛистания(ИндексФотографии)
	
	Элементы.ЛистатьВперед.Доступность = Не (ИндексФотографии = ТаблицаФотографий.Количество() - 1);
	Элементы.ЛистатьНазад.Доступность = Не (ИндексФотографии = 0);
	
КонецПроцедуры	
	 


