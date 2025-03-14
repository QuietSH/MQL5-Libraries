//+------------------------------------------------------------------+
//|                                                Handelszeiten.mqh |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Quiet"
#property link      "https://www.mql5.com"

#ifndef __HANDELSZEITEN__MQH
#define __HANDELSZEITEN__MQH

// Funktion, die den Wochentag eines gegebenen datetime-Werts berechnet
int BerechneWochentag(datetime aktuelleZeit)
{
   MqlDateTime timeStruct;
   TimeToStruct(aktuelleZeit, timeStruct);  // Konvertiere datetime zu MqlDateTime-Struktur

   return timeStruct.day_of_week;  // Gibt den Wochentag zurück (0 = Sonntag, 1 = Montag, ..., 6 = Samstag)
}

// Funktion, die zu einem datetime-Wert eine bestimmte Zeitspanne in Sekunden hinzufügt
datetime AddTime(datetime time, int seconds)
{
   MqlDateTime timeStruct;
   TimeToStruct(time, timeStruct);  // datetime in MqlDateTime-Struktur konvertieren
   
   timeStruct.sec += seconds;  // Sekunden hinzufügen
   if (timeStruct.sec >= 60)
   {
      timeStruct.sec -= 60;
      timeStruct.min += 1;
   }

   if (timeStruct.min >= 60)
   {
      timeStruct.min -= 60;
      timeStruct.hour += 1;
   }

   if (timeStruct.hour >= 24)
   {
      timeStruct.hour -= 24;
      timeStruct.day += 1;
   }

   // Zeitüberschreitungen (Monate, Jahre) werden hier nicht behandelt, da es nur um Stunden, Minuten und Sekunden geht.
   return StructToTime(timeStruct);  // Zurück in datetime konvertieren
}

// Funktion, die die Handelszeiten für verschiedene Assets zurückgibt und die Minuten berechnet
int BerechneHandelszeitInMinuten(string asset, datetime startZeit, datetime endZeit)
{
   datetime marketStart, marketEnd;
   
   // Handelszeiten für das jeweilige Asset setzen
   if (asset == "Forex")
   {
      marketStart = StringToTime("2025.03.14 00:00:00");  // Forex-Handelszeit beginnt um Mitternacht (Serverzeit)
      marketEnd = StringToTime("2025.03.14 23:59:59");    // Forex-Handelszeit endet um 23:59 Uhr
   }
   else if (asset == "Aktien")
   {
      marketStart = StringToTime("2025.03.14 09:00:00");  // Aktienhandelszeit beginnt um 9:00 Uhr
      marketEnd = StringToTime("2025.03.14 17:00:00");    // Aktienhandelszeit endet um 17:00 Uhr
   }
   else if (asset == "Krypto")
   {
      marketStart = StringToTime("2025.03.14 00:00:00");  // Krypto-Handelszeit beginnt um Mitternacht
      marketEnd = StringToTime("2025.03.14 23:59:59");    // Krypto-Handelszeit endet um 23:59 Uhr
   }
   else
   {
      // Standardwerte für unbekannte Assets
      marketStart = StringToTime("2025.03.14 00:00:00");
      marketEnd = StringToTime("2025.03.14 23:59:59");
   }

   // Berechnung der Zeitspanne in Minuten, die außerhalb der Handelszeiten liegt
   int totalMinutes = 0;

   // Gehe durch die Tage von startZeit bis endZeit und berechne die Handelszeit unter Berücksichtigung von Wochenenden
   datetime currentTime = startZeit;

   while (currentTime < endZeit)
   {
      // Wenn es ein Wochenende ist, überspringe den Tag
      int wochentag = BerechneWochentag(currentTime);
      if (wochentag == 0 || wochentag == 6) // 0=Sonntag, 6=Samstag
      {
         currentTime = AddTime(currentTime, 24 * 3600);  // Nächster Tag
         continue;
      }

      // Wenn der Tag innerhalb der Handelszeit liegt, berechne die Minuten
      if (currentTime >= marketStart && currentTime <= marketEnd)
      {
         datetime nextTime = AddTime(currentTime, 3600); // 1 Stunde später

         if (nextTime > endZeit) {
            nextTime = endZeit; // Verhindert, dass die Zeit über das Ende hinausgeht
         }

         int diffMinutes = (int) (nextTime - currentTime) / 60; // Berechne Minuten zwischen den beiden Zeitpunkten
         totalMinutes += diffMinutes;
      }
      currentTime = AddTime(currentTime, 3600); // 1 Stunde später
   }
   
   return totalMinutes;
}

#endif
