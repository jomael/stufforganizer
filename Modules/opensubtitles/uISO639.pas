unit uISO639;

interface

uses
  Windows;

type
  TLanguageItem = record
      Code: string[2];
      ISO639: string[2];
      Lang: string[3];
      Name : string[100];
  end;

var
  LanguageList: array[0..49] of TLanguageItem = (
    (Code: 'sq'; ISO639: 'sq'; Lang: 'alb'; Name: 'Albanian'),
    (Code: 'ar'; ISO639: 'ar'; Lang: 'ara'; Name: 'Arabic'),
    (Code: 'hy'; ISO639: 'hy'; Lang: 'arm'; Name: 'Armenian'),
    (Code: 'ms'; ISO639: 'ms'; Lang: 'may'; Name: 'Malay'),
    (Code: 'bs'; ISO639: 'bs'; Lang: 'bos'; Name: 'Bosnian'),
    (Code: 'bg'; ISO639: 'bg'; Lang: 'bul'; Name: 'Bulgarian'),
    (Code: 'ca'; ISO639: 'ca'; Lang: 'cat'; Name: 'Catalan'),
    (Code: 'eu'; ISO639: 'eu'; Lang: 'eus'; Name: 'Basque'),
    (Code: 'zh_CN'; ISO639: 'zh'; Lang: 'chi'; Name: 'Chinese (China)'),
    (Code: 'hr'; ISO639: 'hr'; Lang: 'hrv'; Name: 'Croatian'),
    (Code: 'cs'; ISO639: 'cs'; Lang: 'cze'; Name: 'Czech'),
    (Code: 'da'; ISO639: 'da'; Lang: 'dan'; Name: 'Danish'),
    (Code: 'nl'; ISO639: 'nl'; Lang: 'dut'; Name: 'Dutch'),
    (Code: 'en'; ISO639: 'en'; Lang: 'eng'; Name: 'English (US)'),
    (Code: 'en_GB'; ISO639: 'en'; Lang: 'bre'; Name: 'English (UK)'),
    (Code: 'eo'; ISO639: 'eo'; Lang: 'epo'; Name: 'Esperanto'),
    (Code: 'et'; ISO639: 'et'; Lang: 'est'; Name: 'Estonian'),
    (Code: 'fi'; ISO639: 'fi'; Lang: 'fin'; Name: 'Finnish'),
    (Code: 'fr'; ISO639: 'fr'; Lang: 'fre'; Name: 'French'),
    (Code: 'gl'; ISO639: 'gl'; Lang: 'glg'; Name: 'Galician'),
    (Code: 'ka'; ISO639: 'ka'; Lang: 'geo'; Name: 'Georgian'),
    (Code: 'de'; ISO639: 'de'; Lang: 'ger'; Name: 'German'),
    (Code: 'el'; ISO639: 'el'; Lang: 'ell'; Name: 'Greek'),
    (Code: 'he'; ISO639: 'he'; Lang: 'heb'; Name: 'Hebrew'),
    (Code: 'hu'; ISO639: 'hu'; Lang: 'hun'; Name: 'Hungarian'),
    (Code: 'id'; ISO639: 'id'; Lang: 'ind'; Name: 'Indonesian'),
    (Code: 'it'; ISO639: 'it'; Lang: 'ita'; Name: 'Italian'),
    (Code: 'ja'; ISO639: 'ja'; Lang: 'jpn'; Name: 'Japanese'),
    (Code: 'kk'; ISO639: 'kk'; Lang: 'kaz'; Name: 'Kazakh'),
    (Code: 'ko'; ISO639: 'ko'; Lang: 'kor'; Name: 'Korean'),
    (Code: 'lv'; ISO639: 'lv'; Lang: 'lav'; Name: 'Latvian'),
    (Code: 'lt'; ISO639: 'lt'; Lang: 'lit'; Name: 'Lithuanian'),
    (Code: 'lb'; ISO639: 'lb'; Lang: 'ltz'; Name: 'Luxembourgish'),
    (Code: 'mk'; ISO639: 'mk'; Lang: 'mac'; Name: 'Macedonian'),
    (Code: 'no'; ISO639: 'no'; Lang: 'nor'; Name: 'Norwegian'),
    (Code: 'fa'; ISO639: 'fa'; Lang: 'per'; Name: 'Persian'),
    (Code: 'pl'; ISO639: 'pl'; Lang: 'pol'; Name: 'Polish'),
    (Code: 'pt_PT'; ISO639: 'pt'; Lang: 'por'; Name: 'Portuguese (Portugal)'),
    (Code: 'pt_BR'; ISO639: 'pb'; Lang: 'pob'; Name: 'Portuguese (Brazil)'),
    (Code: 'ro'; ISO639: 'ro'; Lang: 'rum'; Name: 'Romanian'),
    (Code: 'ru'; ISO639: 'ru'; Lang: 'rus'; Name: 'Russian'),
    (Code: 'sr'; ISO639: 'sr'; Lang: 'scc'; Name: 'Serbian'),
    (Code: 'sk'; ISO639: 'sk'; Lang: 'slo'; Name: 'Slovak'),
    (Code: 'sl'; ISO639: 'sl'; Lang: 'slv'; Name: 'Slovenian'),
    (Code: 'es_ES'; ISO639: 'es'; Lang: 'spa'; Name: 'Spanish (Spain)'),
    (Code: 'sv'; ISO639: 'sv'; Lang: 'swe'; Name: 'Swedish'),
    (Code: 'th'; ISO639: 'th'; Lang: 'tha'; Name: 'Thai'),
    (Code: 'tr'; ISO639: 'tr'; Lang: 'tur'; Name: 'Turkish'),
    (Code: 'uk'; ISO639: 'uk'; Lang: 'ukr'; Name: 'Ukrainian'),
    (Code: 'vi'; ISO639: 'vi'; Lang: 'vie'; Name: 'Vietnamese'));

function AutoDetectLanguage: TLanguageItem;

implementation

function AutoDetectLanguage: TLanguageItem;
var
  I: integer;
  ID: LangID;
  Language: array [0..100] of char;
begin
  ID := GetSystemDefaultLangID;
  GetLocaleInfo(ID, LOCALE_SISO639LANGNAME, Language, 100 );

  for I := Low(LanguageList) to High(LanguageList) do
  begin
    if LanguageList[I].ISO639 = string(Language) then
      Exit(LanguageList[I]);
  end;
end;

end.
