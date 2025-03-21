//+------------------------------------------------------------------+
//|                                                       Symbol.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

class clsSymbol{
   private:
      string name;
      ENUM_BORDER_TYPE btype;
      int fntsize;
      bool showwindow;
   public:
      clsSymbol(){
         name = "SymbolWindow";
         fntsize = 10;
      }
      //Gibt den Ask Kurs zurück
      double Ask(){ return SymbolInfoDouble(_Symbol,SYMBOL_ASK); }
      
      //Gibt den Bid Kurs zudück
      double Bid(){ return SymbolInfoDouble(_Symbol,SYMBOL_BID); }
      
      //Gibt den Spread zudück
      double Spread(){
         double res = Ask()-Bid();
         return StringToDouble(DoubleToString(res * MathPow(10,_Digits)/100,2));
      }
      
      double PointValue(){
         return SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      }
      
      double Risk(double SL, double Volume){
         double value = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
         double size  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
         
         return (SL/size*Volume) / MathPow(10,_Digits);
      }
      
      string Sector(){
         return SymbolInfoString(_Symbol,SYMBOL_SECTOR_NAME);
      }
      
      string Industry(){
         return SymbolInfoString(_Symbol,SYMBOL_INDUSTRY_NAME);
      }
      
      string Category(){
         return SymbolInfoString(_Symbol,SYMBOL_CATEGORY);
      }
      
      string Description(){
         return SymbolInfoString(_Symbol,SYMBOL_DESCRIPTION);
      }
      
      bool WindowShow(){
         return showwindow;
      }
      
      //Gibt den Marginwert für das jeweilige Symbol zurück, abhängig von den übergebenen Werten
      //Standardwerte sind für den aktuellen Preis und des kleinsten Volumen auf eine Buy Order
      double Margin(double Volumen = 0, double Price = 0, ENUM_ORDER_TYPE OrderType = ORDER_TYPE_BUY){
         double val;
         
         if(Volumen == 0.0)
            Volumen = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
         
         if(Price == 0.0)
            Price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            
         OrderCalcMargin(OrderType,_Symbol,Volumen,Price,val);
         return val;
      }
      
      //Gibt das Tagestief zurück
      //ago = 0 entspricht dem aktuellen Tag, ago = 1 gestern usw.
      double DayLow(int ago = 1){
         return iLow(_Symbol,PERIOD_D1,ago);
      }
      
      //Gibt das Tageshoch zurück
      //ago = 0 entspricht dem aktuellen Tag, ago = 1 gestern usw.
      double DayHigh(int ago = 1){
         return iHigh(_Symbol,PERIOD_D1,ago);
      }
      
      //Gibt die Tageseröffnung zurück (erster Kurs des Tages des Tages)
      //ago = 0 entspricht dem aktuellen Tag, ago = 1 gestern usw.
      double DayOpen(int ago = 0){
         return iOpen(_Symbol,PERIOD_D1,ago);
      }
      
      void DrawDayOpen(){
         MqlDateTime t_1;
         MqlDateTime t_2;
         TimeCurrent(t_1);
         
         t_2 = t_1;
         t_1.hour = 0;
         t_1.min = 0;
         t_1.sec = 0;
         t_2.hour = 23;
         t_2.min = 59;
         t_2.sec = 59;
         
         //Print(StructToTime(t_1) + " " + StructToTime(t_2));
         
         ObjectCreate(NULL,"DayOpen",OBJ_TREND,0,StructToTime(t_1),DayOpen(),StructToTime(t_2),DayOpen());
         ObjectSetInteger(NULL,"DayOpen",OBJPROP_SELECTABLE,1);
      }
      
      //Gibt den TagesSchlusskurs zurück
      //ago = 0 entspricht dem aktuellen Tag, ago = 1 gestern usw.
      //da der aktuelle Tag nie geschlossen ist wird hier ein Tag hinzuaddiert
      double DayClose(int ago = 0){
         return iClose(_Symbol,PERIOD_D1,ago + 1);
      }
      
      void DrawWindow(int X, int Y){
         //Erstellt das Fenster
         if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
            return;
         SetBorderType();
         ObjectSetInteger(NULL,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name,OBJPROP_XDISTANCE,X);
         ObjectSetInteger(NULL,name,OBJPROP_YDISTANCE,Y);
         ObjectSetInteger(NULL,name,OBJPROP_XSIZE,200);
         ObjectSetInteger(NULL,name,OBJPROP_YSIZE,100);
         ObjectSetInteger(NULL,name,OBJPROP_ZORDER,0);
         
         //Erstellt MarginLabel
         if(!ObjectCreate(NULL,name + "_lbl_Margin",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Margin",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Margin",OBJPROP_XDISTANCE,X - 10);
         ObjectSetInteger(NULL,name + "_lbl_Margin",OBJPROP_YDISTANCE,Y + 10);
         ObjectSetInteger(NULL,name + "_lbl_Margin",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Margin",OBJPROP_TEXT,"Margin: ");
         ObjectSetInteger(NULL,name + "_lbl_Margin",OBJPROP_ZORDER,1);
         
         if(!ObjectCreate(NULL,name + "_lbl_Margin_Value",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Margin_Value",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Margin_Value",OBJPROP_XDISTANCE,X - 75);
         ObjectSetInteger(NULL,name + "_lbl_Margin_Value",OBJPROP_YDISTANCE,Y + 10);
         ObjectSetInteger(NULL,name + "_lbl_Margin_Value",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Margin_Value",OBJPROP_TEXT," ");
         ObjectSetInteger(NULL,name + "_lbl_Margin_Value",OBJPROP_ZORDER,1);
         //***********************************************************************************
         
         //Erstellt SpreadLabel
         if(!ObjectCreate(NULL,name + "_lbl_Spread",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Spread",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Spread",OBJPROP_XDISTANCE,X - 10);
         ObjectSetInteger(NULL,name + "_lbl_Spread",OBJPROP_YDISTANCE,Y + 25);
         ObjectSetInteger(NULL,name + "_lbl_Spread",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Spread",OBJPROP_TEXT,"Spread: ");
         ObjectSetInteger(NULL,name + "_lbl_Spread",OBJPROP_ZORDER,1);
         
         if(!ObjectCreate(NULL,name + "_lbl_Spread_Value",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Spread_Value",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Spread_Value",OBJPROP_XDISTANCE,X - 75);
         ObjectSetInteger(NULL,name + "_lbl_Spread_Value",OBJPROP_YDISTANCE,Y + 25);
         ObjectSetInteger(NULL,name + "_lbl_Spread_Value",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Spread_Value",OBJPROP_TEXT," ");
         ObjectSetInteger(NULL,name + "_lbl_Spread_Value",OBJPROP_ZORDER,1);
         //***********************************************************************************
         
         //Erstellt SectorLabel
         if(!ObjectCreate(NULL,name + "_lbl_Sector",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Sector",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Sector",OBJPROP_XDISTANCE,X - 10);
         ObjectSetInteger(NULL,name + "_lbl_Sector",OBJPROP_YDISTANCE,Y + 40);
         ObjectSetInteger(NULL,name + "_lbl_Sector",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Sector",OBJPROP_TEXT,"Sector: ");
         ObjectSetInteger(NULL,name + "_lbl_Sector",OBJPROP_ZORDER,1);
         
         if(!ObjectCreate(NULL,name + "_lbl_Sector_Value",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Sector_Value",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Sector_Value",OBJPROP_XDISTANCE,X - 75);
         ObjectSetInteger(NULL,name + "_lbl_Sector_Value",OBJPROP_YDISTANCE,Y + 40);
         ObjectSetInteger(NULL,name + "_lbl_Sector_Value",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Sector_Value",OBJPROP_TEXT," ");
         ObjectSetInteger(NULL,name + "_lbl_Sector_Value",OBJPROP_ZORDER,1);
         //***********************************************************************************
         
         //Erstellt IndustryLabel
         if(!ObjectCreate(NULL,name + "_lbl_Industry",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Industry",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Industry",OBJPROP_XDISTANCE,X - 10);
         ObjectSetInteger(NULL,name + "_lbl_Industry",OBJPROP_YDISTANCE,Y + 55);
         ObjectSetInteger(NULL,name + "_lbl_Industry",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Industry",OBJPROP_TEXT,"Industry: ");
         ObjectSetInteger(NULL,name + "_lbl_Industry",OBJPROP_ZORDER,1);
         
         if(!ObjectCreate(NULL,name + "_lbl_Industry_Value",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,name + "_lbl_Industry_Value",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,name + "_lbl_Industry_Value",OBJPROP_XDISTANCE,X - 75);
         ObjectSetInteger(NULL,name + "_lbl_Industry_Value",OBJPROP_YDISTANCE,Y + 55);
         ObjectSetInteger(NULL,name + "_lbl_Industry_Value",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,name + "_lbl_Industry_Value",OBJPROP_TEXT," ");
         ObjectSetInteger(NULL,name + "_lbl_Industry_Value",OBJPROP_ZORDER,1);
         
         showwindow = true;
      }
      
      void DeInit(){
         ObjectDelete(NULL,name);
         ObjectDelete(NULL,name + "_lbl_Margin");
         ObjectDelete(NULL,name + "_lbl_Margin_Value");
         ObjectDelete(NULL,name + "_lbl_Spread");
         ObjectDelete(NULL,name + "_lbl_Spread_Value");
         ObjectDelete(NULL,name + "_lbl_Sector");
         ObjectDelete(NULL,name + "_lbl_Sector_Value");
         ObjectDelete(NULL,name + "_lbl_Industry");
         ObjectDelete(NULL,name + "_lbl_Industry_Value");
         
         showwindow = false;
      }
      
      void SetBorderType(ENUM_BORDER_TYPE BType = BORDER_FLAT){
         btype = BType;
         ObjectSetInteger(NULL,name,OBJPROP_BORDER_TYPE,btype);
      }
      
      double TradeSpan(int Days = 10){
         double av = 0;
         double l,h, d = Days + 1;
         for(int i = d; i > 0; i--){
            l = iLow(_Symbol,PERIOD_D1,i);
            h = iHigh(_Symbol,PERIOD_D1,i);
            av += (h-l);
         }
         av = av/Days;
         return av;
      }
      
      double TradeSpanMax(int Days = 10){
         double av = 0;
         double l,h, d = Days + 1;
         for(int i = d; i > 0; i--){
            l = iLow(_Symbol,PERIOD_D1,i);
            h = iHigh(_Symbol,PERIOD_D1,i);
            if(av < h-l)
               av = (h-l);
         }
         return av;
      }
      
      double TradeSpanMin(int Days = 10){
         double av = 0;
         double l,h, d = Days + 1;
         for(int i = d; i > 0; i--){
            l = iLow(_Symbol,PERIOD_D1,i);
            h = iHigh(_Symbol,PERIOD_D1,i);
            if(av == 0)
               av = (h-l);
            if(av > h-l && av > 0)
               av = (h-l);
         }
         return av;
      }
      
      double TradeSpanToday(){
         double av = 0;
         double l,h;
         l = iLow(_Symbol,PERIOD_D1,0);
         h = iHigh(_Symbol,PERIOD_D1,0);
         av = (h-l);
         return av;
      }
      
      
      void OnTick(){
         
         if(ObjectFind(NULL,name) == 0){
            ObjectSetString(NULL,name + "_lbl_Margin_Value",OBJPROP_TEXT,Margin());
            ObjectSetString(NULL,name + "_lbl_Spread_Value",OBJPROP_TEXT,Spread());
            ObjectSetString(NULL,name + "_lbl_Sector_Value",OBJPROP_TEXT,Sector());
            ObjectSetString(NULL,name + "_lbl_Industry_Value",OBJPROP_TEXT,Industry());
         }
      }
      
};