
&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	Если Элементы.Список.ТекущаяСтрока <> Неопределено Тогда
		АдресФотографии = ПолучитьАдресФотографии(Элементы.Список.ТекущаяСтрока);
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьАдресФотографии(Персона)
	
	Возврат ПоместитьВоВременноеХранилище(Персона.ПолучитьОбъект().ХранилищеФотографии.Получить());
	
КонецФункции	
