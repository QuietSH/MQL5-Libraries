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
   string numStr = IntegerToString(number);
   while(StringLen(numStr) < zeros + 1) 
      numStr = "0" + numStr;
   return numStr;
}
//Gibt die aktuelle Uhrzeit als STring wieder, im Format hh:mm:ss
string GetTime(){
   MqlDateTime time;
   TimeCurrent(time);
   string h,m,s;
   
   h = ZeroPad(time.hour);
   m = ZeroPad(time.min);
   s = ZeroPad(time.hour);

   return h + ":" + m + ":" + s;
}

string GetDateTime(datetime date = -1){
   MqlDateTime _datetime;
   string D,M,Y,h,m;
   if(date == -1)
      TimeCurrent(_datetime);
   else
      TimeToStruct(date,_datetime);
   
   D = ZeroPad(_datetime.day);
   M = ZeroPad(_datetime.mon);
   Y = ZeroPad(_datetime.year);
   h = ZeroPad(_datetime.hour);
   m = ZeroPad(_datetime.min);
   
   return D + "." + M + "." + Y + "  " + h + ":" + m;
}

//Gibt ein DoubleWert als String zurück mit zwei Stellen nach dem Kommata
string GetDblStr(double Number){
   return DoubleToString(Number,2);
}

//Kürzt einen DoubleWert auf zwei Stellen nach dem Kommata
double GetClrDbl(double Number){
   return StringToDouble(GetDblStr(Number));
}

string TF_To_Str(ENUM_TIMEFRAMES tf){
   string out;
   int p = PeriodSeconds(tf);
   
   switch(p)
   {
      case 60:
         out = "M1";
         break;
      case 120:
         out = "M2";
         break;
      case 180:
         out = "M3";
         break;
      case 300:
         out = "M5";
         break;
      case 600:
         out = "M10";
         break;
      case 900:
         out = "M15";
         break;
      case 1800:
         out = "M30";
         break;
      case 3600:
         out = "H1";
         break;
      case 7200:
         out = "H2";
         break;
      case 14400:
         out = "H4";
         break;
      case 86400:
         out = "D1";
         break;
      case 604800:
         out = "W1";
         break;
      default:
         out = (string)p;
         break;
   }
   
   return out;
}

int TimeframeToSeconds(ENUM_TIMEFRAMES timeframe)
{
    switch (timeframe)
    {
        case PERIOD_M1:   return 60;
        case PERIOD_M2:   return 120;
        case PERIOD_M3:   return 180;
        case PERIOD_M4:   return 240;
        case PERIOD_M5:   return 300;
        case PERIOD_M6:   return 360;
        case PERIOD_M10:  return 600;
        case PERIOD_M12:  return 720;
        case PERIOD_M15:  return 900;
        case PERIOD_M20:  return 1200;
        case PERIOD_M30:  return 1800;
        case PERIOD_H1:   return 3600;
        case PERIOD_H2:   return 7200;
        case PERIOD_H3:   return 10800;
        case PERIOD_H4:   return 14400;
        case PERIOD_H6:   return 21600;
        case PERIOD_H8:   return 28800;
        case PERIOD_H12:  return 43200;
        case PERIOD_D1:   return 86400;
        case PERIOD_W1:   return 604800;
        case PERIOD_MN1:  return 2592000; // Durchschnittlich 30 Tage
        default:          return -1; // Fehlerwert für unbekannte Timeframes
    }
}