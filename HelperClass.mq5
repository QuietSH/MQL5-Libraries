//+------------------------------------------------------------------+
//|                                                  HelperClass.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "ErrorHandler.mq5";

// Funktion für führende Null
// Diese Funktion fügt führende Nullen vor einer Zahl hinzu, um eine bestimmte Länge zu erreichen.
// Sie gibt eine formatierte Zahl als String zurück, wobei die Anzahl der Nullen durch den Parameter 'zeros' bestimmt wird.
// Zum Beispiel wird aus '5' mit 'zeros = 3' die Ausgabe '0005'.
string ZeroPad(int number, int zeros = 1){
   return StringFormat("%0*ld", zeros + 1, number); // Formatierung mit führenden Nullen
}

// Gibt die aktuelle Uhrzeit als String zurück, im Format hh:mm:ss
// Diese Funktion holt die aktuelle Zeit und gibt sie als String im Format 'hh:mm:ss' zurück.
// Sie verwendet die MqlDateTime-Struktur und formatiert die Zeit entsprechend.
// Beispiel: '12:30:45'
string GetTime(){
   MqlDateTime time;
   TimeCurrent(time);  // Nur einmal pro Aufruf
   return StringFormat("%02d:%02d:%02d", time.hour, time.min, time.sec);
}

// Gibt das Datum und die Uhrzeit im Format 'dd.mm.yyyy hh:mm' zurück
// Diese Funktion konvertiert entweder das aktuelle Datum oder ein übergebenes Datum in das Format 'dd.mm.yyyy hh:mm'.
// Der optionale Parameter 'date' kann verwendet werden, um ein spezifisches Datum zu übergeben.
// Beispiel: '15.03.2025 09:13'
string GetDateTime(datetime date = -1){
   MqlDateTime _datetime;
   if(date == -1)
      TimeCurrent(_datetime);
   else
      TimeToStruct(date, _datetime);
   return StringFormat("%02d.%02d.%04d %02d:%02d", _datetime.day, _datetime.mon, _datetime.year, _datetime.hour, _datetime.min);
}

// Gibt einen Double-Wert als String zurück, formatiert auf zwei Dezimalstellen
// Diese Funktion nimmt einen Double-Wert und gibt ihn als String mit genau zwei Dezimalstellen zurück.
// Der Wert wird normalisiert und dann als String im Format 'xx.xx' ausgegeben.
// Beispiel: '25.75'
string GetDblStr(double Number){
   return DoubleToString(NormalizeDouble(Number, 2), 2);
}

// Kürzt einen Double-Wert auf zwei Dezimalstellen
// Diese Funktion gibt einen Double-Wert zurück, der auf zwei Dezimalstellen gerundet ist.
// Sie verwendet NormalizeDouble, um den Wert auf genau zwei Dezimalstellen zu kürzen.
// Beispiel: aus '25.756' wird '25.76'
double GetClrDbl(double Number){
   return NormalizeDouble(Number, 2);
}

// Konvertiert einen ENUM_TIMEFRAMES-Wert in einen String
// Diese Funktion nimmt einen ENUM_TIMEFRAMES-Wert und gibt den entsprechenden Zeitrahmen als String zurück.
// Sie verwendet ein Array, um den Zeitrahmen zu bestimmen und gibt den zugehörigen Wert als String zurück.
// Beispiel: ENUM_TIMEFRAMES.H4 wird zu 'H4'
string TF_To_Str(ENUM_TIMEFRAMES tf){
   string tfStrings[] = {"M1", "M2", "M3", "M5", "M10", "M15", "M30", "H1", "H2", "H4", "D1", "W1"};
   int idx = (int)tf / 60; // Um den richtigen Index im Array zu finden
   if (idx >= 0 && idx < ArraySize(tfStrings)) {
      return tfStrings[idx];
   } else {
      return IntegerToString((int)tf); // Rückgabe als Standardwert, wenn der Wert nicht im Array ist
   }
}

// Konvertiert einen ENUM_TIMEFRAMES-Wert in Sekunden
// Diese Funktion gibt den Wert eines ENUM_TIMEFRAMES als Anzahl der Sekunden zurück.
// Sie nutzt die interne MQL5-Darstellung der Zeitrahmen und gibt diese als Integer zurück.
// Beispiel: ENUM_TIMEFRAMES.H1 wird zu 3600 (Sekunden)
int TimeframeToSeconds(ENUM_TIMEFRAMES timeframe)
{
   switch(timeframe) {
        case PERIOD_M1:   return 60;       // 1 Minute
        case PERIOD_M5:   return 5 * 60;   // 5 Minuten
        case PERIOD_M15:  return 15 * 60;  // 15 Minuten
        case PERIOD_M30:  return 30 * 60;  // 30 Minuten
        case PERIOD_H1:   return 60 * 60;  // 1 Stunde
        case PERIOD_H4:   return 4 * 60 * 60; // 4 Stunden
        case PERIOD_D1:   return 24 * 60 * 60; // 1 Tag
        case PERIOD_W1:   return 7 * 24 * 60 * 60; // 1 Woche
        case PERIOD_MN1:  return 30 * 24 * 60 * 60; // 1 Monat
        default:          return -1; // Unbekannter Zeitraum
    }
}

// Gibt den letzten Moment des aktuellen Tages (23:59:59) zurück
// Diese Funktion berechnet das Ende des aktuellen Tages, indem sie die Stunden, Minuten und Sekunden auf 23, 59, 59 setzt.
// Sie verwendet die TimeToStruct und StructToTime-Funktionen, um den datetime-Wert zu berechnen.
// Beispiel: 2025.03.15 23:59:59
datetime GetEndOfDay(){
   MqlDateTime time;
   TimeToStruct(TimeCurrent(),time);
   time.hour = 23; time.min = 59; time.sec = 59;
   datetime endOfDay = StructToTime(time);
   return endOfDay;
}

// Gibt den ersten Moment des aktuellen Tages (00:00:01) zurück
// Diese Funktion berechnet das Ende des aktuellen Tages, indem sie die Stunden, Minuten und Sekunden auf 00, 00, 01 setzt.
// Sie verwendet die TimeToStruct und StructToTime-Funktionen, um den datetime-Wert zu berechnen.
// Beispiel: 2025.03.15 00:00:01
datetime GetStartOfDay(){
   MqlDateTime time;
   TimeToStruct(TimeCurrent(),time);
   time.hour = 00; time.min = 00; time.sec = 01;
   datetime endOfDay = StructToTime(time);
   return endOfDay;
}

string GetError(int error_code){
   ErrorHandler error;
   return error.GetErrorMessage(error_code);
}