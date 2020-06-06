#Include SerDes.ahk
#Include ocr.ahk
#Include ff14commandparser.ahk

class view{
   SETTING_FILE_PATH := "setting.dat"

   __New(){
      try{
         setting := SerDes(this.SETTING_FILE_PATH)
      }Catch e{
         msgbox, You have to press Ctrl+T
         setting := {"x": 1020, "y":400, "w":150, "h":200}
      }
      this.parser := new FF14CommandParser(setting)
   }

   ExecuteMacro(s){
      this.parser.ExecuteMarco(s)
      Return
   }

   CheckStatus(){
      result := this.parser.GetCrafterStatus()
      DumpArray(result)
      Return
   }

   InitSetting(){
      rect := GetArea()
      list := this.parser.OcrCrafterStatus(rect.x, rect.y, rect.w, rect.h)
      text := "It got crafter status. Please reload. If you feel bad, you can change anytime."
      dumped := SerDes(list)
      msgbox %text%`n%dumped%
      SerDes(rect, this.SETTING_FILE_PATH)
   }
}

DumpArray(obj){
   text := SerDes(obj)
   msgbox %text%
   Return
}
