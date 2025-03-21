//+------------------------------------------------------------------+
//|                                                 DrawElements.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

class DrawElements{

   public:
   
      //sucht ein Element nach Namen im Chart
      bool FindElement(string Name){
         int res = ObjectFind(NULL,Name);
         if(res == 0)
            return true;
         return false;
      }
      
      double HLinePrice(string Name){
         if(FindElement(Name))
            return ObjectGetDouble(NULL,Name,OBJPROP_PRICE);
         return -1;
      }
      
      void HLine(string Name, double Price, color lineColor, ENUM_LINE_STYLE lineStyle, int lineWidth){
         if(!FindElement(Name)){ // Falls die Linie noch nicht existiert
            ObjectCreate(NULL, Name, OBJ_HLINE, 0, 0, 0);
         }
         
         ObjectSetInteger(NULL, Name, OBJPROP_COLOR, lineColor);
         ObjectSetInteger(NULL, Name, OBJPROP_STYLE, lineStyle);
         ObjectSetInteger(NULL, Name, OBJPROP_WIDTH, lineWidth);
         ObjectSetDouble(NULL, Name, OBJPROP_PRICE, Price);
      }
      
      void Trendline(string name, double price, datetime start, color lineColor, int width = 1)
      {
         // Prüfen, ob die Linie bereits existiert
         if(ObjectFind(NULL, name) != 0)
         {
            // Linie erstellen
            ObjectCreate(NULL, name, OBJ_TREND, 0, start, price, TimeCurrent() + 50000, price);
      
            // Eigenschaften setzen
            ObjectSetInteger(NULL, name, OBJPROP_COLOR, lineColor);
            ObjectSetInteger(NULL, name, OBJPROP_WIDTH, width);
         }
         else
         {
            ObjectSetInteger(NULL, name, OBJPROP_COLOR, lineColor);
            ObjectMove(NULL,name,0,start,price);
            ObjectMove(NULL,name,1,TimeCurrent() + 50000,price);
            ObjectSetInteger(NULL, name, OBJPROP_WIDTH, width);
         }
      }
      
      void Trendline(string Name, datetime Time_1, double Price_1, datetime Time_2, double Price_2, color lineColor){
         ObjectCreate(NULL,Name,OBJ_TREND,0,Time_1,Price_1,Time_2,Price_2);
      }
      
      double TLinePriceA(string Name){
         if(FindElement(Name))
            return ObjectGetDouble(NULL,Name,OBJPROP_PRICE,0);
         return -1;
      }
      
      double TLinePriceB(string Name){
         if(FindElement(Name))
            return ObjectGetDouble(NULL,Name,OBJPROP_PRICE,1);
         return -1;
      }
      
      bool isSelected(string Name){
         if(FindElement(Name) && ObjectGetInteger(NULL,Name,OBJPROP_SELECTED) == 1)
            return true;
         return false;
      }
      
      int GetType(string Name){
         return ObjectGetInteger(NULL,Name,OBJPROP_TYPE);
      }
      
      
      
      void DeleteObject(string Name){
         if(FindElement(Name))
            ObjectDelete(NULL,Name);
      }
   
};