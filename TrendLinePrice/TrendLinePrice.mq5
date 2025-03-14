//+------------------------------------------------------------------+
//|                                               TrendLinePrice.mq5 |
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

#include "../Include/Handelszeiten.mqh";

struct TL{
   double Price_1;
   double Price_2;
   datetime Time_1;
   datetime Time_2;
   double Steigung;
   double Abschnitt;
   double AktuellerPreis;
   string Direction;
   string Name;
};

class TrendLinePrice {
private:
   datetime time_1, time_2; // Zeitpunkte der Trendlinie
   double price_1, price_2; // Preispunkte der Trendlinie
   double trendSteigung; // Steigung der Trendlinie
   double trendAchsenAbschnitt; // Y-Achsenabschnitt der Trendlinie
   //int tls;
   
   TL TrendLine[];
   double currentPrice; // Speichert den aktuellen Preis (z. B. Bid oder Ask)
   datetime nextUpdate;
   int updateFrequency;
   double distanceThreshold;
   int currentDistance;
   
   void AddTrendLine(){
      int size = ArraySize(TrendLine);
      if(ArrayResize(TrendLine, size + 1) != size + 1){
         Print("Fehler beim Vergrößern des Arrays TrendLine!");
         return;
      }
      //tls = size + 1;
      //ArrayResize(TrendLine,size + 1);
      TrendLine[size].Price_1 = 0.0;
      TrendLine[size].Price_2 = 0.0;
      TrendLine[size].Time_1 = -1;
      TrendLine[size].Time_2 = -1;
      TrendLine[size].Steigung = 0.0;
      TrendLine[size].Abschnitt = 0.0;
      TrendLine[size].Direction = "";
      TrendLine[size].Name = "";
   }
   
   int TLS(){
      return ArraySize(TrendLine);
   }
   
   int TLP(){
      return ArraySize(TrendLine) - 1;
   }
   
   double Distance(double value_1, double value_2){
      return (value_1 < value_2) ? value_2-value_1 : value_1-value_2;
   }
   
public:
   // Konstruktor, der den Chart nach Trendlinien durchsucht
   void Init() {
      // Durchsuche den Chart nach Objekten, die "Trendlinie" im Namen haben
      ArrayFree(TrendLine);
      updateFrequency = 10; // Update alle 10 Sekunden standardmäßig
      distanceThreshold = 10.0; // Abstand, bei dem wir auf OnTick wechseln
      currentDistance = 0; // Aktueller Abstand
      
      int objCount = ObjectsTotal(NULL,0,OBJ_TREND);
      if(objCount == 0)
         return;
      for (int i = 0; i < objCount; i++) {
         string objName = ObjectName(NULL,i,0,OBJ_TREND);
         if (StringFind(objName, "Trendline") != -1) { // Wenn der Name "Trendlinie" enthält
            // Holen der Start- und Endpunkte der Trendlinie
            
            time_1 = ObjectGetInteger(0, objName, OBJPROP_TIME,0); // Zeit des ersten Punktes
            price_1 = ObjectGetDouble(0, objName, OBJPROP_PRICE,0); // Preis des ersten Punktes
            time_2 = ObjectGetInteger(0, objName, OBJPROP_TIME,1); // Zeit des zweiten Punktes
            price_2 = ObjectGetDouble(0, objName, OBJPROP_PRICE,1); // Preis des zweiten Punktes
            
            // Fehlerbehandlung: Ungültige Trendlinien überspringen
            if(time_1 == time_2 || price_1 == 0.0 || price_2 == 0.0 || !(time_1 < TimeCurrent() && time_2 > TimeCurrent())) {
               Print("Fehlerhafte Trendlinie übersprungen: ", objName);
               continue;
            }
            
            AddTrendLine();
            // Berechne die Trendlinie
            BerechneTrendlinie();
            int p = TLP();
            TrendLine[p].Name = objName;
            TrendLine[p].Time_1 = time_1;
            TrendLine[p].Time_2 = time_2;
            TrendLine[p].Price_1 = price_1;
            TrendLine[p].Price_2 = price_2;
            TrendLine[p].Steigung = trendSteigung;
            TrendLine[p].Abschnitt = trendAchsenAbschnitt;
            TrendLine[p].Direction = (price_1 < price_2) ? "Long":"Short";
         }
      }
   }
   
   // Funktion, die den nächsten Preis zur Trendlinie berechnet
   void FindClosestTrendLine() {
      double closestDistance = -1;
      int closestIndex = -1;
      
      // Durchlaufe alle Trendlinien
      for (int i = 0; i < ArraySize(TrendLine); i++) {
         // Berechne den Preis der Trendlinie zum aktuellen Zeitpunkt
         double trendLinePrice = BerechnePreisZumZeitpunkt(TimeCurrent(), TrendLine[i].Steigung, TrendLine[i].Abschnitt);
         
         // Berechne die Entfernung zwischen dem aktuellen Preis und dem Preis der Trendlinie
         double distance = MathAbs(SymbolInfoDouble(_Symbol, SYMBOL_BID) - trendLinePrice);
         
         // Finde den Preis, der am nächsten zum aktuellen Preis ist
         if (closestDistance == -1 || distance < closestDistance) {
            closestDistance = distance;
            closestIndex = i;
         }
      }
      
      // Wenn der Index der nächsten Trendlinie gefunden wurde, den Preis speichern
      if (closestIndex != -1) {
         currentPrice = BerechnePreisZumZeitpunkt(TimeCurrent(), TrendLine[closestIndex].Steigung, TrendLine[closestIndex].Abschnitt);
         Print("Nächste Trendlinie gefunden: ", currentPrice, " bei Trendlinie Index ", closestIndex);
      }
   }
   
   void UpdateTrendLines() {
      for(int i = 0; i < TLS(); i++) {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double trendLinePrice = BerechnePreisZumZeitpunkt(TimeCurrent(), TrendLine[i].Steigung, TrendLine[i].Abschnitt);
         double distance = MathAbs(bid - trendLinePrice);
         Print(Distance(bid,trendLinePrice)," ",distance);
         
         updateFrequency = (distance > distanceThreshold) ? 10:1;
         
         nextUpdate = TimeCurrent() + updateFrequency;
         Print("Time: ",TimeCurrent()," next update: ", nextUpdate, " distance: ",distance," maxDistance: ", distanceThreshold);
         // Hier könntest du dann auch die Trendlinie bei Bedarf updaten
         // Je nach Abstandsregel, die du festgelegt hast
         if (updateFrequency == 1) {
            BerechneTrendlinie(); // Update der Trendlinie
         }
      }
   }
   
   // Gibt die Steigung und den Y-Achsenabschnitt der Trendlinie aus
   void Ausgabe(){
      int t = TLS();
      if(t < 1)
         return;
      Print("Trendlinien Check: Count = ", t);
      for(int i = 0; i < t; i++){
         double p3 = BerechnePreisZumZeitpunkt(TimeCurrent(),TrendLine[i].Steigung,TrendLine[i].Abschnitt);
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID), distance = MathAbs(bid - p3);
         Print((i+1)," Start:[", TrendLine[i].Time_1, " " ,GetDblStr(TrendLine[i].Price_1),"] End:[",TrendLine[i].Time_2, " ", GetDblStr(TrendLine[i].Price_2),
         "] aktueller TrendLinePreis: ", GetDblStr(p3), " Distance: ", GetDblStr(distance), " Direction: ",TrendLine[i].Direction);
      }
   }
   // Berechnet die Trendlinie basierend auf den zwei Punkten
   void BerechneTrendlinie() {
      // Berechnung der Steigung (m) und des Achsenabschnitts (b)
      trendSteigung = (price_2 - price_1) / (time_2 - time_1);
      trendAchsenAbschnitt = price_1 - trendSteigung * time_1;
   }

   // Berechnet den Preis zu einem bestimmten Zeitpunkt (x)
   double BerechnePreisZumZeitpunkt(datetime zeit, double Steigung, double Abschnitt) {
      return Steigung * zeit + Abschnitt;
   }
};
