#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

;定数
WAITTIME_EACH_STROKE := 64
SETTING_FILE_PATH := "setting.dat"

#Include SerDes.ahk
#Include ocr.ahk

try{
   setting := SerDes(SETTING_FILE_PATH)
}Catch e{
   msgbox, You have to press Ctrl+T
   setting := {"x": 1020, "y":400, "w":150, "h":200}
}
parser := new FF14CommandParser(setting)

+N::
   macro=
(
/ac 真価
/ac マニピュレーション
/ac イノベーション
/acifnq 倹約加工
/acifnq 倹約加工
/acifnq 倹約加工
/acifnq 倹約加工
/acifnq グレートストライド
/acifnq ビエルゴの祝福
/ac ヴェネレーション
/acifnw 模範作業
/acifnw 模範作業
/acifnw 模範作業
/acifnw 模範作業
/echo 完成!! <se.3>
)
   parser.ExecuteMarco(macro)
   Return

^D::
   result := parser.GetCrafterStatus()
   DumpArray(result)
   Return

^T::
   global SETTING_FILE_PATH
   rect := GetArea()
   list := parser.OcrCrafterStatus(rect.x, rect.y, rect.w, rect.h)
   text := "It got crafter status. Please reload. If you feel bad, you can change anytime."
   dumped := SerDes(list)
   msgbox %text%`n%dumped%
   SerDes(rect, SETTING_FILE_PATH)
   Return

Esc::
   ;ゲームにも送る
   ControlSend, ,{esc} ,ahk_class FFXIVGAME
   Reload

class FF14CommandParser
{
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
      global WAITTIME_EACH_STROKE
      ControlSend, ,{Enter} ,ahk_class FFXIVGAME
      Sleep WAITTIME_EACH_STROKE
      ControlSend, ,{Text}%text% ,ahk_class FFXIVGAME
      Sleep WAITTIME_EACH_STROKE
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

DumpArray(obj){
   text := SerDes(obj)
   msgbox %text%
   Return
}
