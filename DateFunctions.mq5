//+------------------------------------------------------------------+
//|                                                DateFunctions.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+
class DateFunctions{
   
   public:
   bool IsFirstFriday(datetime date)
   {
      // MQLStruct für das Datum
      MqlDateTime dt;
      TimeToStruct(date, dt);
      
      // Erster Tag des Monats
      datetime firstDay = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + ".01 00:00");
      
      // Wochentag des ersten Tages (0=Sonntag, 1=Montag, ..., 6=Samstag)
      int firstDayOfWeek = dt.day_of_week;
      
      // Berechnen der Differenz zum ersten Freitag (Freitag ist 5)
      int daysToAdd = (5 - firstDayOfWeek + 7) % 7;
      
      // Datum des ersten Freitags
      datetime firstFriday = firstDay + daysToAdd * 24 * 3600; // Tage in Sekunden umrechnen
   
      // Überprüfen, ob das gegebene Datum dem ersten Freitag des Monats entspricht
      return date == firstFriday;
   }
};