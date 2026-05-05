Функция BalancesGET(Запрос)
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ОстаткиМатериаловОстатки.Наименование КАК Наименование,
	|	ОстаткиМатериаловОстатки.Партия КАК Партия,
	|	ОстаткиМатериаловОстатки.ОстатокОстаток КАК ОстатокОстаток,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Счет, """") КАК Счет,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Характеристики.Цвет, ""—"") КАК Цвет,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Характеристики.RAL, ""—"") КАК RAL,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Характеристики.Фасовка, """") КАК Фасовка,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Партия.ВходнойКонтроль, ЛОЖЬ) КАК ВходнойКонтроль,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Партия.Брак, """") КАК Брак,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Партия.МестоХранения, """") КАК МестоХранения,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Счет.Контрагент, """") КАК Контрагент,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Счет.Ответственный, """") КАК Ответственный,
	|	ЕСТЬNULL(ЦеныМатериалов.Цена, 0) КАК Цена,
	|	ОстаткиМатериаловОстатки.ОстатокОстаток * ЕСТЬNULL(ЦеныМатериалов.Цена, 0) КАК Сумма,
	|	ЕСТЬNULL(ХарактеристикиПартий.Примечание, """") КАК Примечание,
	|	ЕСТЬNULL(ОстаткиМатериаловОстатки.Наименование.ТипНоменклатуры, """") КАК ТипНоменклатуры
	|ИЗ
	|	РегистрНакопления.ОстаткиМатериалов.Остатки(, Наименование.ТипНоменклатуры В
	|	(ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Продукция), ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Комплект))
	|	И Наименование.Родитель В (ЗНАЧЕНИЕ(Справочник.НоменклатураМатериалы.Продукция))) КАК ОстаткиМатериаловОстатки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ХарактеристикиПартий КАК ХарактеристикиПартий
	|		ПО ОстаткиМатериаловОстатки.Партия = ХарактеристикиПартий.Партия
	|		И ОстаткиМатериаловОстатки.Наименование = ХарактеристикиПартий.Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныМатериалов КАК ЦеныМатериалов
	|		ПО ОстаткиМатериаловОстатки.Партия = ЦеныМатериалов.Партия
	|		И ОстаткиМатериаловОстатки.Наименование = ЦеныМатериалов.Номенклатура";
	
	ЗапросБД = Новый Запрос(ТекстЗапроса);
	Результат = ЗапросБД.Выполнить();
	Выборка = Результат.Выбрать();
	
	// Ссылка для сравнения типа
	ТипКомплект = Перечисления.ТипыНоменклатуры.Комплект;
	
	МассивДанных = Новый Массив;
	Пока Выборка.Следующий() Цикл
		СтрДанных = Новый Структура;
		СтрДанных.Вставить("name",    Строка(Выборка.Наименование));
		СтрДанных.Вставить("color",   Строка(Выборка.Цвет));
		СтрДанных.Вставить("ral",     Строка(Выборка.RAL));
		СтрДанных.Вставить("batch",   Строка(Выборка.Партия));
		СтрДанных.Вставить("qty",     Выборка.ОстатокОстаток);
		СтрДанных.Вставить("pack",    Строка(Выборка.Фасовка));
		СтрДанных.Вставить("ctrl",    ?(Выборка.ВходнойКонтроль, "+", ""));
		СтрДанных.Вставить("defect",  Строка(Выборка.Брак));
		СтрДанных.Вставить("account", Строка(Выборка.Счет));
		СтрДанных.Вставить("place",   Строка(Выборка.МестоХранения));
		СтрДанных.Вставить("client",  Строка(Выборка.Контрагент));
		СтрДанных.Вставить("price",   Выборка.Цена);
		СтрДанных.Вставить("sum",     Выборка.Сумма);
		СтрДанных.Вставить("manager", Строка(Выборка.Ответственный));
		СтрДанных.Вставить("note",    Строка(Выборка.Примечание));
		// Служебное поле для условий оформления
		СтрДанных.Вставить("isSet",   Выборка.ТипНоменклатуры = ТипКомплект);
		
		МассивДанных.Добавить(СтрДанных);
	КонецЦикла;
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, МассивДанных);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	
	HTML = "<!DOCTYPE html>
	|<html lang='ru'>
	|<head>
	|	<meta charset='utf-8'>
	|	<title>АРМ Остатки</title>
	|	<style>
	|		:root {
	|			--bg: #f5f7fa; --surface: #ffffff; --text-main: #1f2937;
	|			--text-muted: #6b7280; --border: #e5e7eb; --primary: #3b82f6;
	|			--highlight: #fef08a; --row-even: #f9fafb; --row-hover: #f3f4f6;
	|			--defect-bg: #fff1f0; /* Светло-красный для брака */
	|		}
	|		body {
	|			font-family: -apple-system, system-ui, sans-serif;
	|			background-color: var(--bg); color: var(--text-main);
	|			margin: 0; padding: 20px; height: 100vh; display: flex; flex-direction: column; box-sizing: border-box;
	|		}
	|		.header-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-shrink: 0; }
	|		h2 { margin: 0; font-size: 20px; font-weight: 600; }
	|		.controls { display: flex; align-items: center; gap: 15px; }
	|		.search-box { padding: 10px 16px; width: 350px; border: 1px solid var(--border); border-radius: 8px; outline: none; font-size: 14px; }
	|		.search-box:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2); }
	|		.table-container { background: var(--surface); border-radius: 10px; overflow: auto; flex-grow: 1; border: 1px solid var(--border); box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
	|		table { border-collapse: collapse; width: 100%; font-size: 12px; white-space: nowrap; }
	|		th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid var(--border); border-right: 1px solid var(--border); }
	|		th { background-color: var(--surface); color: var(--text-muted); position: sticky; top: 0; z-index: 10; cursor: pointer; user-select: none; box-shadow: 0 2px 2px -1px rgba(0,0,0,0.1); }
	|		
	|		/* Стили условного оформления */
	|		.row-set { font-weight: bold; }
	|		.row-billed { color: #555c66 !important; font-style: italic; }
	|		.row-defect { background-color: var(--defect-bg) !important; }
	|		
	|		tbody tr:nth-child(even):not(.row-defect) { background-color: var(--row-even); }
	|		tbody tr:hover { background-color: var(--row-hover) !important; }
	|		
	|		.num { text-align: right; font-variant-numeric: tabular-nums; }
	|		mark { background-color: var(--highlight); color: inherit; padding: 1px 2px; border-radius: 2px; }
	|	</style>
	|</head>
	|<body>
	|	<div class='header-container'>
	|		<h2>Текущие остатки</h2>
	|		<div class='controls'>
	|			<span id='rowCount' style='font-size: 13px; color: var(--text-muted);'>Отображено: 0</span>
	|			<input type='text' id='searchInput' class='search-box' placeholder='Поиск по всем колонкам...'>
	|		</div>
	|	</div>
	|	<div class='table-container'>
	|		<table>
	|			<thead>
	|				<tr>
	|					<th onclick='sortData(""name"")'>Наименование<span id='sort-name'></span></th>
	|					<th onclick='sortData(""color"")'>Цвет<span id='sort-color'></span></th>
	|					<th onclick='sortData(""ral"")'>RAL<span id='sort-ral'></span></th>
	|					<th onclick='sortData(""batch"")'>Партия<span id='sort-batch'></span></th>
	|					<th class='num' onclick='sortData(""qty"")'>Остаток<span id='sort-qty'></span></th>
	|					<th onclick='sortData(""pack"")'>Фасовка<span id='sort-pack'></span></th>
	|					<th onclick='sortData(""ctrl"")'>Контроль<span id='sort-ctrl'></span></th>
	|					<th onclick='sortData(""defect"")'>Брак<span id='sort-defect'></span></th>
	|					<th onclick='sortData(""account"")'>Счет<span id='sort-account'></span></th>
	|					<th onclick='sortData(""place"")'>Место хранения<span id='sort-place'></span></th>
	|					<th onclick='sortData(""client"")'>Контрагент<span id='sort-client'></span></th>
	|					<th class='num' onclick='sortData(""price"")'>Цена<span id='sort-price'></span></th>
	|					<th class='num' onclick='sortData(""sum"")'>Сумма<span id='sort-sum'></span></th>
	|					<th onclick='sortData(""manager"")'>Ответственный<span id='sort-manager'></span></th>
	|					<th onclick='sortData(""note"")'>Примечание<span id='sort-note'></span></th>
	|				</tr>
	|			</thead>
	|			<tbody id='tableBody'></tbody>
	|		</table>
	|	</div>
	|
	|<script>
	|	const allData = " + СтрокаJSON + ";
	|	let filteredData = [...allData];
	|	let currentSort = { key: 'name', dir: 'asc' };
	|	let currentSearch = '';
	|	
	|	const fmt3 = new Intl.NumberFormat('ru-RU', { minimumFractionDigits: 3, maximumFractionDigits: 3 });
	|	const fmt2 = new Intl.NumberFormat('ru-RU', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
	|
	|	function highlight(t, q) {
	|		if (!q || t == null) return t;
	|		return String(t).replace(new RegExp(`(${q.replace(/[.*+?^${}()|[\]\\]/g, '\\\\$&')})`, 'gi'), '<mark>$1</mark>');
	|	}
	|
	|	function renderTable() {
	|		let h = '';
	|		for (let r of filteredData) {
	|			// Формируем список классов для строки
	|			let classes = [];
	|			if (r.isSet) classes.push('row-set');     // Условие 1: Комплект -> Жирный
	|			if (r.account) classes.push('row-billed'); // Условие 2: Счет заполнен -> Курсив и Серый
	|			if (r.defect) classes.push('row-defect'); // Условие 3: Брак заполнен -> Красный фон
	|			
	|			h += `<tr class='${classes.join(' ')}'>
	|				<td>${highlight(r.name, currentSearch)}</td>
	|				<td>${highlight(r.color, currentSearch)}</td>
	|				<td>${highlight(r.ral, currentSearch)}</td>
	|				<td>${highlight(r.batch, currentSearch)}</td>
	|				<td class='num'>${highlight(fmt3.format(r.qty), currentSearch)}</td>
	|				<td>${highlight(r.pack, currentSearch)}</td>
	|				<td>${highlight(r.ctrl, currentSearch)}</td>
	|				<td>${highlight(r.defect, currentSearch)}</td>
	|				<td>${highlight(r.account, currentSearch)}</td>
	|				<td>${highlight(r.place, currentSearch)}</td>
	|				<td>${highlight(r.client, currentSearch)}</td>
	|				<td class='num'>${highlight(fmt2.format(r.price), currentSearch)}</td>
	|				<td class='num'>${highlight(fmt2.format(r.sum), currentSearch)}</td>
	|				<td>${highlight(r.manager, currentSearch)}</td>
	|				<td>${highlight(r.note, currentSearch)}</td>
	|			</tr>`;
	|		}
	|		document.getElementById('tableBody').innerHTML = h;
	|		document.getElementById('rowCount').textContent = `Отображено: ${filteredData.length}`;
	|	}
	|
	|	function sortData(key, keepDir = false) {
	|		document.querySelectorAll('th span').forEach(s => s.textContent = '');
	|		if (!keepDir) {
	|			if (currentSort.key === key) currentSort.dir = currentSort.dir === 'asc' ? 'desc' : 'asc';
	|			else { currentSort.key = key; currentSort.dir = 'asc'; }
	|		}
	|		document.getElementById(`sort-${key}`).textContent = currentSort.dir === 'asc' ? ' ▼' : ' ▲';
	|		filteredData.sort((a, b) => {
	|			let vA = a[key], vB = b[key];
	|			if (typeof vA === 'string') { vA = vA.toLowerCase(); vB = vB.toLowerCase(); }
	|			return currentSort.dir === 'asc' ? (vA < vB ? -1 : vA > vB ? 1 : 0) : (vA > vB ? -1 : vA < vB ? 1 : 0);
	|		});
	|		renderTable();
	|	}
	|
	|	let st;
	|	document.getElementById('searchInput').addEventListener('input', e => {
	|		clearTimeout(st);
	|		st = setTimeout(() => {
	|			currentSearch = e.target.value.trim().toLowerCase();
	|			filteredData = !currentSearch ? [...allData] : allData.filter(r => 
	|				Object.values(r).some(v => String(v).toLowerCase().includes(currentSearch))
	|			);
	|			sortData(currentSort.key, true);
	|		}, 250);
	|	});
	|
	|	sortData('name', true);
	|</script>
	|</body>
	|</html>";
	
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.Заголовки.Вставить("Content-Type", "text/html; charset=utf-8");
	Ответ.УстановитьТелоИзСтроки(HTML, КодировкаТекста.UTF8);
	Возврат Ответ;
	
КонецФункции