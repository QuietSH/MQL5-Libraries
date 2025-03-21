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

//+------------------------------------------------------------------+
//| Berechnet die gesamte Arbeitszeit in Minuten zwischen zwei Zeiten |
//| unter Berücksichtigung der Arbeitszeiten und abgezogenen Tagen    |
//+------------------------------------------------------------------+
int BerechneHandelszeitInSekunden(datetime startZeit, datetime endZeit, string arbeitszeitStart, string arbeitszeitEnde)
{
   // Arbeitszeit in Stunden und Minuten umwandeln
   string teile[];
   StringSplit(arbeitszeitStart, ':', teile);
   int startStunde = StringToInteger(teile[0]);
   int startMinute = StringToInteger(teile[1]);
   
   StringSplit(arbeitszeitEnde, ':', teile);
   int endeStunde = StringToInteger(teile[0]);
   int endeMinute = StringToInteger(teile[1]);
   // Arbeitszeit in Minuten berechnen
   int arbeitszeitProTag = (endeStunde * 60 + endeMinute) - (startStunde * 60 + startMinute);

   // Berechne die Gesamtdauer in Tagen zwischen startZeit und endZeit
   int gesamtTage = (int)(endZeit - startZeit) / (24 * 3600);
   Print(gesamtTage);
   // Berechne, wie viele vollständige 7-Tage-Perioden existieren
   int volleWochen = gesamtTage / 7;

   // Berechne die verbleibenden Tage nach den vollständigen 7-Tagen
   int verbleibendeTage = gesamtTage % 7;

   // Berechne die abgezogenen Tage
   int abgezogeneTage = volleWochen * 2;  // Für jede volle Woche 2 Tage abziehen

   // Wenn weniger als 7 Tage verbleiben, 1 Tag abziehen
   if (verbleibendeTage > 0)
   {
      abgezogeneTage += 1;  // Einen Tag für die verbleibenden Tage abziehen
   }

   // Berechne die tatsächlichen Arbeitstage nach den Abzügen
   int arbeitsTage = gesamtTage - abgezogeneTage;
   Print(arbeitsTage);
   // Berechne die gesamte Arbeitszeit in Minuten
   int gesamteArbeitszeit = gesamtTage * arbeitszeitProTag * 60;

   return gesamteArbeitszeit;
}

#endif
