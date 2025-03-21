//+------------------------------------------------------------------+
//|                                               TrendLinePrice.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

// Struktur zur Speicherung der Trendlinien-Daten
//TODO Doku
struct TL{
   double Price_1;         // Preis des ersten Punktes
   double Price_2;         // Preis des zweiten Punktes
   datetime Time_1;       // Zeit des ersten Punktes
   datetime Time_2;       // Zeit des zweiten Punktes
   double Steigung;       // Steigung der Trendlinie
   double Abschnitt;      // Y-Achsenabschnitt der Trendlinie
   double AktuellerPreis; // Aktueller Preis an der Trendlinie
   string Direction;      // Richtung der Trendlinie (Long/Short)
   string Name;           // Name der Trendlinie
   int Tage;              // Anzahl der Tage zwischen den Punkten
};

// Klasse zur Verwaltung und Berechnung von Trendlinienpreismodellen
//TODO Doku
class TrendLinePrice {
private:
   datetime time_1, time_2; // Zeitpunkte der Trendlinie
   double price_1, price_2; // Preispunkte der Trendlinie
   double trendSteigung;    // Steigung der Trendlinie
   double trendAchsenAbschnitt; // Y-Achsenabschnitt der Trendlinie
   int tage;                // Anzahl der Tage zwischen den Punkten
   
   TL TrendLine[];          // Array von Trendlinien
   double currentPrice;     // Speichert den aktuellen Preis (z.B. Bid oder Ask)
   datetime nextUpdate;     // Nächster Update-Zeitpunkt
   int updateFrequency;     // Frequenz der Updates
   double distanceThreshold; // Abstand, bei dem auf den nächsten Tick gewechselt wird
   int currentDistance;     // Aktueller Abstand zum Zielpreis

   // Funktion zum Hinzufügen einer neuen Trendlinie in das Array
   void AddTrendLine(){
      int size = ArraySize(TrendLine);
      if(ArrayResize(TrendLine, size + 1) != size + 1){
         Print("Fehler beim Vergrößern des Arrays TrendLine!");
         return;
      }
      TrendLine[size].Price_1 = 0.0;
      TrendLine[size].Price_2 = 0.0;
      TrendLine[size].Time_1 = -1;
      TrendLine[size].Time_2 = -1;
      TrendLine[size].Steigung = 0.0;
      TrendLine[size].Abschnitt = 0.0;
      TrendLine[size].Direction = "";
      TrendLine[size].Name = "";
      TrendLine[size].Tage = -1;
   }
   
   // Gibt die Anzahl der gespeicherten Trendlinien zurück
   int TLS(){
      return ArraySize(TrendLine);
   }
   
   // Gibt den Index der letzten gespeicherten Trendlinie zurück
   int TLP(){
      return ArraySize(TrendLine) - 1;
   }
   
   // Berechnet die Entfernung zwischen zwei Werten
   double Distance(double value_1, double value_2){
      return (value_1 < value_2) ? value_2-value_1 : value_1-value_2;
   }
   
public:
   // Konstruktor: Durchsucht den Chart nach Trendlinien und speichert sie
   void Init() {
      ArrayFree(TrendLine);
      updateFrequency = 10; // Standardmäßige Update-Frequenz auf 10 Sekunden
      distanceThreshold = 10.0; // Abstand, bei dem auf den nächsten Tick gewechselt wird
      currentDistance = 0;
      
      int objCount = ObjectsTotal(NULL,0,OBJ_TREND);
      if(objCount == 0)
         return;
      for (int i = 0; i < objCount; i++) {
         string objName = ObjectName(NULL,i,0,OBJ_TREND);
         if (StringFind(objName, "Trendline") != -1) {
            time_1 = ObjectGetInteger(0, objName, OBJPROP_TIME,0);
            price_1 = ObjectGetDouble(0, objName, OBJPROP_PRICE,0);
            time_2 = ObjectGetInteger(0, objName, OBJPROP_TIME,1);
            price_2 = ObjectGetDouble(0, objName, OBJPROP_PRICE,1);
            tage = ((time_2-time_1) - (1*(24*60*60))) / (24*60*60);
            
            //TODO Doku
            if(time_1 == time_2) {
               Print("Fehlerhafte Trendlinie: time_1 == time_2 für ", objName);
               continue;
            }else if(price_1 == 0.0) {
               Print("Fehlerhafte Trendlinie: price_1 == 0.0 für ", objName);
               continue;
            }else if(price_2 == 0.0) {
               Print("Fehlerhafte Trendlinie: price_2 == 0.0 für ", objName);
               continue;
            }else if(time_2 > GetEndOfDay()) {
               Print("Fehlerhafte Trendlinie: time_2 > EndOfDay für ", objName);
               continue;
            }
            else if(time_2 < TimeCurrent()) {
               Print("Fehlerhafte Trendlinie: time_2 < CurrentTime für ", objName);
               continue;
            }
            AddTrendLine();
            BerechneTrendlinie();
            int p = TLP();
            TrendLine[p].Name = objName;
            TrendLine[p].Time_1 = time_1;
            TrendLine[p].Time_2 = time_2;
            TrendLine[p].Price_1 = price_1;
            TrendLine[p].Price_2 = price_2;
            TrendLine[p].Steigung = trendSteigung;
            TrendLine[p].Abschnitt = trendAchsenAbschnitt;
            TrendLine[p].Direction = (price_1 < price_2) ? "Long" : "Short";
            TrendLine[p].Tage = tage;
         }
      }
   }
   
   // Berechnet den nächsten Preis für jede Trendlinie und speichert den nächsten Trend
   //TODO Doku
   void FindClosestTrendLine() {
      double closestDistance = -1;
      int closestIndex = -1;
      
      for (int i = 0; i < ArraySize(TrendLine); i++) {
         double trendLinePrice = BerechnePreisZumZeitpunkt(TimeCurrent(), TrendLine[i].Steigung, TrendLine[i].Abschnitt);
         double distance = MathAbs(SymbolInfoDouble(_Symbol, SYMBOL_BID) - trendLinePrice);
         
         if (closestDistance == -1 || distance < closestDistance) {
            closestDistance = distance;
            closestIndex = i;
         }
      }
      
      if (closestIndex != -1) {
         currentPrice = BerechnePreisZumZeitpunkt(TimeCurrent(), TrendLine[closestIndex].Steigung, TrendLine[closestIndex].Abschnitt);
         Print("Nächste Trendlinie gefunden: ", currentPrice, " bei Trendlinie Index ", closestIndex);
      }
   }
   
   // Aktualisiert alle gespeicherten Trendlinien basierend auf dem aktuellen Marktpreis
   //TODO Doku
   void UpdateTrendLines() {
      for(int i = 0; i < TLS(); i++) {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double trendLinePrice = BerechnePreisZumZeitpunkt(TimeCurrent(), TrendLine[i].Steigung, TrendLine[i].Abschnitt);
         double distance = MathAbs(bid - trendLinePrice);
         
         updateFrequency = (distance > distanceThreshold) ? 10 : 1;
         nextUpdate = TimeCurrent() + updateFrequency;
         
         if (updateFrequency == 1) {
            BerechneTrendlinie(); // Update der Trendlinie
         }
      }
   }
   
   // Gibt Informationen zu den aktuellen Trendlinien aus
   void Ausgabe(){
      int t = TLS();
      if(t < 1)
         return;
      Print("Trendlinien Check: Count = ", t);
      for(int i = 0; i < t; i++){
         double p3 = BerechnePreisZumZeitpunkt(TimeCurrent(),TrendLine[i].Steigung,TrendLine[i].Abschnitt);
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID), distance = MathAbs(bid - p3);
         Print("Current Time: ", TimeCurrent()," Name: ", TrendLine[i].Name, " Tage: ", TrendLine[i].Tage, " Distance: ", GetDblStr(distance));
      }
   }
   
   // Berechnet die Steigung und den Y-Achsenabschnitt der Trendlinie
   //TODO Docu
   void BerechneTrendlinie() {
      trendSteigung = (price_2 - price_1) / (time_2 - time_1);
      trendAchsenAbschnitt = price_1 - trendSteigung * time_1;
   }

   // Berechnet den Preis zu einem bestimmten Zeitpunkt basierend auf der Trendlinie
   //TODO Docu
   double BerechnePreisZumZeitpunkt(datetime zeit, double Steigung, double Abschnitt) {
      return (Steigung * zeit + Abschnitt);
   }
};
