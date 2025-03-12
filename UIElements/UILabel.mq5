//+------------------------------------------------------------------+
//|                                                      UILabel.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

class UILabel{
   private:
      string name;
      int x, y, width, height, fntsize;
      
      void Create(){
         if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
            return;
         ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fntsize);
         ObjectSetInteger(0,name,OBJPROP_ZORDER,1);
         ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
      }
   public:
      UILabel(){}
      UILabel(string Name, int X, int Y, int FntSize = 10){
         name = Name; x = X; y = Y; fntsize = FntSize;
         Create();
      }
      
      void Init(string Name, int X, int Y, int FntSize = 10){
         name = Name; x = X; y = Y; fntsize = FntSize;
         Create();
      }
      
      void Init(){
         Create();
      }
      
      void SetSize(int Width, int Height){
         height = Height; width = Width;
         ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
         ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      }
      
      void SetText(string txt){
         ObjectSetString(0,name,OBJPROP_TEXT,txt);
      }
      
      void SetTextColor(color Color){
         ObjectSetInteger(0,name,OBJPROP_COLOR,Color);
      }
      
      void SetFontSize(int size){
         fntsize = size;
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fntsize);
      }
      
      void DeInit(){
         ObjectDelete(0,name);
      }
}