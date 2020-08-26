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
         this.SendText(cmd["output"])
         ControlSend, ,{Enter} ,ahk_class FFXIVGAME
         if(cmd["skip"] == true)
           Sleep 16
         else
           Sleep cmd["wait"]
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
      ;/ac 加工 か /ac 加工 <wait.3>にマッチするかどうか
      ;token、token1から3に対応するグループが入る
      result := RegExMatch(cmd, "(\/[a-z]+)\s(\S+)\s?<?([a-z]+)?\.?([0-9]+)?>?", token)
      if(result == 0)
          return Object("output","/echo syntax error","wait", 0)
      status := this.GetCrafterStatus()
      output := cmd
      Switch token1
      {
        case "/acifnq":
          if(status.quality.now < status.quality.max)
            output := "/ac" + " " + token2
          else
            output := ""
        case "/acifnw":
          if(status.workload.now < status.workload.max)
            output := "/ac" + " " + token2
          else
            output := ""
        case "/ac":
          output := "/ac" + " " + token2
      }

      wait := 0
      if(token3 == "wait" && token4 != "")
      {
          wait := token4 * 1000
      }

      skipflag := false
      if(output == "")
      {
          output := "/echo skipped"
          skipflag := true
      }

      return Object("output",output,"wait", wait, "skip", skipflag)
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
