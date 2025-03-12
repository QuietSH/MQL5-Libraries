//+------------------------------------------------------------------+
//|                                                    BuyButton.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "BaseButton.mq5";

class BuyButton : public BaseButton{
   private:
   
   public:
      void OnClick() override{
         Print("Buy");
         //trade.MarketBuy();
      }
};