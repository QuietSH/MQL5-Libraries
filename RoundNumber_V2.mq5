//+------------------------------------------------------------------+
//|                                               RoundNumber_V2.mq5 |
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

input group "RoundNumber";
input double StartStep = 100.0;
input double Step = 100.0;
input int Lines = 5;
input int LineWidth = 1;
input ENUM_LINE_STYLE LineStyle = STYLE_DASHDOTDOT;
input color LineColor = clrLightGray;

class RoundNumberV2{
   private:
      double roundedValue;
      double bid;
      string Line[];
      
      void AddLine(string Name){
         int size = ArraySize(Line);
         ArrayResize(Line,size + 1);
         Line[size] = Name;
      }
      
      double RoundToNearestStep(double price, double step){
         if (step <= 0) return price; // Fehlervermeidung
         
         int digits = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         
         // Anpassung für verschiedene Märkte
         if (pointSize >= 0.01) // Aktien, Gold, Indizes
            step = NormalizeDouble(step, 0);
         else if (pointSize == 0.001 || pointSize == 0.0001) // Forex Standard
            step *= pointSize;
         
         return NormalizeDouble(MathRound(price / step) * step, digits);
      }
      
   public:
      // Methode, um den Wert basierend auf den Digits des Symbols auf das nächste 100 Punkte zu runden
      void Init(){
         if (StartStep <= 0) {
            Print("Fehler: StartStep darf nicht 0 oder negativ sein!");
            return; // Gibt den Originalwert zurück
         }
         
         bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         // Anzahl der Dezimalstellen für das aktuelle Symbol
         int digits = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Größe eines Pips/Punkts
         bool isForex = (pointSize < 0.01);
         
         //Print(RoundToNearestStep(bid,StartStep));
         
         double stepAdjusted = StartStep;
         if (isForex) {
            stepAdjusted = StartStep * pointSize; // Umrechnung für Forex
         }
         
         double rv;
         roundedValue = MathRound(bid/StartStep)*StartStep;
         
         if(digits == 3){
            roundedValue = NormalizeDouble(bid,0);
         }else if(digits == 4)
            roundedValue = NormalizeDouble(bid,2);
         else if(digits == 5)
            roundedValue = NormalizeDouble(bid,3);
         
         //Print("Symbol: ", _Symbol, ", Bid: ", bid, ", StartStep: ", StartStep, ", Rounded Value: " + roundedValue);
         
         Draw.HLine("RN_RefLine",roundedValue,LineColor,LineStyle,LineWidth);
         AddLine("RN_RefLine");
      }
      
      double GetStepAdjusted(int idx) {
         if (Step == 0) {
            Print("Fehler: StartStep darf nicht 0 sein!");
            return 0; // Fehlerfall
         }
      
         int digits = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Größe eines Pips/Punkts
         bool isForex = (pointSize < 0.01);
         
         double stepAdjusted = idx * Step;
         if (digits > 3) {
            stepAdjusted = idx * Step * pointSize; // Umrechnung für Forex
         }
         return stepAdjusted;
      }
      
      void DrawLines(){
         for(int i = 1; i <= Lines; i++){
            Draw.HLine("RN_Line_Top_" + i ,roundedValue + GetStepAdjusted(i),LineColor,LineStyle,LineWidth);
            AddLine("RN_Line_Top_" + i);
            
            Draw.HLine("RN_Line_Bottom_" + i ,roundedValue - GetStepAdjusted(i),LineColor,LineStyle,LineWidth);
            AddLine("RN_Line_Bottom_" + i);
         }
         ChartRedraw();
      }
      
      void DeleteDraw(){
         for(int i = 0; i <= ArraySize(Line) -1; i++){
            ObjectDelete(NULL,Line[i]);
         }
      }
      
      // Methode, die den gerundeten Wert zurückgibt
      double GetRoundedValue()
      {
         return roundedValue;
      }
      
      // Methode zur Darstellung des gerundeten Wertes in der Konsole
      void PrintRoundedValue(double value)
      {
         Print("Original Value: ", bid, " Rounded to Nearest 100: ", roundedValue);
      }
};