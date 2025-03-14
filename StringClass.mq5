//+------------------------------------------------------------------+
//|                                                  StringClass.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"


// Funktion für führende Null
string ZeroPad(int number, int zeros = 1){
   return StringFormat("%0*ld", zeros + 1, number); // Formatierung mit führenden Nullen
}
//Gibt die aktuelle Uhrzeit als STring wieder, im Format hh:mm:ss
string GetTime(){
   MqlDateTime time;
   TimeCurrent(time);  // Nur einmal pro Aufruf
   return StringFormat("%02d:%02d:%02d", time.hour, time.min, time.sec);
}

string GetDateTime(datetime date = -1){
   MqlDateTime _datetime;
   if(date == -1)
      TimeCurrent(_datetime);
   else
      TimeToStruct(date, _datetime);
   return StringFormat("%02d.%02d.%04d %02d:%02d", _datetime.day, _datetime.mon, _datetime.year, _datetime.hour, _datetime.min);
}

//Gibt ein DoubleWert als String zurück mit zwei Stellen nach dem Kommata
string GetDblStr(double Number){
   return DoubleToString(NormalizeDouble(Number, 2), 2);
}

//Kürzt einen DoubleWert auf zwei Stellen nach dem Kommata
double GetClrDbl(double Number){
   return NormalizeDouble(Number, 2);
}

string TF_To_Str(ENUM_TIMEFRAMES tf){
   // Array mit den Strings der Zeitrahmen
   string tfStrings[] = {"M1", "M2", "M3", "M5", "M10", "M15", "M30", "H1", "H2", "H4", "D1", "W1"};
   
   // Der Index in der Array ist (Zeitrahmen - 1) / Anzahl der Minuten
   int idx = (int)tf / 60; // Um den richtigen Index im Array zu finden
   
   if (idx >= 0 && idx < ArraySize(tfStrings)) {
      return tfStrings[idx];
   } else {
      return IntegerToString((int)tf); // Rückgabe als Standardwert, wenn der Wert nicht im Array ist
   }
}

int TimeframeToSeconds(ENUM_TIMEFRAMES timeframe)
{
   return (int)timeframe;
}