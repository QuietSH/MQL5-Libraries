//+------------------------------------------------------------------+
//|                                                          HA2.mq5 |
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

struct HA_Candl{
   double Open;
   double Close;
   double High;
   double Low;
   datetime Time;
   int Direction;
   int Nr;
   double ResistHigh;
   double ResistLow;
   datetime ResistTime;
};

struct HA_Move{
   double StartValue;
   datetime StartTime;
   double MoveValue;
   datetime MoveTime;
   int Direction;
   int Nr;
   string comment;
};

struct StatisticMove{
   double Points;
   int Candls;
   datetime Start;
   datetime End;
   int Direction;
};

class HeikenAshi{
private:
    ENUM_TIMEFRAMES period;    
    int bars;
    HA_Candl HA_Data[];
    HA_Move ha_moves[];
    StatisticMove ha_statistic[];
    string Points[];
    int Trend;
    
    double ha_high_value;
    datetime ha_high_time;
    double ha_low_value;
    datetime ha_low_time;
    
   
   int tpoint(){
      return ArraySize(ha_moves) -1;
   }
   
   int StPoint(){
      return ArraySize(ha_statistic) -1;
   }
   
   void AddPoint(string name){
      int size;
      size = ArraySize(Points);
      ArrayResize(Points,size + 1);
      Points[size] = name;
   }
   
   void AddMove(){
      int size;
      size = ArraySize(ha_moves);
      ArrayResize(ha_moves,size + 1);
      ha_moves[size].MoveTime = 0;
      ha_moves[size].MoveValue = 0.0;
      ha_moves[size].Nr = 0;
      ha_moves[size].StartTime = 0;
      ha_moves[size].StartValue = 0.0;
      ha_moves[size].Direction = 0;
      ha_moves[size].comment = EMPTY_VALUE;
   }
   
   void AddStatistic(){
      int size;
      size = ArraySize(ha_statistic);
      ArrayResize(ha_statistic,size + 1);
      ha_statistic[size].Candls = 0;
      ha_statistic[size].End = 0.0;
      ha_statistic[size].Points = 0.0;
      ha_statistic[size].Start = 0.0;
      ha_statistic[size].Direction = 0;
   }
   
   void DataInit(){
      int len = GetDataLen() -1;
      for(int i = 0; i < len; i++){
         HA_Data[i].Close = 0.0;
         HA_Data[i].Direction = 0;
         HA_Data[i].High = 0.0;
         HA_Data[i].Low = 0.0;
         HA_Data[i].Nr = 0;
         HA_Data[i].Open = 0.0;
         HA_Data[i].ResistHigh = 0.0;
         HA_Data[i].ResistLow = 0.0;
         HA_Data[i].ResistTime = 0;
         HA_Data[i].Time = 0;
      }
   }
   
   void PrintResistArray(bool All = false){
      for(int i = 0; i < 20; i++){
         if(HA_Data[i].ResistLow >  0){
            Print("No: " + HA_Data[i].Nr + " Time: " + HA_Data[i].ResistTime + " ResistLow: " + HA_Data[i].ResistLow);
         }else if(HA_Data[i].ResistLow == 0 && All == true){
            Print("No: " + HA_Data[i].Nr + " Time: " + HA_Data[i].ResistTime + " ResistLow: " + HA_Data[i].ResistLow);
         }
         if(HA_Data[i].ResistHigh >  0){
            Print("No: " + HA_Data[i].Nr + " Time: " + HA_Data[i].ResistTime + " ResistHigh: " + HA_Data[i].ResistHigh);
         }else if(HA_Data[i].ResistHigh == 0 && All == true){
            Print("No: " + HA_Data[i].Nr + " Time: " + HA_Data[i].ResistTime + " ResistHigh: " + HA_Data[i].ResistHigh);
         }
      }
   }
   
public:
    
   void Init(ENUM_TIMEFRAMES TimeFrame, int Candls){
      
      ArrayFree(HA_Data);
      ArrayFree(ha_moves);
      ArrayFree(ha_statistic);
      
      period = TimeFrame;
      bars = Candls + 20;
      
      ArrayResize(HA_Data, bars);
      DataInit();
      for(int i = bars - 1; i >= 1; i--){
         //Print(i);
         CalculateHeikenAshi(i);
         
      }
   }
   
   void CalculateHeikenAshi(int index)
   {
       // Original OHLC-Werte der aktuellen Kerze
       double open  = iOpen(Symbol(), period, index);
       double high  = iHigh(Symbol(), period, index);
       double low   = iLow(Symbol(), period, index);
       double close = iClose(Symbol(), period, index);
       
       HA_Data[index].Nr = index;
       // Heiken-Ashi Close
       HA_Data[index].Close = (open + high + low + close) / 4.0;
       
       // Heiken-Ashi Open (für die erste Kerze gleich dem Open-Wert)
       if (index == bars - 1)
           HA_Data[index].Open = open;
       else
       {
           HA_Data[index].Open = (HA_Data[index + 1].Open + HA_Data[index + 1].Close) / 2.0;
       }
       //Print(ha_Open[index]);
       
       // Heiken-Ashi High
       HA_Data[index].High = MathMax(high, MathMax(HA_Data[index].Open, HA_Data[index].Close));
       
       // Heiken-Ashi Low
       HA_Data[index].Low = MathMin(low, MathMin(HA_Data[index].Open, HA_Data[index].Close));
       
       HA_Data[index].Time = iTime(_Symbol,period,index);
       
       if(HA_Data[index].Close > HA_Data[index].Open)
         HA_Data[index].Direction = 1;
       if(HA_Data[index].Close < HA_Data[index].Open)
         HA_Data[index].Direction = -1;
       
       if(index > bars -2)
         return;
       if(HA_Data[index].Direction == 1){
         //Wenn Low-1 > Close
         if(HA_Data[index+1].Low < HA_Data[index].Low && HA_Data[index+1].ResistLow == 0){
            HA_Data[index].ResistLow = HA_Data[index].Low;
            HA_Data[index].ResistTime = HA_Data[index].Time;
         }else if(HA_Data[index+1].Low < HA_Data[index].Low && HA_Data[index+1].ResistLow < HA_Data[index].Low){
            HA_Data[index].ResistLow = HA_Data[index].Low;
            HA_Data[index].ResistTime = HA_Data[index].Time;
         }else{
            HA_Data[index].ResistLow = HA_Data[index+1].ResistLow;
            HA_Data[index].ResistTime = HA_Data[index+1].ResistTime;
         }
       }else if(HA_Data[index].Direction == -1){
         //Wenn High-1 < Close
         if(HA_Data[index+1].High > HA_Data[index].High && HA_Data[index+1].ResistHigh == 0){
            HA_Data[index].ResistHigh = HA_Data[index].High;
            HA_Data[index].ResistTime = HA_Data[index].Time;
         }else if(HA_Data[index+1].High > HA_Data[index].High && HA_Data[index+1].ResistLow < HA_Data[index].High){
            HA_Data[index].ResistHigh = HA_Data[index].High;
            HA_Data[index].ResistTime = HA_Data[index].Time;
         }else{
            HA_Data[index].ResistHigh = HA_Data[index+1].ResistHigh;
            HA_Data[index].ResistTime = HA_Data[index+1].ResistTime;
         }
       }
   }
   
   void PrintResist(bool PrintArray = 0, bool All = false){
      if(PrintArray == 0){
         if(HA_Data[1].ResistHigh > 0)
            Print("No: " + HA_Data[1].Nr + " Time: " + HA_Data[1].ResistTime + " ResistHigh: " + HA_Data[1].ResistHigh);
         if(HA_Data[1].ResistLow > 0)
            Print("No: " + HA_Data[1].Nr + " Time: " + HA_Data[1].ResistTime + " ResistLow: " + HA_Data[1].ResistLow);
         return;
      }
      PrintResistArray(All);
   }

    void GetTrendInfo(){
      Print("High Time: " + TimeToString(ha_high_time) + " High: " + GetDblStr(ha_high_value));
      Print("Low Time: " + TimeToString(ha_low_time) + " Low: " + GetDblStr(ha_low_value));
    }
    
    int GetMoveLen(){
      return ArraySize(ha_moves);
    }
    
    int GetDataLen(){
      return ArraySize(HA_Data);
    }
    
    int GetStatisticLen(){
      return ArraySize(ha_statistic);
    }
    
    void PrintStatistic(int i = 0){
      if(i < 0) { Print("invalid"); return; }
      int size = ArraySize(ha_statistic);
      int tmp_l_candl = 0, tmp_s_candl = 0;
      double tmp_l_points = 0.0, tmp_s_points = 0.0;
      
      int l_moves = 0, s_moves = 0;
      int l_candl_max = 0, s_candl_max = 0;
      double l_point_max = 0.0, s_point_max = 0.0;
      int l_candl_min = 0, s_candl_min = 0;
      double l_point_min = 0.0, s_point_min = 0.0;
      int l_candl_av = 0, s_candl_av = 0;
      double l_point_av = 0.0, s_point_av = 0.0;
      
      if(i == 0){
         for(int j = 1; j < size - 1; j++){
            if(ha_statistic[j].Direction == 1){
               l_moves++;
               if(l_candl_min == 0 || l_candl_min > ha_statistic[j].Candls)
                  l_candl_min = ha_statistic[j].Candls;
               if(l_candl_max == 0 || l_candl_max < ha_statistic[j].Candls)
                  l_candl_max = ha_statistic[j].Candls;
               if(l_point_min == 0 || l_point_min > ha_statistic[j].Points)
                  l_point_min = ha_statistic[j].Points;
               if(l_point_max == 0 || l_point_max < ha_statistic[j].Points)
                  l_point_max = ha_statistic[j].Points;
               
               tmp_l_candl += ha_statistic[j].Candls;
               tmp_l_points += ha_statistic[j].Points;
            }
            
            if(ha_statistic[j].Direction == -1){
               s_moves++;
               if(s_candl_min == 0 || s_candl_min > ha_statistic[j].Candls)
                  s_candl_min = ha_statistic[j].Candls;
               if(s_candl_max == 0 || s_candl_max < ha_statistic[j].Candls)
                  s_candl_max = ha_statistic[j].Candls;
               if(s_point_min == 0 || s_point_min > ha_statistic[j].Points)
                  s_point_min = ha_statistic[j].Points;
               if(s_point_max == 0 || s_point_max < ha_statistic[j].Points)
                  s_point_max = ha_statistic[j].Points;
               
               tmp_s_candl += ha_statistic[j].Candls;
               tmp_s_points += ha_statistic[j].Points;
            }
         }
         
         l_candl_av = tmp_l_candl/l_moves;
         l_point_av = tmp_l_points/l_moves;
         s_candl_av = tmp_s_candl/s_moves;
         s_point_av = tmp_s_points/s_moves;
         Print("Long Moves:");
         Print("Numbers: " + l_moves);
         Print("Candl Min: " + l_candl_min);
         Print("Candl Max: " + l_candl_max);
         Print("Candl AV: " + l_candl_av);
         Print("Points Min: " + GetDblStr(l_point_min));
         Print("Points Max: " + GetDblStr(l_point_max));
         Print("Points AV: " + GetDblStr(l_point_av));
         Print("-------------------------------------------");
         Print("Short Moves:");
         Print("Numbers: " + s_moves);
         Print("Candl Min: " + s_candl_min);
         Print("Candl Max: " + s_candl_max);
         Print("Candl AV: " + s_candl_av);
         Print("Points Min: " + GetDblStr(s_point_min));
         Print("Points Max: " + GetDblStr(s_point_max));
         Print("Points AV: " + GetDblStr(s_point_av));
         
         
      }else{
         Print("Start: " + ha_statistic[i].Start);
         Print("End: " + ha_statistic[i].End);
         Print("Points: " + ha_statistic[i].Points);
         Print("Candls: " + ha_statistic[i].Candls);
         Print("Direction: " + ha_statistic[i].Direction);
      }
   }
   
   void TrendLoop(){
      for(int i = bars - 20; i >= 1; i--){
         DetectTrend(i);
      }
   }
   
   bool IsNewCandle()
   {
       static datetime lastTime = 0;
       datetime currentTime = iTime(_Symbol, period, 0);
       
       if (currentTime != lastTime)
       {
           lastTime = currentTime;
           return true;
       }
       return false;
   }
   
   void DataUpdate(){
      if(ArraySize(HA_Data) < 1)
         return;
      for(int i = 0;i < bars - 1;i++){
         HA_Data[i] = HA_Data[i+1];
      }
      CalculateHeikenAshi(1);
      DetectTrend(1);
      DrawPoints();
      Print("Update");
   }
   
   void DrawPoints(){
      int size = ArraySize(ha_moves);
      string name = "HA_Point_";
      for(int i = 0; i < size -1; i++){
         double price = ha_moves[i].MoveValue;
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         if(bid < price)
            Draw.Trendline(name + (i+1),price,ha_moves[i].MoveTime,clrFireBrick);
         else
            Draw.Trendline(name + (i+1),price,ha_moves[i].MoveTime,clrGreen);
         AddPoint(name + (i+1));
      }
   }
   
   void PrintPoints(){
      int size = ArraySize(ha_moves);
      for(int i = 0; i <= size -1;i++)
         if(StringFind(ha_moves[i].comment,"+") > 0)
            Print(ha_moves[i].Nr + " " + ha_moves[i].MoveTime + " " + ha_moves[i].MoveValue + " " + ha_moves[i].Direction + " " + ha_moves[i].comment);
   }
   
   void DeletePoints(){
      int size = ArraySize(Points);
      for(int i = 0; i <= size -1;i++)
         ObjectDelete(0,Points[i]);
   }
   
   void DetectTrend(int i){
      if(ArraySize(ha_moves) == 0)
         AddMove();
      if(ArraySize(ha_statistic) == 0)
         AddStatistic();
      
      ha_statistic[StPoint()].Candls++;
      if(Trend == 0){
         if(HA_Data[i].Direction == 1 && HA_Data[i+1].Direction == 1){
            Trend = 1;
            //AddMove();
            //AddStatistic();
            ha_low_value = HA_Data[i+1].Low;
            ha_low_time = HA_Data[i+1].Time;
            ha_moves[tpoint()].StartValue = HA_Data[i+1].Low;
            ha_moves[tpoint()].StartTime = HA_Data[i+1].Time;
            ha_statistic[StPoint()].Start = HA_Data[i+1].Time;
            ha_statistic[StPoint()].Direction = 1;
            ha_statistic[StPoint()].Start = HA_Data[i+2].Time;
            ha_statistic[StPoint()].Points = HA_Data[i].High - ha_low_value;

         }else if(HA_Data[i].Direction == -1 && HA_Data[i+1].Direction == -1){
            Trend = -1;
            //AddMove();
            //AddStatistic();
            ha_high_value = HA_Data[i+1].High;
            ha_high_time = HA_Data[i+1].Time;
            ha_moves[tpoint()].StartValue = HA_Data[i+1].High;
            ha_moves[tpoint()].StartTime = HA_Data[i+1].Time;
            ha_statistic[StPoint()].Start = HA_Data[i+1].Time;
            ha_statistic[StPoint()].Direction = -1;
            ha_statistic[StPoint()].Start = HA_Data[i+1].Time;
            ha_statistic[StPoint()].Points = HA_Data[i].Low - HA_Data[i+1].High;

         }else{
            ha_high_value = HA_Data[i].High;
            ha_low_value = HA_Data[i].Low;
            ha_high_time = HA_Data[i].Time;
            ha_low_time = HA_Data[i].Time;
         }
         if(Trend == 0) 
            return;
      }
         
      if(tpoint() > -1)
         ha_moves[tpoint()].Nr = tpoint()+1;
      
      if(Trend == 1){
         //neue Hochs
         //ha_statistic[StPoint()].Candls++;
         if(HA_Data[i].High > ha_high_value || ha_high_value == 0){
            ha_high_value = HA_Data[i].High;
            ha_high_time = HA_Data[i].Time;
            ha_moves[tpoint()].MoveValue = HA_Data[i].High;
            ha_moves[tpoint()].MoveTime = HA_Data[i].Time;
            ha_moves[tpoint()].Direction = 1;
            ha_moves[tpoint()].comment = "CandlIndex: " + i;
            ha_statistic[StPoint()].Direction = 1;
            ha_statistic[StPoint()].Points = ha_high_value - ha_low_value;
         }
         
         //Movewechsel
         if(HA_Data[i].Direction == -1 && HA_Data[i+1].Direction == -1){
            Trend = -1;
            ha_statistic[StPoint()].Candls--;
            AddMove();
            AddStatistic();
            ha_moves[tpoint()].Direction = -1;
            ha_statistic[StPoint()].Direction = -1;
            ha_statistic[StPoint()].Start = HA_Data[i+1].Time;
            ha_statistic[StPoint()-1].End = HA_Data[i+2].Time;
            if(HA_Data[i+1].Low < HA_Data[i].Low){
               ha_moves[tpoint()].MoveValue = HA_Data[i+1].Low;
               ha_moves[tpoint()].MoveTime = HA_Data[i+1].Time;
               ha_low_value = HA_Data[i+1].Low;
               ha_low_time = HA_Data[i+1].Time;
               ha_moves[tpoint()].comment = "CandlIndex: " + i + " +1";
            }else{
               ha_moves[tpoint()].MoveValue = HA_Data[i].Low;
               ha_moves[tpoint()].MoveTime = HA_Data[i].Time;
               ha_low_value = HA_Data[i].Low;
               ha_low_time = HA_Data[i].Time;
               ha_moves[tpoint()].comment = "CandlIndex: " + i + " +0";
            }
            return;
         }
      }
      
      if(Trend == -1){
         //Neue Tiefs
         //ha_statistic[StPoint()].Candls++;
         if(HA_Data[i].Low < ha_low_value || ha_low_value == 0){
            ha_low_value = HA_Data[i].Low;
            ha_low_time = HA_Data[i].Time;
            ha_moves[tpoint()].MoveValue = HA_Data[i].Low;
            ha_moves[tpoint()].MoveTime = HA_Data[i].Time;
            ha_moves[tpoint()].Direction = -1;
            ha_moves[tpoint()].comment = "CandlIndex: " + i;
            ha_statistic[StPoint()].Direction = -1;
            //ha_statistic[StPoint()].Points = ha_high_value - ha_low_value;
         }
         //Movewechsel
         if(HA_Data[i].Direction == 1 && HA_Data[i+1].Direction == 1){
            Trend = 1;
            ha_statistic[StPoint()].Candls--;
            AddMove();
            AddStatistic();
            ha_moves[tpoint()].Direction = 1;
            ha_statistic[StPoint()].Direction = 1;
            ha_statistic[StPoint()].Start = HA_Data[i+1].Time;
            ha_statistic[StPoint()-1].End = HA_Data[i+2].Time;
            ha_statistic[StPoint()-1].Points = ha_high_value - ha_low_value;
            
            if(HA_Data[i+1].High > HA_Data[i].High){
               ha_moves[tpoint()].MoveValue = HA_Data[i+1].High;
               ha_moves[tpoint()].MoveTime = HA_Data[i+1].Time;
               ha_high_value = HA_Data[i+1].High;
               ha_high_time = HA_Data[i+1].Time;
               ha_moves[tpoint()].comment = "CandlIndex: " + i + " +1";
            }else{
               ha_moves[tpoint()].MoveValue = HA_Data[i].High;
               ha_moves[tpoint()].MoveTime = HA_Data[i].Time;
               ha_high_value = HA_Data[i].High;
               ha_high_time = HA_Data[i].Time;
               ha_moves[tpoint()].comment = "CandlIndex: " + i + " +0";
            }
            return;
         }
      }
   }
};