//+------------------------------------------------------------------+
//|                                              TestEAFunctions.mq5 |
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


void GetTrends(){
   double d_Trend_1 = DE.HLinePrice(Trend_1);
   double d_Trend_2 = DE.HLinePrice(Trend_2);
   double d_Trend_tmp = DE.HLinePrice("tmp_Trend");
   
   if(sym.Bid() > d_Trend_1){
      UI.lbl_Trend_1_value.SetText("Long");
   }else{
      UI.lbl_Trend_1_value.SetText("Short");
   }
   
   if(sym.Bid() > d_Trend_2){
      UI.lbl_Trend_2_value.SetText("Long");
   }else{
      UI.lbl_Trend_2_value.SetText("Short");
   }
   
   if(sym.Bid() > d_Trend_tmp){
      UI.lbl_Trend_tmp_value.SetText("Long");
   }else{
      UI.lbl_Trend_tmp_value.SetText("Short");
   }
}