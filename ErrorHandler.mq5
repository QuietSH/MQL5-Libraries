//+------------------------------------------------------------------+
//|                                                 ErrorHandler.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

class ErrorHandler {
private:
   string error_messages[];

public:
   // Konstruktor: Initialisiert die Fehlernachrichten
   ErrorHandler() {
      // Dateioperationen
      error_messages[1]  = "Ungültiger Dateiname";
      error_messages[2]  = "Datei existiert nicht";
      error_messages[3]  = "Unzureichende Berechtigungen";
      error_messages[4]  = "Datei ist bereits geöffnet";
      error_messages[5]  = "Fehler beim Schreiben auf die Datei";
      error_messages[6]  = "Fehler beim Lesen von der Datei";
      error_messages[7]  = "Unzureichender Speicher";
      error_messages[8]  = "Fehler bei der Dateioperation";

      // MQL5 Systemfehler
      error_messages[1001] = "Ungültiger Funktionsaufruf";
      error_messages[1002] = "Nicht genug Speicher";
      error_messages[1003] = "Unzulässige Operation";
      error_messages[1004] = "Nicht unterstützte Funktion";
      error_messages[1005] = "Fehler bei der Berechnung";

      // Mathematische Fehler
      error_messages[2001] = "Division durch Null";
      error_messages[2002] = "Ungültige Argumente für eine mathematische Funktion";

      // Allgemeine Fehler
      error_messages[3001] = "Unbekannter Fehler";
      error_messages[3002] = "Fehler bei der Initialisierung";
      error_messages[3003] = "Fehler beim Zugriff auf ein Objekt";
      error_messages[3004] = "Fehler in der Logik";

      // Handelsfehler (Orders und Positionen)
      error_messages[4001] = "Fehler beim Senden einer Order";
      error_messages[4002] = "Fehler bei der Positionseröffnung";
      error_messages[4003] = "Fehler beim Schließen einer Position";
      error_messages[4004] = "Fehler beim Stornieren einer Order";
      error_messages[4005] = "Order wurde abgelehnt";
      error_messages[4006] = "Fehler bei der Überprüfung der Handelsbedingungen";
      error_messages[4007] = "Nicht genug Kapital, um eine Order zu öffnen";
      error_messages[4008] = "Fehler bei der Berechnung der Margin";
      error_messages[4009] = "Slippage überschreitet erlaubtes Limit";
      error_messages[4010] = "Fehler bei der Handelsposition";
      error_messages[4011] = "Fehler beim Abrufen von Positionsinformationen";
      error_messages[4012] = "Fehler beim Aktualisieren der Order";
   }

   // Gibt eine Fehlermeldung basierend auf dem Fehlercode zurück
   string GetErrorMessage(int error_code) {
      if (error_messages[error_code] != "") {
         return error_messages[error_code];
      } else {
         return "Unbekannter Fehlercode: " + IntegerToString(error_code);
      }
   }
};