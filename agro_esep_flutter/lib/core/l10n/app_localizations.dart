import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ky'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'AgroESEP'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navModel.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get navModel;

  /// No description provided for @navAbout.
  ///
  /// In ru, this message translates to:
  /// **'Проект'**
  String get navAbout;

  /// No description provided for @navCalculator.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт'**
  String get navCalculator;

  /// No description provided for @navHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get navHistory;

  /// No description provided for @instituteName.
  ///
  /// In ru, this message translates to:
  /// **'Институт математики НАН КР'**
  String get instituteName;

  /// No description provided for @contactsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Контакты'**
  String get contactsTitle;

  /// No description provided for @contactsLink.
  ///
  /// In ru, this message translates to:
  /// **'Контакты института'**
  String get contactsLink;

  /// No description provided for @contactsAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get contactsAddress;

  /// No description provided for @contactsPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get contactsPhone;

  /// No description provided for @contactsEmail.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get contactsEmail;

  /// No description provided for @contactsHead.
  ///
  /// In ru, this message translates to:
  /// **'Руководитель проекта'**
  String get contactsHead;

  /// No description provided for @onlineCalculation.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн-расчёт'**
  String get onlineCalculation;

  /// No description provided for @ctaCalculate.
  ///
  /// In ru, this message translates to:
  /// **'Рассчитать оптимальное решение'**
  String get ctaCalculate;

  /// No description provided for @ctaAbout.
  ///
  /// In ru, this message translates to:
  /// **'О проекте'**
  String get ctaAbout;

  /// No description provided for @ctaStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать расчёт'**
  String get ctaStart;

  /// No description provided for @ctaNext.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get ctaNext;

  /// No description provided for @howItWorksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как работает калькулятор?'**
  String get howItWorksTitle;

  /// No description provided for @howItWorksSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Четыре шага, около пяти минут.'**
  String get howItWorksSubtitle;

  /// No description provided for @modelFormulas.
  ///
  /// In ru, this message translates to:
  /// **'Формулы'**
  String get modelFormulas;

  /// No description provided for @modelGlossary.
  ///
  /// In ru, this message translates to:
  /// **'Обозначения'**
  String get modelGlossary;

  /// No description provided for @aboutTab.
  ///
  /// In ru, this message translates to:
  /// **'О проекте'**
  String get aboutTab;

  /// No description provided for @goalsTab.
  ///
  /// In ru, this message translates to:
  /// **'Цель и задачи'**
  String get goalsTab;

  /// No description provided for @resultsTab.
  ///
  /// In ru, this message translates to:
  /// **'Результаты'**
  String get resultsTab;

  /// No description provided for @relevanceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Актуальность'**
  String get relevanceTitle;

  /// No description provided for @goalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Цель проекта'**
  String get goalTitle;

  /// No description provided for @tasksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Основные задачи'**
  String get tasksTitle;

  /// No description provided for @tasksBadge.
  ///
  /// In ru, this message translates to:
  /// **'задачи'**
  String get tasksBadge;

  /// No description provided for @expectedResultsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ожидаемые результаты'**
  String get expectedResultsTitle;

  /// No description provided for @resultsBadge.
  ///
  /// In ru, this message translates to:
  /// **'результаты'**
  String get resultsBadge;

  /// No description provided for @practicalValueTitle.
  ///
  /// In ru, this message translates to:
  /// **'Практическая значимость'**
  String get practicalValueTitle;

  /// No description provided for @valueBadge.
  ///
  /// In ru, this message translates to:
  /// **'значимость'**
  String get valueBadge;

  /// No description provided for @wizardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт хозяйства'**
  String get wizardTitle;

  /// No description provided for @wizardStep.
  ///
  /// In ru, this message translates to:
  /// **'ШАГ {current} ИЗ {total}'**
  String wizardStep(int current, int total);

  /// No description provided for @stepFarmTypeQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Какое у вас хозяйство?'**
  String get stepFarmTypeQuestion;

  /// No description provided for @stepFarmTypeHint.
  ///
  /// In ru, this message translates to:
  /// **'От этого зависят нормативы, по которым выполняется расчёт.'**
  String get stepFarmTypeHint;

  /// No description provided for @stepLandQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Сколько у вас земли?'**
  String get stepLandQuestion;

  /// No description provided for @stepLandHint.
  ///
  /// In ru, this message translates to:
  /// **'Площадь в гектарах по каждому виду угодий.'**
  String get stepLandHint;

  /// No description provided for @stepLandEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Заполняется только то, что есть. Пустое поле не ошибка: у большинства хозяйств не все виды угодий сразу.'**
  String get stepLandEmptyHint;

  /// No description provided for @stepLandTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего {area} га. Если часть земли арендована, укажите её вместе с собственной.'**
  String stepLandTotal(String area);

  /// No description provided for @stepPlanQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Сколько продукции планируете получить?'**
  String get stepPlanQuestion;

  /// No description provided for @stepPlanHint.
  ///
  /// In ru, this message translates to:
  /// **'За год. Заполните только то, что собираетесь производить.'**
  String get stepPlanHint;

  /// No description provided for @stepPlanWarningFootnote.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение не блокирует расчёт: если значение верное, продолжайте.'**
  String get stepPlanWarningFootnote;

  /// No description provided for @stepBreedsQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Какие породы вы можете содержать?'**
  String get stepBreedsQuestion;

  /// No description provided for @stepBreedsHint.
  ///
  /// In ru, this message translates to:
  /// **'Отметьте доступные. Под названием — нормативы института. Можно указать, сколько голов вы способны содержать.'**
  String get stepBreedsHint;

  /// No description provided for @stepBreedsUncovered.
  ///
  /// In ru, this message translates to:
  /// **'Ни одна выбранная порода не даёт: {products}. Добавьте подходящую породу или уберите этот вид из плана.'**
  String stepBreedsUncovered(String products);

  /// No description provided for @stepReviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте данные'**
  String get stepReviewTitle;

  /// No description provided for @stepReviewQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Всё верно?'**
  String get stepReviewQuestion;

  /// No description provided for @stepReviewHint.
  ///
  /// In ru, this message translates to:
  /// **'Любой блок можно поправить на месте, не возвращаясь по всей цепочке.'**
  String get stepReviewHint;

  /// No description provided for @stepReviewEdit.
  ///
  /// In ru, this message translates to:
  /// **'ИЗМЕНИТЬ'**
  String get stepReviewEdit;

  /// No description provided for @blockFarm.
  ///
  /// In ru, this message translates to:
  /// **'ХОЗЯЙСТВО'**
  String get blockFarm;

  /// No description provided for @blockFarmType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get blockFarmType;

  /// No description provided for @blockLand.
  ///
  /// In ru, this message translates to:
  /// **'УГОДЬЯ'**
  String get blockLand;

  /// No description provided for @blockPlan.
  ///
  /// In ru, this message translates to:
  /// **'ПЛАН ПРОИЗВОДСТВА'**
  String get blockPlan;

  /// No description provided for @blockBreeds.
  ///
  /// In ru, this message translates to:
  /// **'ПОРОДЫ'**
  String get blockBreeds;

  /// No description provided for @yes.
  ///
  /// In ru, this message translates to:
  /// **'да'**
  String get yes;

  /// No description provided for @ctaSolve.
  ///
  /// In ru, this message translates to:
  /// **'Рассчитать оптимальный вариант'**
  String get ctaSolve;

  /// No description provided for @ctaSolveSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'расчёт занимает несколько секунд, интернет не нужен'**
  String get ctaSolveSubtitle;

  /// No description provided for @solvingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подбираем оптимальный вариант'**
  String get solvingTitle;

  /// No description provided for @solvingDescription.
  ///
  /// In ru, this message translates to:
  /// **'Перебираются сочетания культур и поголовья, чтобы суммарные затраты оказались наименьшими.'**
  String get solvingDescription;

  /// No description provided for @solvingStageChecked.
  ///
  /// In ru, this message translates to:
  /// **'Данные проверены'**
  String get solvingStageChecked;

  /// No description provided for @solvingStageNormatives.
  ///
  /// In ru, this message translates to:
  /// **'Нормативы подставлены'**
  String get solvingStageNormatives;

  /// No description provided for @solvingStageOptimizing.
  ///
  /// In ru, this message translates to:
  /// **'Решается задача оптимизации'**
  String get solvingStageOptimizing;

  /// No description provided for @resultTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендация'**
  String get resultTitle;

  /// No description provided for @resultCostLabel.
  ///
  /// In ru, this message translates to:
  /// **'ЗАТРАТЫ ЗА ГОД'**
  String get resultCostLabel;

  /// No description provided for @resultWhatToSow.
  ///
  /// In ru, this message translates to:
  /// **'ЧТО ПОСЕЯТЬ'**
  String get resultWhatToSow;

  /// No description provided for @resultLandUsage.
  ///
  /// In ru, this message translates to:
  /// **'{used} из {total} га'**
  String resultLandUsage(String used, String total);

  /// No description provided for @resultUnused.
  ///
  /// In ru, this message translates to:
  /// **'не занято'**
  String get resultUnused;

  /// No description provided for @resultHowManyHeads.
  ///
  /// In ru, this message translates to:
  /// **'СКОЛЬКО ГОЛОВ СОДЕРЖАТЬ'**
  String get resultHowManyHeads;

  /// No description provided for @ctaExplain.
  ///
  /// In ru, this message translates to:
  /// **'Как это посчитано'**
  String get ctaExplain;

  /// No description provided for @ctaOpenHistory.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено — открыть мои расчёты'**
  String get ctaOpenHistory;

  /// No description provided for @ctaSavePdf.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить в PDF'**
  String get ctaSavePdf;

  /// No description provided for @explainTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как это посчитано'**
  String get explainTitle;

  /// No description provided for @explainLandUse.
  ///
  /// In ru, this message translates to:
  /// **'Использование земли'**
  String get explainLandUse;

  /// No description provided for @explainFeedBalance.
  ///
  /// In ru, this message translates to:
  /// **'Кормовой баланс'**
  String get explainFeedBalance;

  /// No description provided for @explainCostStructure.
  ///
  /// In ru, this message translates to:
  /// **'Структура затрат'**
  String get explainCostStructure;

  /// No description provided for @explainPlanFor.
  ///
  /// In ru, this message translates to:
  /// **'План: {product}'**
  String explainPlanFor(String product);

  /// No description provided for @explainFulfilled.
  ///
  /// In ru, this message translates to:
  /// **'выполнен'**
  String get explainFulfilled;

  /// No description provided for @explainNotFulfilled.
  ///
  /// In ru, this message translates to:
  /// **'не выполнен'**
  String get explainNotFulfilled;

  /// No description provided for @explainObserved.
  ///
  /// In ru, this message translates to:
  /// **'соблюдён'**
  String get explainObserved;

  /// No description provided for @infeasibleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Такой план на этой земле не выполнить'**
  String get infeasibleTitle;

  /// No description provided for @infeasibleDescription.
  ///
  /// In ru, this message translates to:
  /// **'Годовой рацион поголовья, нужного для такого плана, не помещается на ваших угодьях.'**
  String get infeasibleDescription;

  /// No description provided for @infeasibleMissingLand.
  ///
  /// In ru, this message translates to:
  /// **'столько пашни не хватает при нынешней урожайности'**
  String get infeasibleMissingLand;

  /// No description provided for @ctaReducePlan.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить план'**
  String get ctaReducePlan;

  /// No description provided for @ctaChangeLand.
  ///
  /// In ru, this message translates to:
  /// **'Изменить угодья'**
  String get ctaChangeLand;

  /// No description provided for @failedOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения'**
  String get failedOffline;

  /// No description provided for @failedGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить расчёт'**
  String get failedGeneric;

  /// No description provided for @failedDataKept.
  ///
  /// In ru, this message translates to:
  /// **'Введённые данные сохранены — возвращаться к началу не нужно.'**
  String get failedDataKept;

  /// No description provided for @ctaRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить расчёт'**
  String get ctaRetry;

  /// No description provided for @ctaBackToData.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться к данным'**
  String get ctaBackToData;

  /// No description provided for @errorNoConnection.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения. Расчёт сохранён и будет отправлен, когда появится связь.'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In ru, this message translates to:
  /// **'Сервис расчёта не ответил вовремя. Попробуйте ещё раз.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить расчёт. Проверьте введённые данные или попробуйте ещё раз.'**
  String get errorServer;

  /// No description provided for @historyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои расчёты'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сохранённых расчётов'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyDescription.
  ///
  /// In ru, this message translates to:
  /// **'Каждый выполненный расчёт сохраняется на телефоне и потом открывается без интернета.'**
  String get historyEmptyDescription;

  /// No description provided for @historyQueuedBanner.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} расчёт ждёт отправки} few{{count} расчёта ждут отправки} other{{count} расчётов ждут отправки}}. Расчёт уйдёт сам, как только появится связь.'**
  String historyQueuedBanner(int count);

  /// No description provided for @historyNewCalculation.
  ///
  /// In ru, this message translates to:
  /// **'Новый расчёт'**
  String get historyNewCalculation;

  /// No description provided for @historyDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить расчёт'**
  String get historyDelete;

  /// No description provided for @historyCosts.
  ///
  /// In ru, this message translates to:
  /// **'Затраты'**
  String get historyCosts;

  /// No description provided for @historyHeads.
  ///
  /// In ru, this message translates to:
  /// **'Поголовье'**
  String get historyHeads;

  /// No description provided for @historyHeadsValue.
  ///
  /// In ru, this message translates to:
  /// **'{count} голов'**
  String historyHeadsValue(int count);

  /// No description provided for @historyNoResult.
  ///
  /// In ru, this message translates to:
  /// **'Результата пока нет'**
  String get historyNoResult;

  /// No description provided for @historyInfeasible.
  ///
  /// In ru, this message translates to:
  /// **'План на этой земле не выполнить'**
  String get historyInfeasible;

  /// No description provided for @statusDone.
  ///
  /// In ru, this message translates to:
  /// **'готов'**
  String get statusDone;

  /// No description provided for @statusQueued.
  ///
  /// In ru, this message translates to:
  /// **'в очереди'**
  String get statusQueued;

  /// No description provided for @statusInfeasible.
  ///
  /// In ru, this message translates to:
  /// **'невыполним'**
  String get statusInfeasible;

  /// No description provided for @statusFailed.
  ///
  /// In ru, this message translates to:
  /// **'ошибка'**
  String get statusFailed;

  /// No description provided for @demoNormativesWarning.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт выполняется на демонстрационных нормативах ({version}). Реальная нормативная база института ещё не подключена.'**
  String demoNormativesWarning(String version);

  /// No description provided for @normativesLine.
  ///
  /// In ru, this message translates to:
  /// **'Нормативы {version}'**
  String normativesLine(String version);

  /// No description provided for @solverLine.
  ///
  /// In ru, this message translates to:
  /// **'решатель {version}'**
  String solverLine(String version);

  /// No description provided for @unitHa.
  ///
  /// In ru, this message translates to:
  /// **'га'**
  String get unitHa;

  /// No description provided for @unitTons.
  ///
  /// In ru, this message translates to:
  /// **'т'**
  String get unitTons;

  /// No description provided for @unitTonsPerYear.
  ///
  /// In ru, this message translates to:
  /// **'т/год'**
  String get unitTonsPerYear;

  /// No description provided for @unitSom.
  ///
  /// In ru, this message translates to:
  /// **'сом'**
  String get unitSom;

  /// No description provided for @wizardTitleShort.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт'**
  String get wizardTitleShort;

  /// No description provided for @noResult.
  ///
  /// In ru, this message translates to:
  /// **'Нет результата'**
  String get noResult;

  /// No description provided for @notSavedYet.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт ещё не сохранён'**
  String get notSavedYet;

  /// No description provided for @unitPerHectare.
  ///
  /// In ru, this message translates to:
  /// **'га'**
  String get unitPerHectare;

  /// No description provided for @stepLandTotalNote.
  ///
  /// In ru, this message translates to:
  /// **'Если часть земли арендована, укажите её вместе с собственной.'**
  String get stepLandTotalNote;

  /// No description provided for @stepBreedsFix.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте подходящую породу или уберите этот вид из плана.'**
  String get stepBreedsFix;

  /// No description provided for @stepReviewAllCorrect.
  ///
  /// In ru, this message translates to:
  /// **'Всё верно?'**
  String get stepReviewAllCorrect;

  /// No description provided for @solvingDescriptionFull.
  ///
  /// In ru, this message translates to:
  /// **'Приложение перебирает сочетания культур и поголовья, чтобы суммарные затраты оказались наименьшими. Расчёт идёт на вашем телефоне.'**
  String get solvingDescriptionFull;

  /// No description provided for @resultCostStructure.
  ///
  /// In ru, this message translates to:
  /// **'СТРУКТУРА ЗАТРАТ'**
  String get resultCostStructure;

  /// No description provided for @resultCrops.
  ///
  /// In ru, this message translates to:
  /// **'Растениеводство'**
  String get resultCrops;

  /// No description provided for @resultLivestock.
  ///
  /// In ru, this message translates to:
  /// **'Содержание животных'**
  String get resultLivestock;

  /// No description provided for @resultOtherCrops.
  ///
  /// In ru, this message translates to:
  /// **'Прочие культуры'**
  String get resultOtherCrops;

  /// No description provided for @infeasibleFullDescription.
  ///
  /// In ru, this message translates to:
  /// **'Годовой рацион поголовья, нужного для такого плана, не помещается на ваших угодьях.'**
  String get infeasibleFullDescription;

  /// No description provided for @errorUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестная ошибка.'**
  String get errorUnknown;

  /// No description provided for @historyEmptyFull.
  ///
  /// In ru, this message translates to:
  /// **'Каждый выполненный расчёт сохраняется на телефоне. Приложение работает полностью без интернета.'**
  String get historyEmptyFull;

  /// No description provided for @compareAction.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить'**
  String get compareAction;

  /// No description provided for @compareCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get compareCancel;

  /// No description provided for @compareSelected.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить выбранные'**
  String get compareSelected;

  /// No description provided for @compareTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение'**
  String get compareTitle;

  /// No description provided for @compareBefore.
  ///
  /// In ru, this message translates to:
  /// **'РАНЬШЕ'**
  String get compareBefore;

  /// No description provided for @compareAfter.
  ///
  /// In ru, this message translates to:
  /// **'ПОЗЖЕ'**
  String get compareAfter;

  /// No description provided for @comparePerYear.
  ///
  /// In ru, this message translates to:
  /// **'сом в год'**
  String get comparePerYear;

  /// No description provided for @compareCropChanges.
  ///
  /// In ru, this message translates to:
  /// **'ЧТО МЕНЯЕТСЯ В ПОСЕВАХ'**
  String get compareCropChanges;

  /// No description provided for @compareHerdChanges.
  ///
  /// In ru, this message translates to:
  /// **'ЧТО МЕНЯЕТСЯ В ПОГОЛОВЬЕ'**
  String get compareHerdChanges;

  /// No description provided for @diffNew.
  ///
  /// In ru, this message translates to:
  /// **'новое'**
  String get diffNew;

  /// No description provided for @diffRemoved.
  ///
  /// In ru, this message translates to:
  /// **'убрано'**
  String get diffRemoved;

  /// No description provided for @diffUnchanged.
  ///
  /// In ru, this message translates to:
  /// **'без изменений'**
  String get diffUnchanged;

  /// No description provided for @diffMore.
  ///
  /// In ru, this message translates to:
  /// **'больше'**
  String get diffMore;

  /// No description provided for @diffLess.
  ///
  /// In ru, this message translates to:
  /// **'меньше'**
  String get diffLess;

  /// No description provided for @unitHeads.
  ///
  /// In ru, this message translates to:
  /// **'гол.'**
  String get unitHeads;

  /// No description provided for @modelTitle.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get modelTitle;

  /// No description provided for @farmPeasant.
  ///
  /// In ru, this message translates to:
  /// **'Крестьянское (фермерское)'**
  String get farmPeasant;

  /// No description provided for @farmPeasantHint.
  ///
  /// In ru, this message translates to:
  /// **'семейное хозяйство, как правило до 50 га'**
  String get farmPeasantHint;

  /// No description provided for @farmCooperative.
  ///
  /// In ru, this message translates to:
  /// **'Кооператив'**
  String get farmCooperative;

  /// No description provided for @farmCooperativeHint.
  ///
  /// In ru, this message translates to:
  /// **'объединение нескольких хозяйств'**
  String get farmCooperativeHint;

  /// No description provided for @farmEnterprise.
  ///
  /// In ru, this message translates to:
  /// **'Агропредприятие'**
  String get farmEnterprise;

  /// No description provided for @farmEnterpriseHint.
  ///
  /// In ru, this message translates to:
  /// **'сельхозорганизация с наёмными работниками'**
  String get farmEnterpriseHint;

  /// No description provided for @farmHousehold.
  ///
  /// In ru, this message translates to:
  /// **'Личное подсобное'**
  String get farmHousehold;

  /// No description provided for @farmHouseholdHint.
  ///
  /// In ru, this message translates to:
  /// **'небольшое хозяйство для собственных нужд'**
  String get farmHouseholdHint;

  /// No description provided for @explainLandUsed.
  ///
  /// In ru, this message translates to:
  /// **'Занято {percent} % угодий. Незанятая земля означает, что на ней корма обходятся дороже.'**
  String explainLandUsed(int percent);

  /// No description provided for @explainFeedText.
  ///
  /// In ru, this message translates to:
  /// **'Выращено и куплено не меньше, чем требуется на годовой рацион выбранного поголовья. Излишек не планируется: каждая лишняя единица площади увеличивала бы затраты.'**
  String get explainFeedText;

  /// No description provided for @explainCostText.
  ///
  /// In ru, this message translates to:
  /// **'Минимизируется сумма затрат на посевы, на содержание животных и на закупку кормов — это и есть целевая функция модели.'**
  String get explainCostText;

  /// No description provided for @explainPlanText.
  ///
  /// In ru, this message translates to:
  /// **'{produced} т при плане {planned} т.'**
  String explainPlanText(String produced, String planned);

  /// No description provided for @historyStatsHeads.
  ///
  /// In ru, this message translates to:
  /// **'{count} голов'**
  String historyStatsHeads(int count);

  /// No description provided for @compareStats.
  ///
  /// In ru, this message translates to:
  /// **'{heads} голов · {area} га посевов'**
  String compareStats(int heads, String area);

  /// No description provided for @compareCheaperBy.
  ///
  /// In ru, this message translates to:
  /// **'Второй вариант дешевле на {percent} %.'**
  String compareCheaperBy(int percent);

  /// No description provided for @compareDearerBy.
  ///
  /// In ru, this message translates to:
  /// **'Второй вариант дороже на {percent} %.'**
  String compareDearerBy(int percent);

  /// No description provided for @comparePerYearAmount.
  ///
  /// In ru, this message translates to:
  /// **'{amount} сом в год'**
  String comparePerYearAmount(String amount);

  /// No description provided for @compareWas.
  ///
  /// In ru, this message translates to:
  /// **'было {value}'**
  String compareWas(String value);

  /// No description provided for @compareSelectedCount.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count} из 2'**
  String compareSelectedCount(int count);

  /// No description provided for @failedServiceUnreachable.
  ///
  /// In ru, this message translates to:
  /// **'Сервис расчёта недоступен'**
  String get failedServiceUnreachable;

  /// No description provided for @errorServiceUnreachable.
  ///
  /// In ru, this message translates to:
  /// **'Интернет есть, но сервис расчёта не отвечает. Расчёт сохранён — попробуйте позже или сообщите разработчику.'**
  String get errorServiceUnreachable;

  /// No description provided for @contactsNormativesBase.
  ///
  /// In ru, this message translates to:
  /// **'Нормативная база: {version}'**
  String contactsNormativesBase(String version);

  /// No description provided for @homeTitleShort.
  ///
  /// In ru, this message translates to:
  /// **'ММЭ ИМ НАН КР'**
  String get homeTitleShort;

  /// No description provided for @modelFormulaObjective.
  ///
  /// In ru, this message translates to:
  /// **'Целевая функция — минимум суммарных затрат'**
  String get modelFormulaObjective;

  /// No description provided for @modelFormulaLandLimit.
  ///
  /// In ru, this message translates to:
  /// **'Ограничение по размеру посевных площадей'**
  String get modelFormulaLandLimit;

  /// No description provided for @modelFormulaFeedBalance.
  ///
  /// In ru, this message translates to:
  /// **'Кормовой баланс: выращено не меньше, чем требуется'**
  String get modelFormulaFeedBalance;

  /// No description provided for @modelFormulaPlan.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение плана производства продукции'**
  String get modelFormulaPlan;

  /// No description provided for @modelFormulaNonNegative.
  ///
  /// In ru, this message translates to:
  /// **'Неотрицательность посевных площадей'**
  String get modelFormulaNonNegative;

  /// No description provided for @modelFormulaInteger.
  ///
  /// In ru, this message translates to:
  /// **'Поголовье — целое неотрицательное число'**
  String get modelFormulaInteger;

  /// No description provided for @modelGlossaryArea.
  ///
  /// In ru, this message translates to:
  /// **'размер посевной площади k-й категории в хозяйстве'**
  String get modelGlossaryArea;

  /// No description provided for @modelGlossaryYield.
  ///
  /// In ru, this message translates to:
  /// **'урожайность j-го вида культуры на k-й категории площади'**
  String get modelGlossaryYield;

  /// No description provided for @modelGlossaryCropCost.
  ///
  /// In ru, this message translates to:
  /// **'затраты на единицу k-й площади под j-й вид культуры'**
  String get modelGlossaryCropCost;

  /// No description provided for @modelGlossaryFeedNeed.
  ///
  /// In ru, this message translates to:
  /// **'годовая потребность в j-м виде продукции растениеводства на одно животное l-й породы при производстве h-го вида продукции'**
  String get modelGlossaryFeedNeed;

  /// No description provided for @modelGlossaryYieldPerHead.
  ///
  /// In ru, this message translates to:
  /// **'объём продукции h-го вида от одного животного l-й породы'**
  String get modelGlossaryYieldPerHead;

  /// No description provided for @modelGlossaryPlan.
  ///
  /// In ru, this message translates to:
  /// **'запланированный объём продукции h-го вида'**
  String get modelGlossaryPlan;

  /// No description provided for @modelGlossaryHeadCost.
  ///
  /// In ru, this message translates to:
  /// **'годовой расход на одно животное l-й породы'**
  String get modelGlossaryHeadCost;

  /// No description provided for @modelGlossaryUnknownArea.
  ///
  /// In ru, this message translates to:
  /// **'искомое: размер площади k под j-й вид культуры'**
  String get modelGlossaryUnknownArea;

  /// No description provided for @modelGlossaryUnknownHeads.
  ///
  /// In ru, this message translates to:
  /// **'искомое: количество животных l-й породы для продукции h'**
  String get modelGlossaryUnknownHeads;

  /// No description provided for @explainFormulaLand.
  ///
  /// In ru, this message translates to:
  /// **'(1.2)  сумма x[k][j] по культурам ≤ s[k]'**
  String get explainFormulaLand;

  /// No description provided for @explainFormulaPlan.
  ///
  /// In ru, this message translates to:
  /// **'(1.4)  сумма v[h][l]·y[h][l] ≥ b[h]'**
  String get explainFormulaPlan;

  /// No description provided for @explainFormulaFeed.
  ///
  /// In ru, this message translates to:
  /// **'(1.3)  сумма a[k][j]·x[k][j] ≥ сумма q[j][h][l]·y[h][l]'**
  String get explainFormulaFeed;

  /// No description provided for @explainFormulaCost.
  ///
  /// In ru, this message translates to:
  /// **'(1.1)  минимум суммы c[k][j]·x[k][j] + d[h][l]·y[h][l] + p[j]·z[j]'**
  String get explainFormulaCost;

  /// No description provided for @plausibilityTooMuch.
  ///
  /// In ru, this message translates to:
  /// **'Для {area} га это очень много. Обычно с такой площади получают не больше {max} т. Возможно, указаны литры вместо тонн?'**
  String plausibilityTooMuch(String area, String max);

  /// No description provided for @compareIncomparable.
  ///
  /// In ru, this message translates to:
  /// **'Расчёты выполнены на разных нормативах ({before} и {after}). Разница в затратах отражает смену базы, а не решение хозяйства.'**
  String compareIncomparable(String before, String after);

  /// No description provided for @pdfTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт оптимального плана хозяйства'**
  String get pdfTitle;

  /// No description provided for @pdfDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата расчёта: {date}'**
  String pdfDate(String date);

  /// No description provided for @pdfPage.
  ///
  /// In ru, this message translates to:
  /// **'стр. {page} из {total}'**
  String pdfPage(int page, int total);

  /// No description provided for @pdfNoResult.
  ///
  /// In ru, this message translates to:
  /// **'Результат расчёта отсутствует.'**
  String get pdfNoResult;

  /// No description provided for @pdfInputSection.
  ///
  /// In ru, this message translates to:
  /// **'Исходные данные'**
  String get pdfInputSection;

  /// No description provided for @pdfFarmType.
  ///
  /// In ru, this message translates to:
  /// **'Тип хозяйства'**
  String get pdfFarmType;

  /// No description provided for @pdfAvailableBreeds.
  ///
  /// In ru, this message translates to:
  /// **'Доступные породы'**
  String get pdfAvailableBreeds;

  /// No description provided for @pdfTotalCost.
  ///
  /// In ru, this message translates to:
  /// **'СУММАРНЫЕ ЗАТРАТЫ ЗА ГОД'**
  String get pdfTotalCost;

  /// No description provided for @pdfWhatToSow.
  ///
  /// In ru, this message translates to:
  /// **'Что посеять — {used} из {total} га'**
  String pdfWhatToSow(String used, String total);

  /// No description provided for @pdfColCrop.
  ///
  /// In ru, this message translates to:
  /// **'Культура'**
  String get pdfColCrop;

  /// No description provided for @pdfColLand.
  ///
  /// In ru, this message translates to:
  /// **'Угодья'**
  String get pdfColLand;

  /// No description provided for @pdfColArea.
  ///
  /// In ru, this message translates to:
  /// **'Площадь, га'**
  String get pdfColArea;

  /// No description provided for @pdfUnusedLand.
  ///
  /// In ru, this message translates to:
  /// **'Не занято {area} га: на этих угодьях корма обходятся дороже.'**
  String pdfUnusedLand(String area);

  /// No description provided for @pdfHowManyHeads.
  ///
  /// In ru, this message translates to:
  /// **'Сколько голов содержать — всего {heads}'**
  String pdfHowManyHeads(int heads);

  /// No description provided for @pdfColBreed.
  ///
  /// In ru, this message translates to:
  /// **'Порода'**
  String get pdfColBreed;

  /// No description provided for @pdfColDirection.
  ///
  /// In ru, this message translates to:
  /// **'Направление'**
  String get pdfColDirection;

  /// No description provided for @pdfColHeads.
  ///
  /// In ru, this message translates to:
  /// **'Голов'**
  String get pdfColHeads;

  /// No description provided for @pdfCostStructure.
  ///
  /// In ru, this message translates to:
  /// **'Структура затрат'**
  String get pdfCostStructure;

  /// No description provided for @pdfColItem.
  ///
  /// In ru, this message translates to:
  /// **'Статья'**
  String get pdfColItem;

  /// No description provided for @pdfColShare.
  ///
  /// In ru, this message translates to:
  /// **'Доля'**
  String get pdfColShare;

  /// No description provided for @pdfColSum.
  ///
  /// In ru, this message translates to:
  /// **'Сумма, сом'**
  String get pdfColSum;

  /// No description provided for @pdfMissingLand.
  ///
  /// In ru, this message translates to:
  /// **'Не хватает примерно {area} га пашни при нынешней урожайности.'**
  String pdfMissingLand(String area);

  /// No description provided for @pdfDemoWarning.
  ///
  /// In ru, this message translates to:
  /// **'ВНИМАНИЕ: расчёт выполнен на демонстрационных нормативах. Реальная нормативная база института не подключена.'**
  String get pdfDemoWarning;

  /// No description provided for @adminTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нормативная база'**
  String get adminTitle;

  /// No description provided for @adminSavedNotice.
  ///
  /// In ru, this message translates to:
  /// **'База сохранена. Перезапустите приложение, чтобы расчёты пошли по новым нормативам.'**
  String get adminSavedNotice;

  /// No description provided for @adminResetNotice.
  ///
  /// In ru, this message translates to:
  /// **'Возврат к встроенной базе. Перезапустите приложение.'**
  String get adminResetNotice;

  /// No description provided for @adminApply.
  ///
  /// In ru, this message translates to:
  /// **'Применить эту базу'**
  String get adminApply;

  /// No description provided for @adminCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get adminCancel;

  /// No description provided for @adminReadingFile.
  ///
  /// In ru, this message translates to:
  /// **'Читаем файл…'**
  String get adminReadingFile;

  /// No description provided for @adminPickFile.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить файл Excel'**
  String get adminPickFile;

  /// No description provided for @adminResetToBundled.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться к встроенной базе'**
  String get adminResetToBundled;

  /// No description provided for @adminCurrentBase.
  ///
  /// In ru, this message translates to:
  /// **'ДЕЙСТВУЮЩАЯ БАЗА'**
  String get adminCurrentBase;

  /// No description provided for @adminVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get adminVersion;

  /// No description provided for @adminSource.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get adminSource;

  /// No description provided for @adminSourceBundled.
  ///
  /// In ru, this message translates to:
  /// **'встроена в приложение'**
  String get adminSourceBundled;

  /// No description provided for @adminSourceImported.
  ///
  /// In ru, this message translates to:
  /// **'загружена вручную'**
  String get adminSourceImported;

  /// No description provided for @adminLandsCount.
  ///
  /// In ru, this message translates to:
  /// **'Угодий'**
  String get adminLandsCount;

  /// No description provided for @adminCropsCount.
  ///
  /// In ru, this message translates to:
  /// **'Культур'**
  String get adminCropsCount;

  /// No description provided for @adminBreedsCount.
  ///
  /// In ru, this message translates to:
  /// **'Пород и направлений'**
  String get adminBreedsCount;

  /// No description provided for @adminDemoWarning.
  ///
  /// In ru, this message translates to:
  /// **'База помечена как демонстрационная — расчёты нельзя предъявлять хозяйствам.'**
  String get adminDemoWarning;

  /// No description provided for @adminPreviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'ФАЙЛ ПРОЧИТАН — ПРОВЕРЬТЕ'**
  String get adminPreviewTitle;

  /// No description provided for @adminPreviewCrops.
  ///
  /// In ru, this message translates to:
  /// **'Культуры: {list}'**
  String adminPreviewCrops(String list);

  /// No description provided for @adminPreviewBreeds.
  ///
  /// In ru, this message translates to:
  /// **'Породы: {list}'**
  String adminPreviewBreeds(String list);

  /// No description provided for @adminIssuesTitle.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Файл не загружен — {count} замечание:} few{Файл не загружен — {count} замечания:} other{Файл не загружен — {count} замечаний:}}'**
  String adminIssuesTitle(int count);

  /// No description provided for @adminIssuesMore.
  ///
  /// In ru, this message translates to:
  /// **'…и ещё {count}'**
  String adminIssuesMore(int count);

  /// No description provided for @adminFormatTitle.
  ///
  /// In ru, this message translates to:
  /// **'ФОРМАТ ФАЙЛА'**
  String get adminFormatTitle;

  /// No description provided for @adminFormatIntro.
  ///
  /// In ru, this message translates to:
  /// **'Файл .xlsx с листами (первая строка — заголовки):'**
  String get adminFormatIntro;

  /// No description provided for @adminFormatLands.
  ///
  /// In ru, this message translates to:
  /// **'id · Название'**
  String get adminFormatLands;

  /// No description provided for @adminFormatCrops.
  ///
  /// In ru, this message translates to:
  /// **'id · Название · Угодье · Урожайность · Затраты · Цена закупки'**
  String get adminFormatCrops;

  /// No description provided for @adminFormatProducts.
  ///
  /// In ru, this message translates to:
  /// **'id · Название · Единица'**
  String get adminFormatProducts;

  /// No description provided for @adminFormatBreeds.
  ///
  /// In ru, this message translates to:
  /// **'Порода id · Порода · Продукция id · Выход · Затраты · далее по столбцу на каждую культуру — потребность в кормах'**
  String get adminFormatBreeds;

  /// No description provided for @adminFormatMeta.
  ///
  /// In ru, this message translates to:
  /// **'version · значение'**
  String get adminFormatMeta;

  /// No description provided for @adminFormatKyColumns.
  ///
  /// In ru, this message translates to:
  /// **'Кыргызские названия — необязательные столбцы «Название (кырг.)», «Единица (кырг.)» и «Порода (кырг.)». Их можно дописать в конец листа: столбцы ищутся по заголовку, а не по номеру. Без них кыргызский интерфейс покажет русские названия справочника.'**
  String get adminFormatKyColumns;

  /// No description provided for @adminFormatNote.
  ///
  /// In ru, this message translates to:
  /// **'Одна культура занимает столько строк, на скольких угодьях растёт. Сохраняйте именно .xlsx: CSV из Windows-версии Excel портит кириллицу.'**
  String get adminFormatNote;

  /// No description provided for @importIssueAtRow.
  ///
  /// In ru, this message translates to:
  /// **'«{sheet}», строка {row}: {message}'**
  String importIssueAtRow(String sheet, int row, String message);

  /// No description provided for @importIssueAtSheet.
  ///
  /// In ru, this message translates to:
  /// **'«{sheet}»: {message}'**
  String importIssueAtSheet(String sheet, String message);

  /// No description provided for @importFileLabel.
  ///
  /// In ru, this message translates to:
  /// **'файл'**
  String get importFileLabel;

  /// No description provided for @importFileUnreadable.
  ///
  /// In ru, this message translates to:
  /// **'не удалось прочитать: {error}'**
  String importFileUnreadable(String error);

  /// No description provided for @importSheetMissing.
  ///
  /// In ru, this message translates to:
  /// **'лист отсутствует в файле'**
  String get importSheetMissing;

  /// No description provided for @importSheetEmpty.
  ///
  /// In ru, this message translates to:
  /// **'лист пуст'**
  String get importSheetEmpty;

  /// No description provided for @importNoRows.
  ///
  /// In ru, this message translates to:
  /// **'нет ни одной строки'**
  String get importNoRows;

  /// No description provided for @importIdAndNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'нужны и id, и название'**
  String get importIdAndNameRequired;

  /// No description provided for @importUnknownLand.
  ///
  /// In ru, this message translates to:
  /// **'неизвестное угодье «{id}»'**
  String importUnknownLand(String id);

  /// No description provided for @importNumbersRequired.
  ///
  /// In ru, this message translates to:
  /// **'урожайность и затраты должны быть числами'**
  String get importNumbersRequired;

  /// No description provided for @importNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'не указано название'**
  String get importNameRequired;

  /// No description provided for @importUnknownCropInHeader.
  ///
  /// In ru, this message translates to:
  /// **'неизвестная культура в заголовке: «{id}»'**
  String importUnknownCropInHeader(String id);

  /// No description provided for @importFeedColumnsMissing.
  ///
  /// In ru, this message translates to:
  /// **'начиная с шестого столбца должны идти id культур — потребность в кормах'**
  String get importFeedColumnsMissing;

  /// No description provided for @importUnknownProduct.
  ///
  /// In ru, this message translates to:
  /// **'неизвестная продукция «{id}»'**
  String importUnknownProduct(String id);

  /// No description provided for @importYieldMustBePositive.
  ///
  /// In ru, this message translates to:
  /// **'выход продукции должен быть больше нуля'**
  String get importYieldMustBePositive;

  /// No description provided for @importCostMustBeNumber.
  ///
  /// In ru, this message translates to:
  /// **'затраты на голову должны быть числом'**
  String get importCostMustBeNumber;

  /// No description provided for @importFeedNeedEmpty.
  ///
  /// In ru, this message translates to:
  /// **'не заполнена потребность ни в одном корме'**
  String get importFeedNeedEmpty;

  /// No description provided for @stepBreedsLimitLabel.
  ///
  /// In ru, this message translates to:
  /// **'Не больше'**
  String get stepBreedsLimitLabel;

  /// No description provided for @stepBreedsLimitHint.
  ///
  /// In ru, this message translates to:
  /// **'Оставьте пустым, если поголовье не ограничено'**
  String get stepBreedsLimitHint;

  /// No description provided for @resultFeedPurchase.
  ///
  /// In ru, this message translates to:
  /// **'ЧТО ПРИДЁТСЯ ДОКУПИТЬ'**
  String get resultFeedPurchase;

  /// No description provided for @resultFeedPurchaseHint.
  ///
  /// In ru, this message translates to:
  /// **'Этих кормов своя земля не даёт — модель посчитала их по рыночной цене.'**
  String get resultFeedPurchaseHint;

  /// No description provided for @resultPurchasedFeed.
  ///
  /// In ru, this message translates to:
  /// **'Покупные корма'**
  String get resultPurchasedFeed;

  /// No description provided for @resultSelfSufficient.
  ///
  /// In ru, this message translates to:
  /// **'Хозяйство полностью обеспечивает себя кормами.'**
  String get resultSelfSufficient;

  /// No description provided for @modelFormulaBreedLimit.
  ///
  /// In ru, this message translates to:
  /// **'Предел поголовья по породе, если хозяйство его задало'**
  String get modelFormulaBreedLimit;

  /// No description provided for @modelFormulaPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Закупка кормов неотрицательна'**
  String get modelFormulaPurchase;

  /// No description provided for @modelGlossaryFeedPrice.
  ///
  /// In ru, this message translates to:
  /// **'цена тонны j-го корма на рынке'**
  String get modelGlossaryFeedPrice;

  /// No description provided for @modelGlossaryBreedLimit.
  ///
  /// In ru, this message translates to:
  /// **'предельное поголовье l-й породы в хозяйстве'**
  String get modelGlossaryBreedLimit;

  /// No description provided for @modelGlossaryUnknownPurchase.
  ///
  /// In ru, this message translates to:
  /// **'искомое: сколько тонн j-го корма придётся докупить'**
  String get modelGlossaryUnknownPurchase;

  /// No description provided for @explainFeedPurchaseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Закупка кормов'**
  String get explainFeedPurchaseTitle;

  /// No description provided for @explainFeedPurchaseNone.
  ///
  /// In ru, this message translates to:
  /// **'не потребовалась'**
  String get explainFeedPurchaseNone;

  /// No description provided for @explainFeedPurchaseSome.
  ///
  /// In ru, this message translates to:
  /// **'{tons} т на {cost} сом'**
  String explainFeedPurchaseSome(String tons, String cost);

  /// No description provided for @explainFeedPurchaseTextNone.
  ///
  /// In ru, this message translates to:
  /// **'Весь рацион закрыт своими посевами и пастбищами. Покупать корма не нужно.'**
  String get explainFeedPurchaseTextNone;

  /// No description provided for @explainFeedPurchaseTextSome.
  ///
  /// In ru, this message translates to:
  /// **'Своей земли на весь рацион не хватает. Модель сравнила стоимость гектара и цену корма на рынке и выбрала то, что дешевле.'**
  String get explainFeedPurchaseTextSome;

  /// No description provided for @explainFormulaPurchase.
  ///
  /// In ru, this message translates to:
  /// **'(1.3)  сумма a[k][j]·x[k][j] + z[j] ≥ сумма q[j][h][l]·y[h][l]'**
  String get explainFormulaPurchase;

  /// No description provided for @stepLandPastureNote.
  ///
  /// In ru, this message translates to:
  /// **'Пастбища учитываются наравне с пашней: подножный корм — самая дешёвая часть рациона.'**
  String get stepLandPastureNote;

  /// No description provided for @pdfFeedPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Что придётся докупить'**
  String get pdfFeedPurchase;

  /// No description provided for @pdfColFeed.
  ///
  /// In ru, this message translates to:
  /// **'Корм'**
  String get pdfColFeed;

  /// No description provided for @pdfColTons.
  ///
  /// In ru, this message translates to:
  /// **'Тонн'**
  String get pdfColTons;

  /// No description provided for @pdfSelfSufficient.
  ///
  /// In ru, this message translates to:
  /// **'Закупка кормов не требуется: хозяйство обеспечивает себя полностью.'**
  String get pdfSelfSufficient;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ky', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ky':
      return LKy();
    case 'ru':
      return LRu();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
