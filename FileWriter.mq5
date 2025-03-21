//+------------------------------------------------------------------+
//|                                                   FileWriter.mq5 |
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
class FileWriter {
private:
   string fileName;
   int fileHandle;

public:
   void Init(string _fileName) {
      fileName = _fileName;
      fileHandle = INVALID_HANDLE;
   }

   bool FileCreate(){
      if(FileIsExist(fileName))
         return false;
      int fileHandle = FileOpen(fileName, FILE_WRITE | FILE_READ | FILE_TXT);
      if (fileHandle == INVALID_HANDLE) {
          Print(GetError(fileHandle));
      } else {
          // Wenn die Datei erfolgreich geöffnet wurde, schreibe etwas hinein
          FileWriteString(fileHandle, "");
          // Schließe die Datei nach dem Schreiben
          FileClose(fileHandle);
          Print("Die Datei wurde erfolgreich erstellt.");
      }
      return true;
   }
   
   bool Append(string text) {
      fileHandle = FileOpen(fileName, FILE_READ|FILE_WRITE|FILE_TXT);
         if (fileHandle <= 0) { 
         Print(GetError(fileHandle));
      }
      if ( fileHandle > 0 ) {
         FileSeek(fileHandle,0,SEEK_END);
         FileWrite(fileHandle, text);
         FileFlush(fileHandle);
      }
      FileClose(fileHandle);
      return true;
   }
};