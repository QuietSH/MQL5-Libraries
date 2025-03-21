//+------------------------------------------------------------------+
//|                                                          RSI.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

//Benötigt die StringClass, die relevanten Stellen werden markiert.

input group "RSI Settings";
input double AlertLongValue = 35;
input double AlertShortValue = 65;
input bool AlertMiddle = true;
input group " ";

class RSI{
   private:
      int handle;
      double buffer[1];
      int ma_period;
      ENUM_APPLIED_PRICE applied_price;
      ENUM_TIMEFRAMES tf;
      double longalertvalue, shortalertvalue; //Triggerwerte
      bool alert_long, alert_short; //Alert für Long und Short
      bool trigger_long, trigger_short, trigger_middle; //Trigger ausgelöst
      bool permaalert;
      
      string name;
      ENUM_BORDER_TYPE btype;
      int fntsize;
      
   public:
      
      void Init(ENUM_TIMEFRAMES TF = PERIOD_CURRENT, ENUM_APPLIED_PRICE AP = PRICE_CLOSE, int Periode = 12){
         ma_period = Periode;
         applied_price = AP;
         tf = TF;
         fntsize = 10;
         if(TF == 0)
            name = "Default";
         else
            name = TF_To_Str(TF);
         handle = iRSI(_Symbol,tf,ma_period,applied_price);
         CopyBuffer(handle,0,0,1,buffer);
      }
      
      //void Init(ENUM_TIMEFRAMES TF, ENUM_APPLIED_PRICE AP = PRICE_CLOSE, int Periode = 12){
      //   ma_period = Periode;
      //   applied_price = AP;
      //   tf = TF;
      //   name = TF;
      //   fntsize = 10;
      //   handle = iRSI(_Symbol,tf,ma_period,applied_price);
      //   CopyBuffer(handle,0,0,1,buffer);
      //}
      
      //Schaltet den die Alarme an oder aus, defaultwerte für beide ist true wenn
      //SetAlert(); ausgeführt wird
      void SetAlert(bool along = true, bool ashort = true){
         alert_long = along;
         alert_short = ashort;
      }
            
      //Setzt den Alarm permanent
      void SetPermaAlert(bool alert){
         permaalert = alert;
      }
      
      //***************************************
      // Gibt die Zustände der einzelnen Trigger wieder
      bool GetLongTrigger(){
         return trigger_long;
      }
      
      bool GetShortTrigger(){
         return trigger_short;
      }
      
      //***************************************
      
      //***************************************
      //Setzt die Zustände der einzelnen Trigger
      void SetLongTrigger(bool toggle){
         trigger_long = toggle;
      }
      
      void SetShortTrigger(bool toggle){
         trigger_short = toggle;
      }
      
      //***************************************
      
      //Gibt den aktuellen RSIValue zurück
      double Value(){
         return buffer[0];
      }
      
      //Wandelt den RSIValue in einen String um mit zwei Stellen nach dem Kommata
      string StrValue(){
         return DoubleToString(Value(),2);
      }
      
      //Schreibt den RSIValue in die Console
      void PrintValue(){
         Print(DoubleToString(Value(),2));
      }
      
      void SetTextColor(color Color){
         ObjectSetInteger(0,"lbl_RSI_" + name,OBJPROP_COLOR,Color);
      }
      
      void SetValueColor(color Color){
         ObjectSetInteger(0,"lbl_RSI_" + name + "_Value",OBJPROP_COLOR,Color);
      }
      
      void SetFontSize(int Size){
         fntsize = Size;
         ObjectSetInteger(NULL,"lbl_RSI_" + name,OBJPROP_FONTSIZE,fntsize);
         ObjectSetInteger(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_FONTSIZE,fntsize);
      }
      
      void DrawUI(int X, int Y){         
         //Erstellt RSI Label und RSI ValueLabel
         if(!ObjectCreate(NULL,"lbl_RSI_" + name,OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,"lbl_RSI_" + name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,"lbl_RSI_" + name,OBJPROP_XDISTANCE,X - 2);
         ObjectSetInteger(NULL,"lbl_RSI_" + name,OBJPROP_YDISTANCE,Y + 2);
         ObjectSetInteger(NULL,"lbl_RSI_" + name,OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,"lbl_RSI_" + name,OBJPROP_TEXT,"RSI " + TF_To_Str(tf));
         ObjectSetInteger(NULL,"lbl_RSI_" + name,OBJPROP_ZORDER,1);
         
         if(!ObjectCreate(NULL,"lbl_RSI_" + name + "_Value",OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_XDISTANCE,X - 75);
         ObjectSetInteger(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_YDISTANCE,Y + 2);
         ObjectSetInteger(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_FONTSIZE,fntsize);
         ObjectSetString(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_TEXT," ");
         ObjectSetInteger(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_ZORDER,1);
      }
      
      void DeInit(){
         ObjectDelete(NULL,"lbl_RSI_" + name);
         ObjectDelete(NULL,"lbl_RSI_" + name + "_Value");
      }
      
      //Function zum Alarmmanagement
      void AlertHandle(){
         //Wenn Alert aus, dann return
         if(!alert_long && !alert_short)
            return;
            
         //Wenn LongAlert aktiv und Trigger nicht ausgelöst wurde und
         //RSIValue kleiner als longalertvalue dann
         //Löse Alarm aus und setze den Trigger als ausgelöst
         if(alert_long && !trigger_long && Value() <= AlertLongValue){
            //************* Benotigt die StringClass ******************
            Alert(_Symbol + " " + GetTime() + " RSI Long: " + StrValue());
            if(!permaalert)
               trigger_long = !trigger_long;
         }
         
         //Wenn ShortAlert aktiv und Trigger nicht ausgelöst wurde und
         //RSIValue größer als shortalertvalue dann
         //Löse Alarm aus und setze den Trigger als ausgelöst
         if(alert_short && !trigger_short && Value() >= AlertShortValue){
            //************* Benotigt die StringClass ******************
            Alert(_Symbol + " " + GetTime() + " RSI Short: " + StrValue());
            if(!permaalert)
               trigger_short = !trigger_short;
         }
         
         //Short
         //Wenn RSIValue kleiner als 50 und der Trigger ausgelöst wurde, dann wird der Trigger zurückgesetzt
         if(Value() <= 50 && trigger_short)
            trigger_short = !trigger_short;
         
         //Long
         //Wenn RSIValue größer als 50 und der Trigger ausgelöst wurde, dann wird der Trigger zurückgesetzt   
         if(Value() >= 50 && trigger_long)
            trigger_long = !trigger_long;
      }
      
      void ColoredValue(){
         if(Value() <= AlertLongValue)
            SetValueColor(clrLimeGreen);
         else if(Value() >= AlertShortValue)
            SetValueColor(clrMaroon);
         else
            SetValueColor(clrBlack);
      }
      
      //***********************************************************************
      //  Entweder OnTimer() oder OnTick() benutzen, nicht beide Funktionen
      //***********************************************************************
      
      //Function kommt in einem EA in die OnTimerFunction
      //expl: rsi.OnTimer();
      //Handle wird gesetzt und in ein Array übertragen um so den Value des RSI auslesen zu können
      void OnTimer(bool ColorValue = true){
         handle = iRSI(_Symbol,tf,ma_period,applied_price);
         CopyBuffer(handle,0,0,1,buffer);
         
         if(ObjectFind(NULL,"lbl_RSI_" + name + "_Value") == 0){
            if(ColorValue){
               ColoredValue();
            }
            ObjectSetString(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_TEXT,StrValue());
         }
      }
      
      //Function kommt in einem EA in die OnTickFunction
      //expl: rsi.OnTick();
      //Handle wird gesetzt und in ein Array übertragen um so den Value des RSI auslesen zu können
      void OnTick(bool ColorValue = true){
         handle = iRSI(_Symbol,tf,ma_period,applied_price);
         CopyBuffer(handle,0,0,1,buffer);
         
         if(ObjectFind(NULL,"lbl_RSI_" + name + "_Value") == 0){
            if(ColorValue){
               ColoredValue();
            }
            ObjectSetString(NULL,"lbl_RSI_" + name + "_Value",OBJPROP_TEXT,StrValue());
         }
      }
      
};