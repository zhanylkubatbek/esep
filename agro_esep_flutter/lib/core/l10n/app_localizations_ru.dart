// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AgroESEP';

  @override
  String get navHome => 'Главная';

  @override
  String get navModel => 'Модель';

  @override
  String get navAbout => 'Проект';

  @override
  String get navCalculator => 'Расчёт';

  @override
  String get navHistory => 'История';

  @override
  String get instituteName => 'Институт математики НАН КР';

  @override
  String get contactsTitle => 'Контакты';

  @override
  String get contactsLink => 'Контакты института';

  @override
  String get contactsAddress => 'Адрес';

  @override
  String get contactsPhone => 'Телефон';

  @override
  String get contactsEmail => 'Электронная почта';

  @override
  String get contactsHead => 'Руководитель проекта';

  @override
  String get onlineCalculation => 'Онлайн-расчёт';

  @override
  String get ctaCalculate => 'Рассчитать оптимальное решение';

  @override
  String get ctaAbout => 'О проекте';

  @override
  String get ctaStart => 'Начать расчёт';

  @override
  String get ctaNext => 'Дальше';

  @override
  String get howItWorksTitle => 'Как работает калькулятор?';

  @override
  String get howItWorksSubtitle => 'Четыре шага, около пяти минут.';

  @override
  String get modelFormulas => 'Формулы';

  @override
  String get modelGlossary => 'Обозначения';

  @override
  String get aboutTab => 'О проекте';

  @override
  String get goalsTab => 'Цель и задачи';

  @override
  String get resultsTab => 'Результаты';

  @override
  String get relevanceTitle => 'Актуальность';

  @override
  String get goalTitle => 'Цель проекта';

  @override
  String get tasksTitle => 'Основные задачи';

  @override
  String get tasksBadge => 'задачи';

  @override
  String get expectedResultsTitle => 'Ожидаемые результаты';

  @override
  String get resultsBadge => 'результаты';

  @override
  String get practicalValueTitle => 'Практическая значимость';

  @override
  String get valueBadge => 'значимость';

  @override
  String get wizardTitle => 'Расчёт хозяйства';

  @override
  String wizardStep(int current, int total) {
    return 'ШАГ $current ИЗ $total';
  }

  @override
  String get stepFarmTypeQuestion => 'Какое у вас хозяйство?';

  @override
  String get stepFarmTypeHint =>
      'От этого зависят нормативы, по которым выполняется расчёт.';

  @override
  String get stepLandQuestion => 'Сколько у вас земли?';

  @override
  String get stepLandHint => 'Площадь в гектарах по каждому виду угодий.';

  @override
  String get stepLandEmptyHint =>
      'Заполняется только то, что есть. Пустое поле не ошибка: у большинства хозяйств не все виды угодий сразу.';

  @override
  String stepLandTotal(String area) {
    return 'Всего $area га. Если часть земли арендована, укажите её вместе с собственной.';
  }

  @override
  String get stepPlanQuestion => 'Сколько продукции планируете получить?';

  @override
  String get stepPlanHint =>
      'За год. Заполните только то, что собираетесь производить.';

  @override
  String get stepPlanWarningFootnote =>
      'Предупреждение не блокирует расчёт: если значение верное, продолжайте.';

  @override
  String get stepBreedsQuestion => 'Какие породы вы можете содержать?';

  @override
  String get stepBreedsHint =>
      'Отметьте доступные. Под названием — нормативы института. Можно указать, сколько голов вы способны содержать.';

  @override
  String stepBreedsUncovered(String products) {
    return 'Ни одна выбранная порода не даёт: $products. Добавьте подходящую породу или уберите этот вид из плана.';
  }

  @override
  String get stepReviewTitle => 'Проверьте данные';

  @override
  String get stepReviewQuestion => 'Всё верно?';

  @override
  String get stepReviewHint =>
      'Любой блок можно поправить на месте, не возвращаясь по всей цепочке.';

  @override
  String get stepReviewEdit => 'ИЗМЕНИТЬ';

  @override
  String get blockFarm => 'ХОЗЯЙСТВО';

  @override
  String get blockFarmType => 'Тип';

  @override
  String get blockLand => 'УГОДЬЯ';

  @override
  String get blockPlan => 'ПЛАН ПРОИЗВОДСТВА';

  @override
  String get blockBreeds => 'ПОРОДЫ';

  @override
  String get yes => 'да';

  @override
  String get ctaSolve => 'Рассчитать оптимальный вариант';

  @override
  String get ctaSolveSubtitle =>
      'расчёт занимает несколько секунд, интернет не нужен';

  @override
  String get solvingTitle => 'Подбираем оптимальный вариант';

  @override
  String get solvingDescription =>
      'Перебираются сочетания культур и поголовья, чтобы суммарные затраты оказались наименьшими.';

  @override
  String get solvingStageChecked => 'Данные проверены';

  @override
  String get solvingStageNormatives => 'Нормативы подставлены';

  @override
  String get solvingStageOptimizing => 'Решается задача оптимизации';

  @override
  String get resultTitle => 'Рекомендация';

  @override
  String get resultCostLabel => 'ЗАТРАТЫ ЗА ГОД';

  @override
  String get resultWhatToSow => 'ЧТО ПОСЕЯТЬ';

  @override
  String resultLandUsage(String used, String total) {
    return '$used из $total га';
  }

  @override
  String get resultUnused => 'не занято';

  @override
  String get resultHowManyHeads => 'СКОЛЬКО ГОЛОВ СОДЕРЖАТЬ';

  @override
  String get ctaExplain => 'Как это посчитано';

  @override
  String get ctaOpenHistory => 'Сохранено — открыть мои расчёты';

  @override
  String get ctaSavePdf => 'Сохранить в PDF';

  @override
  String get explainTitle => 'Как это посчитано';

  @override
  String get explainLandUse => 'Использование земли';

  @override
  String get explainFeedBalance => 'Кормовой баланс';

  @override
  String get explainCostStructure => 'Структура затрат';

  @override
  String explainPlanFor(String product) {
    return 'План: $product';
  }

  @override
  String get explainFulfilled => 'выполнен';

  @override
  String get explainNotFulfilled => 'не выполнен';

  @override
  String get explainObserved => 'соблюдён';

  @override
  String get infeasibleTitle => 'Такой план на этой земле не выполнить';

  @override
  String get infeasibleDescription =>
      'Годовой рацион поголовья, нужного для такого плана, не помещается на ваших угодьях.';

  @override
  String get infeasibleMissingLand =>
      'столько пашни не хватает при нынешней урожайности';

  @override
  String get ctaReducePlan => 'Уменьшить план';

  @override
  String get ctaChangeLand => 'Изменить угодья';

  @override
  String get failedOffline => 'Нет подключения';

  @override
  String get failedGeneric => 'Не удалось выполнить расчёт';

  @override
  String get failedDataKept =>
      'Введённые данные сохранены — возвращаться к началу не нужно.';

  @override
  String get ctaRetry => 'Повторить расчёт';

  @override
  String get ctaBackToData => 'Вернуться к данным';

  @override
  String get errorNoConnection =>
      'Нет подключения. Расчёт сохранён и будет отправлен, когда появится связь.';

  @override
  String get errorTimeout =>
      'Сервис расчёта не ответил вовремя. Попробуйте ещё раз.';

  @override
  String get errorServer =>
      'Не удалось выполнить расчёт. Проверьте введённые данные или попробуйте ещё раз.';

  @override
  String get historyTitle => 'Мои расчёты';

  @override
  String get historyEmptyTitle => 'Пока нет сохранённых расчётов';

  @override
  String get historyEmptyDescription =>
      'Каждый выполненный расчёт сохраняется на телефоне и потом открывается без интернета.';

  @override
  String historyQueuedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count расчётов ждут отправки',
      few: '$count расчёта ждут отправки',
      one: '$count расчёт ждёт отправки',
    );
    return '$_temp0. Расчёт уйдёт сам, как только появится связь.';
  }

  @override
  String get historyNewCalculation => 'Новый расчёт';

  @override
  String get historyDelete => 'Удалить расчёт';

  @override
  String get historyCosts => 'Затраты';

  @override
  String get historyHeads => 'Поголовье';

  @override
  String historyHeadsValue(int count) {
    return '$count голов';
  }

  @override
  String get historyNoResult => 'Результата пока нет';

  @override
  String get historyInfeasible => 'План на этой земле не выполнить';

  @override
  String get statusDone => 'готов';

  @override
  String get statusQueued => 'в очереди';

  @override
  String get statusInfeasible => 'невыполним';

  @override
  String get statusFailed => 'ошибка';

  @override
  String demoNormativesWarning(String version) {
    return 'Расчёт выполняется на демонстрационных нормативах ($version). Реальная нормативная база института ещё не подключена.';
  }

  @override
  String normativesLine(String version) {
    return 'Нормативы $version';
  }

  @override
  String solverLine(String version) {
    return 'решатель $version';
  }

  @override
  String get unitHa => 'га';

  @override
  String get unitTons => 'т';

  @override
  String get unitTonsPerYear => 'т/год';

  @override
  String get unitSom => 'сом';

  @override
  String get wizardTitleShort => 'Расчёт';

  @override
  String get noResult => 'Нет результата';

  @override
  String get notSavedYet => 'Расчёт ещё не сохранён';

  @override
  String get unitPerHectare => 'га';

  @override
  String get stepLandTotalNote =>
      'Если часть земли арендована, укажите её вместе с собственной.';

  @override
  String get stepBreedsFix =>
      'Добавьте подходящую породу или уберите этот вид из плана.';

  @override
  String get stepReviewAllCorrect => 'Всё верно?';

  @override
  String get solvingDescriptionFull =>
      'Приложение перебирает сочетания культур и поголовья, чтобы суммарные затраты оказались наименьшими. Расчёт идёт на вашем телефоне.';

  @override
  String get resultCostStructure => 'СТРУКТУРА ЗАТРАТ';

  @override
  String get resultCrops => 'Растениеводство';

  @override
  String get resultLivestock => 'Содержание животных';

  @override
  String get resultOtherCrops => 'Прочие культуры';

  @override
  String get infeasibleFullDescription =>
      'Годовой рацион поголовья, нужного для такого плана, не помещается на ваших угодьях.';

  @override
  String get errorUnknown => 'Неизвестная ошибка.';

  @override
  String get historyEmptyFull =>
      'Каждый выполненный расчёт сохраняется на телефоне. Приложение работает полностью без интернета.';

  @override
  String get compareAction => 'Сравнить';

  @override
  String get compareCancel => 'Отмена';

  @override
  String get compareSelected => 'Сравнить выбранные';

  @override
  String get compareTitle => 'Сравнение';

  @override
  String get compareBefore => 'РАНЬШЕ';

  @override
  String get compareAfter => 'ПОЗЖЕ';

  @override
  String get comparePerYear => 'сом в год';

  @override
  String get compareCropChanges => 'ЧТО МЕНЯЕТСЯ В ПОСЕВАХ';

  @override
  String get compareHerdChanges => 'ЧТО МЕНЯЕТСЯ В ПОГОЛОВЬЕ';

  @override
  String get diffNew => 'новое';

  @override
  String get diffRemoved => 'убрано';

  @override
  String get diffUnchanged => 'без изменений';

  @override
  String get diffMore => 'больше';

  @override
  String get diffLess => 'меньше';

  @override
  String get unitHeads => 'гол.';

  @override
  String get modelTitle => 'Модель';

  @override
  String get farmPeasant => 'Крестьянское (фермерское)';

  @override
  String get farmPeasantHint => 'семейное хозяйство, как правило до 50 га';

  @override
  String get farmCooperative => 'Кооператив';

  @override
  String get farmCooperativeHint => 'объединение нескольких хозяйств';

  @override
  String get farmEnterprise => 'Агропредприятие';

  @override
  String get farmEnterpriseHint => 'сельхозорганизация с наёмными работниками';

  @override
  String get farmHousehold => 'Личное подсобное';

  @override
  String get farmHouseholdHint => 'небольшое хозяйство для собственных нужд';

  @override
  String explainLandUsed(int percent) {
    return 'Занято $percent % угодий. Незанятая земля означает, что на ней корма обходятся дороже.';
  }

  @override
  String get explainFeedText =>
      'Выращено и куплено не меньше, чем требуется на годовой рацион выбранного поголовья. Излишек не планируется: каждая лишняя единица площади увеличивала бы затраты.';

  @override
  String get explainCostText =>
      'Минимизируется сумма затрат на посевы, на содержание животных и на закупку кормов — это и есть целевая функция модели.';

  @override
  String explainPlanText(String produced, String planned) {
    return '$produced т при плане $planned т.';
  }

  @override
  String historyStatsHeads(int count) {
    return '$count голов';
  }

  @override
  String compareStats(int heads, String area) {
    return '$heads голов · $area га посевов';
  }

  @override
  String compareCheaperBy(int percent) {
    return 'Второй вариант дешевле на $percent %.';
  }

  @override
  String compareDearerBy(int percent) {
    return 'Второй вариант дороже на $percent %.';
  }

  @override
  String comparePerYearAmount(String amount) {
    return '$amount сом в год';
  }

  @override
  String compareWas(String value) {
    return 'было $value';
  }

  @override
  String compareSelectedCount(int count) {
    return 'Выбрано: $count из 2';
  }

  @override
  String get failedServiceUnreachable => 'Сервис расчёта недоступен';

  @override
  String get errorServiceUnreachable =>
      'Интернет есть, но сервис расчёта не отвечает. Расчёт сохранён — попробуйте позже или сообщите разработчику.';

  @override
  String contactsNormativesBase(String version) {
    return 'Нормативная база: $version';
  }

  @override
  String get homeTitleShort => 'ММЭ ИМ НАН КР';

  @override
  String get modelFormulaObjective =>
      'Целевая функция — минимум суммарных затрат';

  @override
  String get modelFormulaLandLimit =>
      'Ограничение по размеру посевных площадей';

  @override
  String get modelFormulaFeedBalance =>
      'Кормовой баланс: выращено не меньше, чем требуется';

  @override
  String get modelFormulaPlan => 'Выполнение плана производства продукции';

  @override
  String get modelFormulaNonNegative => 'Неотрицательность посевных площадей';

  @override
  String get modelFormulaInteger => 'Поголовье — целое неотрицательное число';

  @override
  String get modelGlossaryArea =>
      'размер посевной площади k-й категории в хозяйстве';

  @override
  String get modelGlossaryYield =>
      'урожайность j-го вида культуры на k-й категории площади';

  @override
  String get modelGlossaryCropCost =>
      'затраты на единицу k-й площади под j-й вид культуры';

  @override
  String get modelGlossaryFeedNeed =>
      'годовая потребность в j-м виде продукции растениеводства на одно животное l-й породы при производстве h-го вида продукции';

  @override
  String get modelGlossaryYieldPerHead =>
      'объём продукции h-го вида от одного животного l-й породы';

  @override
  String get modelGlossaryPlan => 'запланированный объём продукции h-го вида';

  @override
  String get modelGlossaryHeadCost =>
      'годовой расход на одно животное l-й породы';

  @override
  String get modelGlossaryUnknownArea =>
      'искомое: размер площади k под j-й вид культуры';

  @override
  String get modelGlossaryUnknownHeads =>
      'искомое: количество животных l-й породы для продукции h';

  @override
  String get explainFormulaLand => '(1.2)  сумма x[k][j] по культурам ≤ s[k]';

  @override
  String get explainFormulaPlan => '(1.4)  сумма v[h][l]·y[h][l] ≥ b[h]';

  @override
  String get explainFormulaFeed =>
      '(1.3)  сумма a[k][j]·x[k][j] ≥ сумма q[j][h][l]·y[h][l]';

  @override
  String get explainFormulaCost =>
      '(1.1)  минимум суммы c[k][j]·x[k][j] + d[h][l]·y[h][l] + p[j]·z[j]';

  @override
  String plausibilityTooMuch(String area, String max) {
    return 'Для $area га это очень много. Обычно с такой площади получают не больше $max т. Возможно, указаны литры вместо тонн?';
  }

  @override
  String compareIncomparable(String before, String after) {
    return 'Расчёты выполнены на разных нормативах ($before и $after). Разница в затратах отражает смену базы, а не решение хозяйства.';
  }

  @override
  String get pdfTitle => 'Расчёт оптимального плана хозяйства';

  @override
  String pdfDate(String date) {
    return 'Дата расчёта: $date';
  }

  @override
  String pdfPage(int page, int total) {
    return 'стр. $page из $total';
  }

  @override
  String get pdfNoResult => 'Результат расчёта отсутствует.';

  @override
  String get pdfInputSection => 'Исходные данные';

  @override
  String get pdfFarmType => 'Тип хозяйства';

  @override
  String get pdfAvailableBreeds => 'Доступные породы';

  @override
  String get pdfTotalCost => 'СУММАРНЫЕ ЗАТРАТЫ ЗА ГОД';

  @override
  String pdfWhatToSow(String used, String total) {
    return 'Что посеять — $used из $total га';
  }

  @override
  String get pdfColCrop => 'Культура';

  @override
  String get pdfColLand => 'Угодья';

  @override
  String get pdfColArea => 'Площадь, га';

  @override
  String pdfUnusedLand(String area) {
    return 'Не занято $area га: на этих угодьях корма обходятся дороже.';
  }

  @override
  String pdfHowManyHeads(int heads) {
    return 'Сколько голов содержать — всего $heads';
  }

  @override
  String get pdfColBreed => 'Порода';

  @override
  String get pdfColDirection => 'Направление';

  @override
  String get pdfColHeads => 'Голов';

  @override
  String get pdfCostStructure => 'Структура затрат';

  @override
  String get pdfColItem => 'Статья';

  @override
  String get pdfColShare => 'Доля';

  @override
  String get pdfColSum => 'Сумма, сом';

  @override
  String pdfMissingLand(String area) {
    return 'Не хватает примерно $area га пашни при нынешней урожайности.';
  }

  @override
  String get pdfDemoWarning =>
      'ВНИМАНИЕ: расчёт выполнен на демонстрационных нормативах. Реальная нормативная база института не подключена.';

  @override
  String get adminTitle => 'Нормативная база';

  @override
  String get adminSavedNotice =>
      'База сохранена. Перезапустите приложение, чтобы расчёты пошли по новым нормативам.';

  @override
  String get adminResetNotice =>
      'Возврат к встроенной базе. Перезапустите приложение.';

  @override
  String get adminApply => 'Применить эту базу';

  @override
  String get adminCancel => 'Отменить';

  @override
  String get adminReadingFile => 'Читаем файл…';

  @override
  String get adminPickFile => 'Загрузить файл Excel';

  @override
  String get adminResetToBundled => 'Вернуться к встроенной базе';

  @override
  String get adminCurrentBase => 'ДЕЙСТВУЮЩАЯ БАЗА';

  @override
  String get adminVersion => 'Версия';

  @override
  String get adminSource => 'Источник';

  @override
  String get adminSourceBundled => 'встроена в приложение';

  @override
  String get adminSourceImported => 'загружена вручную';

  @override
  String get adminLandsCount => 'Угодий';

  @override
  String get adminCropsCount => 'Культур';

  @override
  String get adminBreedsCount => 'Пород и направлений';

  @override
  String get adminDemoWarning =>
      'База помечена как демонстрационная — расчёты нельзя предъявлять хозяйствам.';

  @override
  String get adminPreviewTitle => 'ФАЙЛ ПРОЧИТАН — ПРОВЕРЬТЕ';

  @override
  String adminPreviewCrops(String list) {
    return 'Культуры: $list';
  }

  @override
  String adminPreviewBreeds(String list) {
    return 'Породы: $list';
  }

  @override
  String adminIssuesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Файл не загружен — $count замечаний:',
      few: 'Файл не загружен — $count замечания:',
      one: 'Файл не загружен — $count замечание:',
    );
    return '$_temp0';
  }

  @override
  String adminIssuesMore(int count) {
    return '…и ещё $count';
  }

  @override
  String get adminFormatTitle => 'ФОРМАТ ФАЙЛА';

  @override
  String get adminFormatIntro =>
      'Файл .xlsx с листами (первая строка — заголовки):';

  @override
  String get adminFormatLands => 'id · Название';

  @override
  String get adminFormatCrops =>
      'id · Название · Угодье · Урожайность · Затраты · Цена закупки';

  @override
  String get adminFormatProducts => 'id · Название · Единица';

  @override
  String get adminFormatBreeds =>
      'Порода id · Порода · Продукция id · Выход · Затраты · далее по столбцу на каждую культуру — потребность в кормах';

  @override
  String get adminFormatMeta => 'version · значение';

  @override
  String get adminFormatKyColumns =>
      'Кыргызские названия — необязательные столбцы «Название (кырг.)», «Единица (кырг.)» и «Порода (кырг.)». Их можно дописать в конец листа: столбцы ищутся по заголовку, а не по номеру. Без них кыргызский интерфейс покажет русские названия справочника.';

  @override
  String get adminFormatNote =>
      'Одна культура занимает столько строк, на скольких угодьях растёт. Сохраняйте именно .xlsx: CSV из Windows-версии Excel портит кириллицу.';

  @override
  String importIssueAtRow(String sheet, int row, String message) {
    return '«$sheet», строка $row: $message';
  }

  @override
  String importIssueAtSheet(String sheet, String message) {
    return '«$sheet»: $message';
  }

  @override
  String get importFileLabel => 'файл';

  @override
  String importFileUnreadable(String error) {
    return 'не удалось прочитать: $error';
  }

  @override
  String get importSheetMissing => 'лист отсутствует в файле';

  @override
  String get importSheetEmpty => 'лист пуст';

  @override
  String get importNoRows => 'нет ни одной строки';

  @override
  String get importIdAndNameRequired => 'нужны и id, и название';

  @override
  String importUnknownLand(String id) {
    return 'неизвестное угодье «$id»';
  }

  @override
  String get importNumbersRequired =>
      'урожайность и затраты должны быть числами';

  @override
  String get importNameRequired => 'не указано название';

  @override
  String importUnknownCropInHeader(String id) {
    return 'неизвестная культура в заголовке: «$id»';
  }

  @override
  String get importFeedColumnsMissing =>
      'начиная с шестого столбца должны идти id культур — потребность в кормах';

  @override
  String importUnknownProduct(String id) {
    return 'неизвестная продукция «$id»';
  }

  @override
  String get importYieldMustBePositive =>
      'выход продукции должен быть больше нуля';

  @override
  String get importCostMustBeNumber => 'затраты на голову должны быть числом';

  @override
  String get importFeedNeedEmpty => 'не заполнена потребность ни в одном корме';

  @override
  String get stepBreedsLimitLabel => 'Не больше';

  @override
  String get stepBreedsLimitHint =>
      'Оставьте пустым, если поголовье не ограничено';

  @override
  String get resultFeedPurchase => 'ЧТО ПРИДЁТСЯ ДОКУПИТЬ';

  @override
  String get resultFeedPurchaseHint =>
      'Этих кормов своя земля не даёт — модель посчитала их по рыночной цене.';

  @override
  String get resultPurchasedFeed => 'Покупные корма';

  @override
  String get resultSelfSufficient =>
      'Хозяйство полностью обеспечивает себя кормами.';

  @override
  String get modelFormulaBreedLimit =>
      'Предел поголовья по породе, если хозяйство его задало';

  @override
  String get modelFormulaPurchase => 'Закупка кормов неотрицательна';

  @override
  String get modelGlossaryFeedPrice => 'цена тонны j-го корма на рынке';

  @override
  String get modelGlossaryBreedLimit =>
      'предельное поголовье l-й породы в хозяйстве';

  @override
  String get modelGlossaryUnknownPurchase =>
      'искомое: сколько тонн j-го корма придётся докупить';

  @override
  String get explainFeedPurchaseTitle => 'Закупка кормов';

  @override
  String get explainFeedPurchaseNone => 'не потребовалась';

  @override
  String explainFeedPurchaseSome(String tons, String cost) {
    return '$tons т на $cost сом';
  }

  @override
  String get explainFeedPurchaseTextNone =>
      'Весь рацион закрыт своими посевами и пастбищами. Покупать корма не нужно.';

  @override
  String get explainFeedPurchaseTextSome =>
      'Своей земли на весь рацион не хватает. Модель сравнила стоимость гектара и цену корма на рынке и выбрала то, что дешевле.';

  @override
  String get explainFormulaPurchase =>
      '(1.3)  сумма a[k][j]·x[k][j] + z[j] ≥ сумма q[j][h][l]·y[h][l]';

  @override
  String get stepLandPastureNote =>
      'Пастбища учитываются наравне с пашней: подножный корм — самая дешёвая часть рациона.';

  @override
  String get pdfFeedPurchase => 'Что придётся докупить';

  @override
  String get pdfColFeed => 'Корм';

  @override
  String get pdfColTons => 'Тонн';

  @override
  String get pdfSelfSufficient =>
      'Закупка кормов не требуется: хозяйство обеспечивает себя полностью.';
}
