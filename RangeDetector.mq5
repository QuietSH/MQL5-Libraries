//+------------------------------------------------------------------+
//|                                          DaylieRangeDetector.mq5 |
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

struct Range{
   double High;
   double Low;
   datetime StartDate;
   datetime EndDate;
   int Duration;
   int No;
};

class RangeClassifier
{
private:
    ENUM_TIMEFRAMES tf;
    string name;
    int bars;
    datetime nextUpdate;
    Range Ranges[];
    datetime rangeStartDate;
    double rangeHigh;
    double rangeLow;
    int rangeStartIndex;
    int rangeDays;
    bool isValidRange;
    bool isInit;
    int width;
    color clr;
    string RangeLines[];
    
    void AddRange(){
      int size = ArraySize(Ranges);
      ArrayResize(Ranges,size + 1);
      Ranges[size].High = 0.0;
      Ranges[size].Low = 0.0;
      Ranges[size].StartDate = -1;
      Ranges[size].EndDate = -1;
      Ranges[size].Duration = 1;
      Ranges[size].No = size + 1;
    }
    
    void AddRangeLine(string HighName, string LowName){
      int size = ArraySize(RangeLines);
      ArrayResize(RangeLines,size + 2);
      RangeLines[size + 1] = HighName;
      RangeLines[size] = LowName;
    }
    
    int RangeP(){
      return ArraySize(Ranges) - 1;
    }

public:
    RangeClassifier() : rangeHigh(0), rangeLow(0), rangeStartIndex(-1), rangeDays(1), isValidRange(false),isInit(false), rangeStartDate(-1), nextUpdate(-1) {}
    void Init(ENUM_TIMEFRAMES TF, string Name, color LineColor, int LineWidth, int Candls){
      tf = TF; name = Name; clr = LineColor; width = LineWidth; bars = Candls;
      isInit = true;
    }
    
    void InitRange(){
      if(nextUpdate == -1 || nextUpdate < TimeCurrent()){
         CheckRange();
         DrawRange(0);
         nextUpdate = TimeCurrent() + TimeframeToSeconds(tf);
         Print(name + " RangeFinder Next Update: " + GetDateTime(nextUpdate));
      }
    }
    void CheckRange() {
        isValidRange = false; // Reset the flag before each scan
        if(!isInit){Print("Class not initialized");return;}
        Print("Starting range scan...");
            
        for (int i = bars + 1; i >= 1; i--) {
            double high = iHigh(Symbol(), tf, i);
            double low = iLow(Symbol(), tf, i);
            double open = iOpen(Symbol(), tf, i);
            double close = iClose(Symbol(), tf, i);
            double highBefore = iHigh(Symbol(), tf, i+1);
            double lowBefore = iLow(Symbol(), tf, i+1);
            
            if((close < highBefore && close > lowBefore && open > lowBefore && open < highBefore) ||
               (close < rangeHigh && close > rangeLow && open > rangeLow && open < rangeHigh)){
               
               if(ArraySize(Ranges) == 0)
                  AddRange();
               Ranges[RangeP()].Duration++;
               
               if(rangeHigh == 0.0){
                  rangeHigh = fmax(high,highBefore);
                  rangeLow = fmin(low,lowBefore);
                  Ranges[RangeP()].High = fmax(high,highBefore);
                  Ranges[RangeP()].Low = fmin(low,lowBefore);
                  Ranges[RangeP()].StartDate = iTime(Symbol(), tf, i+1);
               }else{
                  rangeHigh = fmax(rangeHigh,fmax(high,highBefore));
                  rangeLow = fmin(rangeLow,fmin(low,lowBefore));
                  Ranges[RangeP()].High = fmax(rangeHigh,fmax(high,highBefore));
                  Ranges[RangeP()].Low = fmin(rangeLow,fmin(low,lowBefore));
               }

               if(Ranges[RangeP()].Duration >= 3)
                  isValidRange = true;
               
            }else{
               if(isValidRange == true){
                  Ranges[RangeP()].EndDate = iTime(Symbol(), tf, i);
                  AddRange();
                  isValidRange = false;
               }
               rangeDays = 1;
               rangeStartDate = -1;
               rangeHigh = 0.0;
               rangeLow = 0.0;
            }
        }
        ArrayReverse(Ranges);
        Print("Range scan complete ...");
    }
    
    void PrintRange(int idx = -1){
      if(!isInit){Print("Class not initialized");return;}
      int s = ArraySize(Ranges);
      Print(s);
      if(idx == -1){
         Print("Valid Ranges:");
         for(int i = s-1; i >= 0;i--){
            string date;
            if(Ranges[i].EndDate == -1)
               date = "til now";
            else
               date = GetDateTime(Ranges[i].EndDate);
            Print("Date: " + GetDateTime(Ranges[i].StartDate) + " - " + date);
            Print("Low: ["+ Ranges[i].Low + "] High: [" + Ranges[i].High + "]");
            Print("Duration: " + Ranges[i].Duration);
         }
      }else if(idx >= 0 && idx <= s - 1){
      
      }
    }
    
    void DrawRange(int idx){
      if(!isInit){Print("Class not initialized");return;}
      string h = name + "_Range_" + idx + "_High", l = name + "_Range_" + idx + "_Low";
      AddRangeLine(h,l);
      Draw.Trendline(h,Ranges[idx].High,Ranges[idx].StartDate,clr,width);
      Draw.Trendline(l,Ranges[idx].Low,Ranges[idx].StartDate,clr,width);
    }
    
    void DeleteDraw(){
      for(int i = 0; i <= ArraySize(RangeLines) -1; i++){
         ObjectDelete(NULL,RangeLines[i]);
      }
    }

    datetime GetRangeStartDate() const { return rangeStartDate; }
    bool IsValidRange() const { return isValidRange; }
    double GetRangeHigh() const { return rangeHigh; }
    double GetRangeLow() const { return rangeLow; }
};
