//+------------------------------------------------------------------+
//|                                                     UEWindow.mq5 |
//|                                                            Quiet |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Quiet"
#property link      "https://www.mql5.com"
#property version   "1.00"

class UIWindow{
   private:
      string name;
      int x,y,width,height;
      ENUM_BORDER_TYPE btype;
      bool hide;
      
      void Create(){
         if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
            return;
            
         SetBorderType();
         ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
         ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
         ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
         ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
      }
   public:
      UIWindow(){}
      UIWindow(string Name, int X, int Y, int Width, int Height){
         name = Name; x = X; y = Y; width = Width; height = Height;
         Create();
         Hide();
      }
      
      void UIWindow(string Name, int X, int Y, int Width, int Height, bool hidden){
         name = Name; x = X; y = Y; width = Width; height = Height;hide = hidden;
         Create();
         Hide(hide);
      }
      
      void Init(){
         Create();
         Hide(hide);
      }
      
      void Init(string Name, int X, int Y, int Width, int Height){
         name = Name; x = X; y = Y; width = Width; height = Height;
         Create();
         Hide();
      }
      
      void SetBorderType(ENUM_BORDER_TYPE BType = BORDER_FLAT){
         btype = BType;
         ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,btype);
      }
      
      void Hide(bool toggle = true){
         hide = toggle;
         ObjectSetInteger(0,name,OBJPROP_HIDDEN,hide);
      }
      
      void DeInit(){
         ObjectDelete(0,name);
      }
};