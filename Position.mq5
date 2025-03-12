//+------------------------------------------------------------------+
//|                                                     Position.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

class Position{
   private:
      double _price;
      double _volume;
      datetime _opentime;
      int _type;
      int _step;
      
      
   public:
      Position(){}
      Position(double Volume, double Price, datetime OpenTime, int Type){
         _volume = Volume; _price = Price; _opentime = OpenTime; _type = Type;
         _step = _volume / SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
      }
      
      int GetType(){
         return _type;
      }
      
      double GetPrice(){
         return _price;
      }
      
      double GetVolume(){
         return _volume;
      }
      
      datetime GetOpenTime(){
         return _opentime;
      }
      
      int GetMinVolStep(){
         return _step;
      }
      
};

class PositionsInfo{
   private:
      int count;
      double cut_long, cut_short, _vlong, _vshort;
   public:
      Position Long[];
      Position Short[];
      
      PositionsInfo(){
         Init();
      }
      
   void Init(){
      count = PositionsTotal();
      ArrayResize(Long,0);
      ArrayResize(Short,0);
      bool isSym = false;
      int symcount = 0;
      
      for(int i = 0; i < count; i++){
         PositionSelect(_Symbol);
         string sym = PositionGetString(POSITION_SYMBOL);
         if(sym == _Symbol){
            isSym = true;
            symcount++;
            ulong t = PositionGetTicket(i);
            int type = PositionGetInteger(POSITION_TYPE);
            datetime opentime = PositionGetInteger(POSITION_TIME);
            double price  = PositionGetDouble(POSITION_PRICE_OPEN);
            double volume = PositionGetDouble(POSITION_VOLUME);
            
            Position pos = new Position(volume,price,opentime,type); 
            
            if(type == 0){
               ArrayResize(Long,ArraySize(Long) + 1);
               Long[ArraySize(Long) - 1] = pos;
               _vlong += volume;
            }
            else{
               ArrayResize(Short,ArraySize(Short) + 1);
               Short[ArraySize(Short) - 1] = pos;
               _vshort += volume;
            }
         }
      }
      
      if(isSym){
         //Print(symcount);
      }
   }
   
   int CountLong(){
      return ArraySize(Long);
   }
   
   int CountShort(){
      return ArraySize(Short);
   }
   
   double VolumeLong(){
      return _vlong;
   }
   
   double VolumeShort(){
      return _vshort;
   }
   
   int Count(){
      return PositionsTotal();
   }
   
   double CutPriceLong(bool draw = false){
      string name = "CutPriceLong";
      cut_long = 0;
      _vlong = 0;
      int step = 0;
      if(CountLong() > 1){
         for(int i = 0; i < CountLong(); i++){
            cut_long += Long[i].GetPrice();
            step += Long[i].GetMinVolStep();
         }
         cut_long = cut_long / step;
      
         
         if(draw && cut_long > 0){
            DE.DrawTrendLine(name,TimeCurrent()-10000,cut_long,TimeCurrent()+10000,cut_long);
            ObjectSetInteger(NULL,name,OBJPROP_STYLE,STYLE_DASHDOTDOT);
            ObjectSetInteger(NULL,name,OBJPROP_COLOR,clrGreen);
            return cut_long;
         }
         DE.DeleteObject(name);
      }
      return -1;
   }
   
   double CutPriceShort(bool draw = false){
      cut_short = 0;
      int step = 0;
      if(CountShort() > 1){
         for(int i = 0; i < count; i++){
            cut_short += Short[i].GetPrice();
            step += Short[i].GetMinVolStep();
         }
         
         cut_short = cut_short / step;
         string name = "CutPriceShort";
         if(draw && cut_short > 0){
            DE.DrawTrendLine(name,TimeCurrent()-10000,cut_short,TimeCurrent()+10000,cut_short);
            ObjectSetInteger(NULL,name,OBJPROP_STYLE,STYLE_DASHDOTDOT);
            ObjectSetInteger(NULL,name,OBJPROP_COLOR,clrFireBrick);
            return cut_short;
         }
         
         DE.DeleteObject(name);  
      }   
      return -1;
   }
   
   double ProfitPoints(){
      double p = 0;
      double lv,sv;
      
      if(CountLong() == CountShort() && VolumeLong() == VolumeShort()){
         for(int i = 0; i < CountLong(); i++){
            p += ((SymbolInfoDouble(_Symbol,SYMBOL_BID) - Long[i].GetPrice()));
         }
         
         for(int i = 0; i < CountShort(); i++){
            p += ((Short[i].GetPrice() - SymbolInfoDouble(_Symbol,SYMBOL_BID)));
         }
      }else{
         for(int i = 0; i < CountLong(); i++){
            p += ((SymbolInfoDouble(_Symbol,SYMBOL_BID) - Long[i].GetPrice())*Long[i].GetMinVolStep());
         }
         
         for(int i = 0; i < CountShort(); i++){
            p += ((Short[i].GetPrice() - SymbolInfoDouble(_Symbol,SYMBOL_BID))*Short[i].GetMinVolStep());
         }
      }
      return p;
   }
};