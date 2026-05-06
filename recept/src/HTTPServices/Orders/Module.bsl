Функция OrdersGET(Запрос)
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ЗаказыРезервыОстатки.Счет.Номер КАК НомерСчета,
	|	ЗаказыРезервыОстатки.Счет.Ответственный КАК Ответственный,
	|	ЗаказыРезервыОстатки.Счет.Контрагент КАК Контрагент,
	|	ЗаказыРезервыОстатки.Характеристики.Владелец КАК ВидЛКМ,
	|	ЗаказыРезервыОстатки.Характеристики.Цвет КАК Цвет,
	|	ЗаказыРезервыОстатки.Характеристики.RAL КАК RAL,
	|	ЗаказыРезервыОстатки.Характеристики.Фасовка КАК Фасовка,
	|	ЕСТЬNULL(ТЧТовары.Ссылка.ВходнойКонтроль, ЛОЖЬ) КАК ВК,
	|	ЗаказыРезервыОстатки.КоличествоОстаток КАК Количество,
	|	ЕСТЬNULL(ТЧТовары.Цена, 0) КАК Цена,
	|	ЗаказыРезервыОстатки.Счет.ДатаОтгрузки КАК ДатаОтгрузки,
	|	ЕСТЬNULL(ТЧТовары.Примечание, """") КАК Примечание
	|ИЗ
	|	РегистрНакопления.ЗаказыРезервы.Остатки КАК ЗаказыРезервыОстатки
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Товары КАК ТЧТовары
	|		ПО ЗаказыРезервыОстатки.Счет = ТЧТовары.Ссылка
	|		И ЗаказыРезервыОстатки.Номенклатура = ТЧТовары.Номенклатура
	|		И ЗаказыРезервыОстатки.Характеристики = ТЧТовары.Характеристика";
	
	ЗапросБД = Новый Запрос(ТекстЗапроса);
	Результат = ЗапросБД.Выполнить();
	Выборка = Результат.Выбрать();
	
	МассивДанных = Новый Массив;
	Пока Выборка.Следующий() Цикл
		СтрДанных = Новый Структура;
		СтрДанных.Вставить("accNum",   Строка(Выборка.НомерСчета));
		СтрДанных.Вставить("manager",  Строка(Выборка.Ответственный));
		СтрДанных.Вставить("client",   Строка(Выборка.Контрагент));
		СтрДанных.Вставить("type",     Строка(Выборка.ВидЛКМ));
		СтрДанных.Вставить("color",    Строка(Выборка.Цвет));
		СтрДанных.Вставить("ral",      Строка(Выборка.RAL));
		СтрДанных.Вставить("pack",     Строка(Выборка.Фасовка));
		СтрДанных.Вставить("vk",       ?(Выборка.ВК, "+", ""));
		СтрДанных.Вставить("qty",      Выборка.Количество);
		СтрДанных.Вставить("price",    Выборка.Цена);
		СтрДанных.Вставить("shipDate", ?(ЗначениеЗаполнено(Выборка.ДатаОтгрузки), Формат(Выборка.ДатаОтгрузки, "ДФ=dd.MM.yyyy"), ""));
		СтрДанных.Вставить("note",     Строка(Выборка.Примечание));
		
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
	|	<title>Заказы</title>
	|	<style>
	|		:root {
	|			--bg: #f5f7fa; --surface: #ffffff; --text-main: #1f2937;
	|			--text-muted: #6b7280; --border: #e5e7eb; --primary: #3b82f6;
	|			--highlight: #fef08a; --row-even: #f9fafb; --row-hover: #f3f4f6;
	|		}
	|		body {
	|			font-family: -apple-system, system-ui, sans-serif;
	|			background-color: var(--bg); color: var(--text-main);
	|			margin: 0; padding: 20px; height: 100vh; display: flex; flex-direction: column; box-sizing: border-box;
	|		}
	|		.header-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-shrink: 0; }
	|		h2 { margin: 0; font-size: 20px; font-weight: 600; }
	|		.controls { display: flex; align-items: center; gap: 15px; }
	|		.search-box { padding: 10px 16px; width: 300px; border: 1px solid var(--border); border-radius: 8px; outline: none; font-size: 14px; }
	|		.search-box:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2); }
	|		.btn-print { background-color: var(--surface); border: 1px solid var(--border); padding: 9px 16px; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 6px; transition: 0.2s; }
	|		.btn-print:hover { border-color: var(--primary); color: var(--primary); }
	|		.table-container { background: var(--surface); border-radius: 10px; overflow: auto; flex-grow: 1; border: 1px solid var(--border); box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
	|		table { border-collapse: collapse; width: 100%; font-size: 12px; white-space: nowrap; }
	|		th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid var(--border); border-right: 1px solid var(--border); }
	|		th { background-color: var(--surface); color: var(--text-muted); position: sticky; top: 0; z-index: 10; cursor: pointer; user-select: none; box-shadow: 0 2px 2px -1px rgba(0,0,0,0.1); }
	|		th:hover { color: var(--primary); }
	|		tbody tr:nth-child(even) { background-color: var(--row-even); }
	|		tbody tr:hover { background-color: var(--row-hover) !important; }
	|		.num { text-align: right; font-variant-numeric: tabular-nums; }
	|		mark { background-color: var(--highlight); color: inherit; padding: 1px 2px; border-radius: 2px; }
	|		
	|		/* Стили для печати */
	|		@media print {
	|			@page { size: landscape; margin: 10mm; }
	|			body { padding: 0; background-color: white; height: auto; display: block; }
	|			.header-container { display: none !important; } /* Удаление заголовка и управления при печати */
	|			.table-container { border: none; box-shadow: none; overflow: visible !important; height: auto !important; }
	|			table { width: 100%; white-space: normal; word-wrap: break-word; font-size: 9pt; } /* Шрифт уменьшен на 1pt */
	|			th, td { border: 1px solid #000 !important; padding: 4px; color: #000; }
	|			th { position: static; box-shadow: none; background-color: #f2f2f2 !important; -webkit-print-color-adjust: exact; color-adjust: exact; }
	|			mark { background-color: transparent; }
	|		}
	|	</style>
	|</head>
	|<body>
	|	<div class='header-container'>
	|		<h2>Заказы</h2>
	|		<div class='controls'>
	|			<span id='rowCount' style='font-size: 13px; color: var(--text-muted);'>Отображено: 0</span>
	|			<input type='text' id='searchInput' class='search-box' placeholder='Поиск...'>
	|			<button class='btn-print' onclick='window.print()'>
	|				<svg width='16' height='16' fill='currentColor' viewBox='0 0 16 16'>
	|					<path d='M2.5 8a.5.5 0 1 0 0-1 .5.5 0 0 0 0 1z'/>
	|					<path d='M5 1a2 2 0 0 0-2 2v2H2a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h1v1a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-1h1a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-1V3a2 2 0 0 0-2-2H5zM4 3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2H4V3zm1 5a2 2 0 0 0-2 2v1H2a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v-1a2 2 0 0 0-2-2H5zm7 2v3a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1z'/>
	|				</svg>
	|				Печать
	|			</button>
	|		</div>
	|	</div>
	|	<div class='table-container'>
	|		<table>
	|			<thead>
	|				<tr>
	|					<th onclick='sortData(""accNum"")'>Номер счета<span id='sort-accNum'></span></th>
	|					<th onclick='sortData(""manager"")'>Ответственный<span id='sort-manager'></span></th>
	|					<th onclick='sortData(""client"")'>Контрагент<span id='sort-client'></span></th>
	|					<th onclick='sortData(""type"")'>Вид ЛКМ<span id='sort-type'></span></th>
	|					<th onclick='sortData(""color"")'>Цвет<span id='sort-color'></span></th>
	|					<th onclick='sortData(""ral"")'>RAL<span id='sort-ral'></span></th>
	|					<th onclick='sortData(""pack"")'>Фасовка<span id='sort-pack'></span></th>
	|					<th onclick='sortData(""vk"")'>ВК<span id='sort-vk'></span></th>
	|					<th class='num' onclick='sortData(""qty"")'>Количество<span id='sort-qty'></span></th>
	|					<th class='num' onclick='sortData(""price"")'>Цена<span id='sort-price'></span></th>
	|					<th onclick='sortData(""shipDate"")'>Дата отгрузки<span id='sort-shipDate'></span></th>
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
	|	let currentSort = { key: 'type', dir: 'asc' }; // По умолчанию сортировка по 'Вид ЛКМ'
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
	|			h += `<tr>
	|				<td>${highlight(r.accNum, currentSearch)}</td>
	|				<td>${highlight(r.manager, currentSearch)}</td>
	|				<td>${highlight(r.client, currentSearch)}</td>
	|				<td>${highlight(r.type, currentSearch)}</td>
	|				<td>${highlight(r.color, currentSearch)}</td>
	|				<td>${highlight(r.ral, currentSearch)}</td>
	|				<td>${highlight(r.pack, currentSearch)}</td>
	|				<td>${highlight(r.vk, currentSearch)}</td>
	|				<td class='num'>${highlight(fmt3.format(r.qty), currentSearch)}</td>
	|				<td class='num'>${highlight(fmt2.format(r.price), currentSearch)}</td>
	|				<td>${highlight(r.shipDate, currentSearch)}</td>
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
	|	sortData('type', true); // Первичная сортировка по 'Вид ЛКМ'
	|</script>
	|</body>
	|</html>";
	
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.Заголовки.Вставить("Content-Type", "text/html; charset=utf-8");
	Ответ.УстановитьТелоИзСтроки(HTML, КодировкаТекста.UTF8);
	Возврат Ответ;
	
КонецФункции