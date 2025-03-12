//+------------------------------------------------------------------+
//|                                           UIButtonCollection.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "UIWindow.mq5";
#include "UILabel.mq5";
#include "Button/BuyButton.mq5";
#include "Button/SellButton.mq5";

class UIElements{
   public:
      UIWindow win;
      RSI rsiM15;
      
      UILabel lbl_profit;
      UILabel lbl_profit_value;
      
      UILabel lbl_spread;
      UILabel lbl_spread_value;
      
      UILabel lbl_tradespan_av;
      UILabel lbl_tradespan_av_value;
      
      UILabel lbl_tradespan_td;
      UILabel lbl_tradespan_td_value;
      
      UILabel lbl_tradespan_max;
      UILabel lbl_tradespan_max_value;
      
      UILabel lbl_tradespan_min;
      UILabel lbl_tradespan_min_value;
      
      UILabel lbl_Margin;
      UILabel lbl_Margin_value;
      
      UILabel lbl_DayRatio;
      UILabel lbl_DayRatio_value;
      
      UILabel lbl_Trend_1;
      UILabel lbl_Trend_1_value;
      
      UILabel lbl_Trend_2;
      UILabel lbl_Trend_2_value;
      
      UILabel lbl_Trend_tmp;
      UILabel lbl_Trend_tmp_value;

      void Init(){
         win.Init("Win",250,30,190,290);
         
         rsiM15.Init(PERIOD_M15);
         rsiM15.DrawUI(240,50);
         rsiM15.SetFontSize(10);
         
         lbl_spread.Init("lbl_Spread",240,70);
         lbl_spread.SetText("Spread:");
         lbl_spread_value.Init("lbl_Spread_value",140,70);
         
         lbl_tradespan_av.Init("lbl_TradeSpan_av",240,100);
         lbl_tradespan_av.SetText("av. Tradespan:");
         lbl_tradespan_av_value.Init("lbl_TradeSpan_av_value",140,100);
         
         lbl_tradespan_td.Init("lbl_TradeSpan_td",240,120);
         lbl_tradespan_td.SetText("td. Tradespan:");
         lbl_tradespan_td_value.Init("lbl_TradeSpan_td_value",140,120);
         
         lbl_tradespan_max.Init("lbl_TradeSpan_max",240,140);
         lbl_tradespan_max.SetText("max. Tradespan:");
         lbl_tradespan_max_value.Init("lbl_TradeSpan_max_value",140,140);
         
         lbl_tradespan_min.Init("lbl_TradeSpan_min",240,160);
         lbl_tradespan_min.SetText("min. Tradespan:");
         lbl_tradespan_min_value.Init("lbl_TradeSpan_min_value",140,160);
         
         lbl_profit.Init("lbl_Profit",240,190);
         lbl_profit.SetText("Profit:");
         lbl_profit_value.Init("lbl_Profit_value",140,190);
         
         lbl_Margin.Init("lbl_Margin",240,210);
         lbl_Margin.SetText("Margin:");
         lbl_Margin_value.Init("lbl_Margin_value",140,210);
         
         lbl_DayRatio.Init("lbl_DayRatio",240,240);
         lbl_DayRatio.SetText("DayRatio:");
         lbl_DayRatio_value.Init("lbl_DayRatio_value",140,240);
         
         lbl_Trend_1.Init("lbl_Trend_1",240,260);
         lbl_Trend_1.SetText("Trend 1:");
         lbl_Trend_1_value.Init("lbl_Trend_1_value",140,260);
         
         lbl_Trend_2.Init("lbl_Trend_2",240,280);
         lbl_Trend_2.SetText("Trend 2:");
         lbl_Trend_2_value.Init("lbl_Trend_2_value",140,280);
         
         lbl_Trend_tmp.Init("lbl_Trend_tmp",240,300);
         lbl_Trend_tmp.SetText("Trend tmp:");
         lbl_Trend_tmp_value.Init("lbl_Trend_tmp_value",140,300);

      }
      
      void DeInit(){
         win.DeInit();
         lbl_spread.DeInit();
         lbl_spread_value.DeInit();
         lbl_tradespan_av.DeInit();
         lbl_tradespan_av_value.DeInit();
         lbl_tradespan_td.DeInit();
         lbl_tradespan_td_value.DeInit();
         lbl_tradespan_max.DeInit();
         lbl_tradespan_max_value.DeInit();
         lbl_tradespan_min.DeInit();
         lbl_tradespan_min_value.DeInit();
         rsiM15.DeInit();
         lbl_profit.DeInit();
         lbl_profit_value.DeInit();
         lbl_Margin.DeInit();
         lbl_Margin_value.DeInit();
         lbl_Trend_1.DeInit();
         lbl_Trend_1_value.DeInit();
         lbl_Trend_2.DeInit();
         lbl_Trend_2_value.DeInit();
         lbl_Trend_tmp.DeInit();
         lbl_Trend_tmp_value.DeInit();
         lbl_DayRatio.DeInit();
         lbl_DayRatio_value.DeInit();
      }
};
