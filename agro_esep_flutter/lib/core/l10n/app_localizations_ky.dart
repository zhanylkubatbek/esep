// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kirghiz Kyrgyz (`ky`).
class LKy extends L {
  LKy([String locale = 'ky']) : super(locale);

  @override
  String get appTitle => 'AgroESEP';

  @override
  String get navHome => 'Башкы';

  @override
  String get navModel => 'Модель';

  @override
  String get navAbout => 'Долбоор';

  @override
  String get navCalculator => 'Эсептөө';

  @override
  String get navHistory => 'Тарых';

  @override
  String get instituteName => 'КР УИА Математика институту';

  @override
  String get contactsTitle => 'Байланыштар';

  @override
  String get contactsLink => 'Институттун байланыштары';

  @override
  String get contactsAddress => 'Дарек';

  @override
  String get contactsPhone => 'Телефон';

  @override
  String get contactsEmail => 'Электрондук почта';

  @override
  String get contactsHead => 'Долбоордун жетекчиси';

  @override
  String get onlineCalculation => 'Онлайн эсептөө';

  @override
  String get ctaCalculate => 'Оптималдуу чечимди эсептөө';

  @override
  String get ctaAbout => 'Долбоор жөнүндө';

  @override
  String get ctaStart => 'Эсептөөнү баштоо';

  @override
  String get ctaNext => 'Кийинки';

  @override
  String get howItWorksTitle => 'Калькулятор кантип иштейт?';

  @override
  String get howItWorksSubtitle => 'Төрт кадам, болжол менен беш мүнөт.';

  @override
  String get modelFormulas => 'Формулалар';

  @override
  String get modelGlossary => 'Белгилөөлөр';

  @override
  String get aboutTab => 'Долбоор жөнүндө';

  @override
  String get goalsTab => 'Максаты жана милдеттери';

  @override
  String get resultsTab => 'Натыйжалар';

  @override
  String get relevanceTitle => 'Актуалдуулугу';

  @override
  String get goalTitle => 'Долбоордун максаты';

  @override
  String get tasksTitle => 'Негизги милдеттер';

  @override
  String get tasksBadge => 'милдеттер';

  @override
  String get expectedResultsTitle => 'Күтүлүүчү натыйжалар';

  @override
  String get resultsBadge => 'натыйжалар';

  @override
  String get practicalValueTitle => 'Практикалык мааниси';

  @override
  String get valueBadge => 'мааниси';

  @override
  String get wizardTitle => 'Чарбаны эсептөө';

  @override
  String wizardStep(int current, int total) {
    return '$total КАДАМДАН $current-КАДАМ';
  }

  @override
  String get stepFarmTypeQuestion => 'Чарбаңыз кайсы түргө кирет?';

  @override
  String get stepFarmTypeHint =>
      'Эсептөөдө колдонулуучу нормативдер ушуга жараша болот.';

  @override
  String get stepLandQuestion => 'Жериңиз канча?';

  @override
  String get stepLandHint => 'Жердин ар бир түрү боюнча аянт, гектар менен.';

  @override
  String get stepLandEmptyHint =>
      'Болгонун гана толтуруңуз. Бош талаа ката эмес: көпчүлүк чарбаларда жердин бардык түрү боло бербейт.';

  @override
  String stepLandTotal(String area) {
    return 'Баары $area га. Жердин бир бөлүгү ижарага алынган болсо, аны өзүңүздүкү менен кошо көрсөтүңүз.';
  }

  @override
  String get stepPlanQuestion => 'Канча продукция алууну пландап жатасыз?';

  @override
  String get stepPlanHint =>
      'Бир жылга. Өндүрөйүн деген продукцияңызды гана толтуруңуз.';

  @override
  String get stepPlanWarningFootnote =>
      'Эскертүү эсептөөгө тоскоол болбойт: маани туура болсо, улантыңыз.';

  @override
  String get stepBreedsQuestion =>
      'Кайсы тукумдарды багууга мүмкүнчүлүгүңүз бар?';

  @override
  String get stepBreedsHint =>
      'Мүмкүн болгондорун белгилеңиз. Аталыштын астында — институттун ченемдери. Канча баш бага аларыңызды көрсөтсөңүз болот.';

  @override
  String stepBreedsUncovered(String products) {
    return 'Тандалган тукумдардын бири да $products бербейт. Ылайыктуу тукум кошуңуз же бул түрдү пландан алып салыңыз.';
  }

  @override
  String get stepReviewTitle => 'Маалыматтарды текшериңиз';

  @override
  String get stepReviewQuestion => 'Баары туурабы?';

  @override
  String get stepReviewHint =>
      'Ар бир блокту ушул жерден эле оңдосо болот, башына кайра өтүүнүн кереги жок.';

  @override
  String get stepReviewEdit => 'ӨЗГӨРТҮҮ';

  @override
  String get blockFarm => 'ЧАРБА';

  @override
  String get blockFarmType => 'Түрү';

  @override
  String get blockLand => 'ЖЕРЛЕР';

  @override
  String get blockPlan => 'ӨНДҮРҮШ ПЛАНЫ';

  @override
  String get blockBreeds => 'ТУКУМДАР';

  @override
  String get yes => 'ооба';

  @override
  String get ctaSolve => 'Оптималдуу вариантты эсептөө';

  @override
  String get ctaSolveSubtitle =>
      'эсептөө бир нече секунд алат, интернеттин кереги жок';

  @override
  String get solvingTitle => 'Оптималдуу вариантты тандап жатабыз';

  @override
  String get solvingDescription =>
      'Жалпы чыгымдар эң аз болушу үчүн эгин түрлөрү менен мал башынын айкалыштары каралып чыгат.';

  @override
  String get solvingStageChecked => 'Маалыматтар текшерилди';

  @override
  String get solvingStageNormatives => 'Нормативдер коюлду';

  @override
  String get solvingStageOptimizing => 'Оптималдаштыруу маселеси чечилүүдө';

  @override
  String get resultTitle => 'Сунуш';

  @override
  String get resultCostLabel => 'БИР ЖЫЛДЫК ЧЫГЫМ';

  @override
  String get resultWhatToSow => 'ЭМНЕ СЕБҮҮ КЕРЕК';

  @override
  String resultLandUsage(String used, String total) {
    return '$used / $total га';
  }

  @override
  String get resultUnused => 'бош калды';

  @override
  String get resultHowManyHeads => 'КАНЧА БАШ МАЛ БАГУУ КЕРЕК';

  @override
  String get ctaExplain => 'Бул кантип эсептелди';

  @override
  String get ctaOpenHistory => 'Сакталды — эсептөөлөрүмдү ачуу';

  @override
  String get ctaSavePdf => 'PDF кылып сактоо';

  @override
  String get explainTitle => 'Бул кантип эсептелди';

  @override
  String get explainLandUse => 'Жерди пайдалануу';

  @override
  String get explainFeedBalance => 'Тоют балансы';

  @override
  String get explainCostStructure => 'Чыгымдардын түзүмү';

  @override
  String explainPlanFor(String product) {
    return 'План: $product';
  }

  @override
  String get explainFulfilled => 'аткарылды';

  @override
  String get explainNotFulfilled => 'аткарылган жок';

  @override
  String get explainObserved => 'сакталды';

  @override
  String get infeasibleTitle => 'Мындай планды бул жерде аткарууга болбойт';

  @override
  String get infeasibleDescription =>
      'Мындай планга керектүү мал башынын жылдык рациону сиздин жерлерге батпайт.';

  @override
  String get infeasibleMissingLand =>
      'азыркы түшүмдүүлүктө айдоо жер ушунчага жетишпейт';

  @override
  String get ctaReducePlan => 'Планды азайтуу';

  @override
  String get ctaChangeLand => 'Жерлерди өзгөртүү';

  @override
  String get failedOffline => 'Байланыш жок';

  @override
  String get failedGeneric => 'Эсептөө аткарылган жок';

  @override
  String get failedDataKept =>
      'Киргизилген маалыматтар сакталды — башынан баштоонун кереги жок.';

  @override
  String get ctaRetry => 'Кайра эсептөө';

  @override
  String get ctaBackToData => 'Маалыматтарга кайтуу';

  @override
  String get errorNoConnection =>
      'Байланыш жок. Эсептөө сакталды жана байланыш чыкканда жөнөтүлөт.';

  @override
  String get errorTimeout =>
      'Эсептөө кызматы өз убагында жооп берген жок. Кайра аракет кылыңыз.';

  @override
  String get errorServer =>
      'Эсептөө аткарылган жок. Киргизилген маалыматтарды текшериңиз же кайра аракет кылыңыз.';

  @override
  String get historyTitle => 'Менин эсептөөлөрүм';

  @override
  String get historyEmptyTitle => 'Азырынча сакталган эсептөөлөр жок';

  @override
  String get historyEmptyDescription =>
      'Ар бир аткарылган эсептөө телефонго сакталат жана кийин интернетсиз эле ачылат.';

  @override
  String historyQueuedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count эсептөө жөнөтүүнү күтүп турат',
      one: '$count эсептөө жөнөтүүнү күтүп турат',
    );
    return '$_temp0. Байланыш чыкканда эсептөө өзү эле жөнөтүлөт.';
  }

  @override
  String get historyNewCalculation => 'Жаңы эсептөө';

  @override
  String get historyDelete => 'Эсептөөнү өчүрүү';

  @override
  String get historyCosts => 'Чыгымдар';

  @override
  String get historyHeads => 'Мал башы';

  @override
  String historyHeadsValue(int count) {
    return '$count баш';
  }

  @override
  String get historyNoResult => 'Азырынча натыйжа жок';

  @override
  String get historyInfeasible => 'Бул жерде планды аткарууга болбойт';

  @override
  String get statusDone => 'даяр';

  @override
  String get statusQueued => 'кезекте';

  @override
  String get statusInfeasible => 'аткарылгыс';

  @override
  String get statusFailed => 'ката';

  @override
  String demoNormativesWarning(String version) {
    return 'Эсептөө демонстрациялык нормативдер ($version) менен аткарылууда. Институттун чыныгы нормативдик базасы азырынча кошула элек.';
  }

  @override
  String normativesLine(String version) {
    return 'Нормативдер $version';
  }

  @override
  String solverLine(String version) {
    return 'эсептегич $version';
  }

  @override
  String get unitHa => 'га';

  @override
  String get unitTons => 'т';

  @override
  String get unitTonsPerYear => 'т/жыл';

  @override
  String get unitSom => 'сом';

  @override
  String get wizardTitleShort => 'Эсептөө';

  @override
  String get noResult => 'Натыйжа жок';

  @override
  String get notSavedYet => 'Эсептөө азырынча сактала элек';

  @override
  String get unitPerHectare => 'га';

  @override
  String get stepLandTotalNote =>
      'Жердин бир бөлүгү ижарага алынган болсо, аны өзүңүздүкү менен кошо көрсөтүңүз.';

  @override
  String get stepBreedsFix =>
      'Ылайыктуу тукум кошуңуз же бул түрдү пландан алып салыңыз.';

  @override
  String get stepReviewAllCorrect => 'Баары туурабы?';

  @override
  String get solvingDescriptionFull =>
      'Колдонмо жалпы чыгымдар эң аз болушу үчүн эгин түрлөрү менен мал башынын айкалыштарын карап чыгат. Эсептөө сиздин телефондо жүрөт.';

  @override
  String get resultCostStructure => 'ЧЫГЫМДАРДЫН ТҮЗҮМҮ';

  @override
  String get resultCrops => 'Өсүмдүк өстүрүү';

  @override
  String get resultLivestock => 'Мал багуу';

  @override
  String get resultOtherCrops => 'Башка эгиндер';

  @override
  String get infeasibleFullDescription =>
      'Мындай планга керектүү мал башынын жылдык рациону сиздин жерлерге батпайт.';

  @override
  String get errorUnknown => 'Белгисиз ката.';

  @override
  String get historyEmptyFull =>
      'Ар бир аткарылган эсептөө телефонго сакталат. Колдонмо толугу менен интернетсиз иштейт.';

  @override
  String get compareAction => 'Салыштыруу';

  @override
  String get compareCancel => 'Жокко чыгаруу';

  @override
  String get compareSelected => 'Тандалгандарды салыштыруу';

  @override
  String get compareTitle => 'Салыштыруу';

  @override
  String get compareBefore => 'МУРУН';

  @override
  String get compareAfter => 'КИЙИН';

  @override
  String get comparePerYear => 'жылына сом';

  @override
  String get compareCropChanges => 'ЭГИНДЕРДЕ ЭМНЕ ӨЗГӨРӨТ';

  @override
  String get compareHerdChanges => 'МАЛ БАШЫНДА ЭМНЕ ӨЗГӨРӨТ';

  @override
  String get diffNew => 'жаңы';

  @override
  String get diffRemoved => 'алынып салынды';

  @override
  String get diffUnchanged => 'өзгөрүүсүз';

  @override
  String get diffMore => 'көбүрөөк';

  @override
  String get diffLess => 'азыраак';

  @override
  String get unitHeads => 'баш';

  @override
  String get modelTitle => 'Модель';

  @override
  String get farmPeasant => 'Дыйкан (фермер) чарбасы';

  @override
  String get farmPeasantHint => 'үй-бүлөлүк чарба, адатта 50 гага чейин';

  @override
  String get farmCooperative => 'Кооператив';

  @override
  String get farmCooperativeHint => 'бир нече чарбанын биримдиги';

  @override
  String get farmEnterprise => 'Агроишкана';

  @override
  String get farmEnterpriseHint => 'жалданма жумушчулары бар айыл чарба уюму';

  @override
  String get farmHousehold => 'Жеке көмөкчү чарба';

  @override
  String get farmHouseholdHint => 'өз муктаждыгы үчүн чакан чарба';

  @override
  String explainLandUsed(int percent) {
    return 'Жерлердин $percent %ы ээленди. Бош калган жер — анда тоют кымбатыраак болот дегенди билдирет.';
  }

  @override
  String get explainFeedText =>
      'Тандалган мал башынын жылдык рационуна канча керек болсо, ошончодон кем эмес өстүрүлдү жана сатып алынды. Ашыкчасы пландалбайт: ар бир ашыкча аянт чыгымды көбөйтмөк.';

  @override
  String get explainCostText =>
      'Айдоолорго, мал багууга жана жем сатып алууга кеткен чыгымдардын суммасы минималдаштырылат — модельдин максат функциясы ушул.';

  @override
  String explainPlanText(String produced, String planned) {
    return 'План $planned т болгондо $produced т.';
  }

  @override
  String historyStatsHeads(int count) {
    return '$count баш';
  }

  @override
  String compareStats(int heads, String area) {
    return '$heads баш · $area га эгин';
  }

  @override
  String compareCheaperBy(int percent) {
    return 'Экинчи вариант $percent %га арзаныраак.';
  }

  @override
  String compareDearerBy(int percent) {
    return 'Экинчи вариант $percent %га кымбатыраак.';
  }

  @override
  String comparePerYearAmount(String amount) {
    return 'жылына $amount сом';
  }

  @override
  String compareWas(String value) {
    return 'мурун $value болчу';
  }

  @override
  String compareSelectedCount(int count) {
    return 'Тандалды: $count / 2';
  }

  @override
  String get failedServiceUnreachable => 'Эсептөө кызматы жеткиликсиз';

  @override
  String get errorServiceUnreachable =>
      'Интернет бар, бирок эсептөө кызматы жооп бербей жатат. Эсептөө сакталды — кийинчерээк аракет кылыңыз же иштеп чыгуучуга кабарлаңыз.';

  @override
  String contactsNormativesBase(String version) {
    return 'Нормативдик база: $version';
  }

  @override
  String get homeTitleShort => 'ЭММ МИ КР УИА';

  @override
  String get modelFormulaObjective =>
      'Максаттуу функция — жалпы чыгымдардын минимуму';

  @override
  String get modelFormulaLandLimit => 'Эгин аянттарынын өлчөмү боюнча чектөө';

  @override
  String get modelFormulaFeedBalance =>
      'Тоют балансы: талап кылынгандан кем эмес өстүрүлөт';

  @override
  String get modelFormulaPlan => 'Продукция өндүрүү планынын аткарылышы';

  @override
  String get modelFormulaNonNegative => 'Эгин аянттарынын терс эместиги';

  @override
  String get modelFormulaInteger => 'Мал башы — бүтүн терс эмес сан';

  @override
  String get modelGlossaryArea =>
      'чарбадагы k-категориядагы эгин аянтынын өлчөмү';

  @override
  String get modelGlossaryYield =>
      'k-категориядагы аянттагы j-түрдөгү эгиндин түшүмдүүлүгү';

  @override
  String get modelGlossaryCropCost =>
      'j-түрдөгү эгин үчүн k-аянттын бирдигине кеткен чыгым';

  @override
  String get modelGlossaryFeedNeed =>
      'h-түрдөгү продукцияны өндүрүүдө l-тукумдагы бир малга j-түрдөгү өсүмдүк продукциясына болгон жылдык муктаждык';

  @override
  String get modelGlossaryYieldPerHead =>
      'l-тукумдагы бир малдан алынуучу h-түрдөгү продукциянын көлөмү';

  @override
  String get modelGlossaryPlan =>
      'h-түрдөгү продукциянын пландаштырылган көлөмү';

  @override
  String get modelGlossaryHeadCost =>
      'l-тукумдагы бир малга кеткен жылдык чыгым';

  @override
  String get modelGlossaryUnknownArea =>
      'изделүүчү: j-түрдөгү эгин үчүн k-аянттын өлчөмү';

  @override
  String get modelGlossaryUnknownHeads =>
      'изделүүчү: h продукциясы үчүн l-тукумдагы малдын саны';

  @override
  String get explainFormulaLand =>
      '(1.2)  эгиндер боюнча x[k][j] суммасы ≤ s[k]';

  @override
  String get explainFormulaPlan => '(1.4)  v[h][l]·y[h][l] суммасы ≥ b[h]';

  @override
  String get explainFormulaFeed =>
      '(1.3)  a[k][j]·x[k][j] суммасы ≥ q[j][h][l]·y[h][l] суммасы';

  @override
  String get explainFormulaCost =>
      '(1.1)  c[k][j]·x[k][j] + d[h][l]·y[h][l] + p[j]·z[j] суммасынын минимуму';

  @override
  String plausibilityTooMuch(String area, String max) {
    return '$area га үчүн бул өтө көп. Адатта мындай аянттан $max тоннадан ашык алынбайт. Тонналардын ордуна литрлер көрсөтүлдүбү?';
  }

  @override
  String compareIncomparable(String before, String after) {
    return 'Эсептөөлөр ар башка нормативдерде аткарылган ($before жана $after). Чыгымдардагы айырма чарбанын чечимин эмес, базанын алмашканын билдирет.';
  }

  @override
  String get pdfTitle => 'Чарбанын оптималдуу планынын эсеби';

  @override
  String pdfDate(String date) {
    return 'Эсептөө күнү: $date';
  }

  @override
  String pdfPage(int page, int total) {
    return '$total беттин $page-бети';
  }

  @override
  String get pdfNoResult => 'Эсептөөнүн натыйжасы жок.';

  @override
  String get pdfInputSection => 'Баштапкы маалыматтар';

  @override
  String get pdfFarmType => 'Чарбанын түрү';

  @override
  String get pdfAvailableBreeds => 'Жеткиликтүү тукумдар';

  @override
  String get pdfTotalCost => 'ЖЫЛДЫК ЖАЛПЫ ЧЫГЫМ';

  @override
  String pdfWhatToSow(String used, String total) {
    return 'Эмне себүү керек — $total гадан $used га';
  }

  @override
  String get pdfColCrop => 'Эгин';

  @override
  String get pdfColLand => 'Жерлер';

  @override
  String get pdfColArea => 'Аянты, га';

  @override
  String pdfUnusedLand(String area) {
    return 'Ээленбеген $area га: бул жерлерде тоют кымбатыраак турат.';
  }

  @override
  String pdfHowManyHeads(int heads) {
    return 'Канча баш багуу керек — баары $heads';
  }

  @override
  String get pdfColBreed => 'Тукум';

  @override
  String get pdfColDirection => 'Багыты';

  @override
  String get pdfColHeads => 'Баш';

  @override
  String get pdfCostStructure => 'Чыгымдардын түзүмү';

  @override
  String get pdfColItem => 'Беренеси';

  @override
  String get pdfColShare => 'Үлүшү';

  @override
  String get pdfColSum => 'Суммасы, сом';

  @override
  String pdfMissingLand(String area) {
    return 'Учурдагы түшүмдүүлүктө болжол менен $area га айдоо жер жетишпейт.';
  }

  @override
  String get pdfDemoWarning =>
      'КӨҢҮЛ БУРУҢУЗ: эсептөө демонстрациялык нормативдерде аткарылган. Институттун чыныгы нормативдик базасы кошула элек.';

  @override
  String get adminTitle => 'Нормативдик база';

  @override
  String get adminSavedNotice =>
      'База сакталды. Эсептөөлөр жаңы нормативдер боюнча жүрүшү үчүн колдонмону кайра иштетиңиз.';

  @override
  String get adminResetNotice =>
      'Камтылган базага кайтуу. Колдонмону кайра иштетиңиз.';

  @override
  String get adminApply => 'Бул базаны колдонуу';

  @override
  String get adminCancel => 'Жокко чыгаруу';

  @override
  String get adminReadingFile => 'Файл окулууда…';

  @override
  String get adminPickFile => 'Excel файлын жүктөө';

  @override
  String get adminResetToBundled => 'Камтылган базага кайтуу';

  @override
  String get adminCurrentBase => 'УЧУРДАГЫ БАЗА';

  @override
  String get adminVersion => 'Версия';

  @override
  String get adminSource => 'Булагы';

  @override
  String get adminSourceBundled => 'колдонмого камтылган';

  @override
  String get adminSourceImported => 'кол менен жүктөлгөн';

  @override
  String get adminLandsCount => 'Жерлер';

  @override
  String get adminCropsCount => 'Эгиндер';

  @override
  String get adminBreedsCount => 'Тукумдар жана багыттар';

  @override
  String get adminDemoWarning =>
      'База демонстрациялык деп белгиленген — эсептөөлөрдү чарбаларга көрсөтүүгө болбойт.';

  @override
  String get adminPreviewTitle => 'ФАЙЛ ОКУЛДУ — ТЕКШЕРИҢИЗ';

  @override
  String adminPreviewCrops(String list) {
    return 'Эгиндер: $list';
  }

  @override
  String adminPreviewBreeds(String list) {
    return 'Тукумдар: $list';
  }

  @override
  String adminIssuesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Файл жүктөлгөн жок — $count эскертүү:',
    );
    return '$_temp0';
  }

  @override
  String adminIssuesMore(int count) {
    return '…дагы $count';
  }

  @override
  String get adminFormatTitle => 'ФАЙЛДЫН ФОРМАТЫ';

  @override
  String get adminFormatIntro =>
      'Барактары бар .xlsx файл (биринчи сап — аталыштар):';

  @override
  String get adminFormatLands => 'id · Аталышы';

  @override
  String get adminFormatCrops =>
      'id · Аталышы · Жер · Түшүмдүүлүк · Чыгым · Сатып алуу баасы';

  @override
  String get adminFormatProducts => 'id · Аталышы · Бирдиги';

  @override
  String get adminFormatBreeds =>
      'Тукум id · Тукум · Продукция id · Чыгымы · Чыгым · андан ары ар бир эгинге бир мамычадан — тоютка муктаждык';

  @override
  String get adminFormatMeta => 'version · мааниси';

  @override
  String get adminFormatKyColumns =>
      'Кыргызча аталыштар — «Название (кырг.)», «Единица (кырг.)» жана «Порода (кырг.)» деген милдеттүү эмес мамычалар. Аларды барактын аягына кошсо болот: мамычалар номери боюнча эмес, аталышы боюнча табылат. Аларсыз кыргызча интерфейс справочниктин орусча аталыштарын көрсөтөт.';

  @override
  String get adminFormatNote =>
      'Бир эгин канча жерде өссө, ошончо сапты ээлейт. Дал .xlsx форматында сактаңыз: Excelдин Windows версиясындагы CSV кириллицаны бузат.';

  @override
  String importIssueAtRow(String sheet, int row, String message) {
    return '«$sheet», $row-сап: $message';
  }

  @override
  String importIssueAtSheet(String sheet, String message) {
    return '«$sheet»: $message';
  }

  @override
  String get importFileLabel => 'файл';

  @override
  String importFileUnreadable(String error) {
    return 'окуу мүмкүн болгон жок: $error';
  }

  @override
  String get importSheetMissing => 'файлда мындай барак жок';

  @override
  String get importSheetEmpty => 'барак бош';

  @override
  String get importNoRows => 'бир дагы сап жок';

  @override
  String get importIdAndNameRequired => 'id да, аталышы да керек';

  @override
  String importUnknownLand(String id) {
    return 'белгисиз жер «$id»';
  }

  @override
  String get importNumbersRequired => 'түшүмдүүлүк жана чыгым сан болушу керек';

  @override
  String get importNameRequired => 'аталышы көрсөтүлгөн эмес';

  @override
  String importUnknownCropInHeader(String id) {
    return 'аталышта белгисиз эгин: «$id»';
  }

  @override
  String get importFeedColumnsMissing =>
      'алтынчы мамычадан баштап эгиндердин id-си турушу керек — тоютка муктаждык';

  @override
  String importUnknownProduct(String id) {
    return 'белгисиз продукция «$id»';
  }

  @override
  String get importYieldMustBePositive =>
      'продукциянын чыгышы нөлдөн чоң болушу керек';

  @override
  String get importCostMustBeNumber =>
      'бир башка кеткен чыгым сан болушу керек';

  @override
  String get importFeedNeedEmpty =>
      'бир дагы тоютка муктаждык толтурулган эмес';

  @override
  String get stepBreedsLimitLabel => 'Көбү дегенде';

  @override
  String get stepBreedsLimitHint => 'Мал башы чектелбесе, бош калтырыңыз';

  @override
  String get resultFeedPurchase => 'КОШУМЧА САТЫП АЛУУ КЕРЕК';

  @override
  String get resultFeedPurchaseHint =>
      'Бул жемдерди өз жериңиз бербейт — модель аларды базар баасы боюнча эсептеди.';

  @override
  String get resultPurchasedFeed => 'Сатылып алынган жем';

  @override
  String get resultSelfSufficient => 'Чарба өзүн жем менен толук камсыз кылат.';

  @override
  String get modelFormulaBreedLimit =>
      'Чарба койгон болсо, тукум боюнча мал башынын чеги';

  @override
  String get modelFormulaPurchase => 'Жем сатып алуу терс эмес';

  @override
  String get modelGlossaryFeedPrice =>
      'j-жемдин базардагы бир тоннасынын баасы';

  @override
  String get modelGlossaryBreedLimit => 'чарбадагы l-тукумдун чектүү мал башы';

  @override
  String get modelGlossaryUnknownPurchase =>
      'изделүүчү: j-жемден канча тонна кошумча сатып алуу керек';

  @override
  String get explainFeedPurchaseTitle => 'Жем сатып алуу';

  @override
  String get explainFeedPurchaseNone => 'талап кылынган жок';

  @override
  String explainFeedPurchaseSome(String tons, String cost) {
    return '$tons т, $cost сом';
  }

  @override
  String get explainFeedPurchaseTextNone =>
      'Бүткүл рацион өз айдоолоруңуз жана жайыттарыңыз менен жабылды. Жем сатып алуунун кереги жок.';

  @override
  String get explainFeedPurchaseTextSome =>
      'Бүткүл рационго өз жериңиз жетпейт. Модель гектардын наркын жана жемдин базардагы баасын салыштырып, арзаныраагын тандады.';

  @override
  String get explainFormulaPurchase =>
      '(1.3)  a[k][j]·x[k][j] суммасы + z[j] ≥ q[j][h][l]·y[h][l] суммасы';

  @override
  String get stepLandPastureNote =>
      'Жайыттар айдоо жери менен бирдей эсепке алынат: жайыттагы жем — рациондун эң арзан бөлүгү.';

  @override
  String get pdfFeedPurchase => 'Кошумча сатып алуу керек';

  @override
  String get pdfColFeed => 'Жем';

  @override
  String get pdfColTons => 'Тонна';

  @override
  String get pdfSelfSufficient =>
      'Жем сатып алуунун кереги жок: чарба өзүн толук камсыз кылат.';
}
