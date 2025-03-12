//+------------------------------------------------------------------+
//|                                                        Trade.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"


class clsTrade{
   private:
      ulong magicnumber;
      double volume, initialSL;
      bool drawSL;
      
      bool CheckSL(){
         if(initialSL <= 0)
            return false;
         return true;
      }
   public:
      void Init(ulong MagicNumber,double Volume, double InitialSL){
         magicnumber = MagicNumber; volume = Volume; initialSL = InitialSL;
      }
      
      void SetInitialSL(double Points){
         initialSL = Points;
      }
      
      double GetSLShort(double Price, bool drawSL = false){
         double sl;
         if(_Digits == 2){
            sl = Price + (initialSL * 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT));
            if(drawSL)
               ObjectCreate(0,"SLShort",OBJ_TREND,0,TimeCurrent()-1000,sl,TimeCurrent()+1000,sl);
            return sl;
         }
         else if(_Digits > 2){
            sl = Price + (initialSL * 10 * SymbolInfoDouble(_Symbol,SYMBOL_POINT));
            if(drawSL)
               ObjectCreate(0,"SLShort",OBJ_TREND,0,TimeCurrent()-1000,sl,TimeCurrent()+1000,sl);
            return sl;
         }
         return -1;
      }
      
      double GetSLLong(double Price, bool drawSL = false){
         double sl;
         if(_Digits == 2){
            sl = Price - (initialSL * 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT));
            if(drawSL)
               ObjectCreate(0,"SLLong",OBJ_TREND,0,TimeCurrent()-1000,sl,TimeCurrent()+1000,sl);
            return sl;
         }
         else if(_Digits > 2){
            sl = Price - (initialSL * 10 * SymbolInfoDouble(_Symbol,SYMBOL_POINT));
            if(drawSL)
               ObjectCreate(0,"SLLong",OBJ_TREND,0,TimeCurrent()-1000,sl,TimeCurrent()+1000,sl);
            return sl;
         }
         return -1;
      }
      
      void MarketBuy(){
         if(!CheckSL())
            return;
         
         MqlTradeRequest request = {};
         MqlTradeResult result = {};
         MqlTradeCheckResult checkresult = {};
         
         request.action = TRADE_ACTION_DEAL;
         request.symbol = _Symbol;
         request.volume = volume;
         request.type = ORDER_TYPE_BUY;
         request.price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         request.sl = request.price - (initialSL * 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT));
         request.magic = magicnumber;
         
         if(!OrderCheck(request,checkresult)){
            Print("OrderCheck failed " + GetLastError());
            return;
         }
         
         if(!OrderSend(request,result)){
            Print("Order not Send: " + GetLastError());
         }
      }
      
      void MarketSell(){
         if(!CheckSL())
            return;
            
         MqlTradeRequest request = {};
         MqlTradeResult result = {};
         MqlTradeCheckResult checkresult = {};
         
         request.action = TRADE_ACTION_DEAL;
         request.symbol = _Symbol;
         request.volume = volume;
         request.type = ORDER_TYPE_SELL;
         request.price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         request.sl = request.price + (initialSL * 100 * SymbolInfoDouble(_Symbol,SYMBOL_POINT));
         request.magic = magicnumber;
         
         if(!OrderCheck(request,checkresult)){
            Print("OrderCheck failed" + GetLastError());
            return;
         }
         
         if(!OrderSend(request,result)){
            Print("Order not Send: " + GetLastError());
         }else
            Print("Order Open: ");
      }
      
      void DeInit(){
         ObjectDelete(0,"SLLong");
         ObjectDelete(0,"SLShort");
      }
};

clsTrade trade;