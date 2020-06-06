class FF14CommandParser
{
   WAITTIME_EACH_STROKE := 64
   __New(param){
      this.crafter_pos := param
   }
   ExecuteMarco(script){
      Sleep 100  ;特殊キーが混じることがあるので待機
      IfWinNotActive ,ahk_class FFXIVGAME ;ff14がアクティブな時以外は実行しない
      {
         return
      }
      status := this.GetCrafterStatus()
      if(status.making == 0)
      {
         return
      }
      loop, parse, script, "`n"
      {
         cmd := this.ParseCommand(A_LoopField)
         if(cmd == "")
            continue
         this.SendText(cmd)
         ControlSend, ,{Enter} ,ahk_class FFXIVGAME
         Sleep 3000
      }
      Return
   }

   SendText(text)
   {
      ControlSend, ,{Enter} ,ahk_class FFXIVGAME
      Sleep this.WAITTIME_EACH_STROKE
      ControlSend, ,{Text}%text% ,ahk_class FFXIVGAME
      Sleep this.WAITTIME_EACH_STROKE
   }

   ParseCommand(cmd){
      token := StrSplit(cmd," ")
      status := this.GetCrafterStatus()
      output := cmd
      Switch token[1]
      {
        case "/acifnq":
          if(status.quality.now < status.quality.max)
            output := "/ac" + " " + token[2]
          else
            output := "/echo skip-" + token[2]
        case "/acifnw":
          if(status.workload.now < status.workload.max)
            output := "/ac" + " " + token[2]
          else
            output := "/echo skip-" + token[2]
      }
      return output
   }

   OcrCrafterStatus(X,Y,W,H){
      WinGet, hWnd, ID, ahk_class FFXIVGAME
      hBitmap := HBitmapFromHwnd(hWnd, X, Y, W, H)
      pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
      DllCall("DeleteObject", "Ptr", hBitmap)
      list := ocr(pIRandomAccessStream, "en")
      return list
   }

   GetCrafterStatus(){
      list := this.OcrCrafterStatus(this.crafter_pos.x, this.crafter_pos.y, this.crafter_pos.w, this.crafter_pos.h)
      result := Object()
      result.Insert("workload", this.ParseProgress(list[1]))
      result.Insert("quality", this.ParseProgress(list[2]))
      result.Insert("making", result.workload.now != "" && result.workload.max != "" && result.quality.now != "" && result.quality.max != "")
      return result
   }

   ParseProgress(str){
      token := StrSplit(str,"/")
      list := Object()
      list.Insert("now", token[1] + 0)  ;数値に変換する
      list.Insert("max", token[2] + 0)  ;数値に変換する
      Return list
   }

}
