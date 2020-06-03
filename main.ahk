#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

;クラフターの品質と工数の数値をスクリーン座標で指定する
CRAFTER_WORK_POS_X := 1020
CRAFTER_WORK_POS_Y := 400
CRAFTER_WORK_WIDTH := 150
CRAFTER_WORK_HEIGHT := 200

;定数
WAITTIME_EACH_STROKE := 34

#Include SerDes.ahk
#Include ocr.ahk

parser := new FF14CommandParser()

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
/acifnw 模範作業
/acifnw 模範作業
/acifnw 模範作業
/acifnw 模範作業
/echo 完成!!
)
   parser.ExecuteMarco(macro)
   Return

^D::
   result := parser.GetCrafterStatus()
   DumpArray(result)
   Return

Esc::
   ;ゲームにも送る
   ControlSend, ,{esc} ,ahk_class FFXIVGAME
   Reload

class FF14CommandParser
{
   ExecuteMarco(script){
      Sleep 100  ;特殊キーが混じることがあるので待機
      IfWinNotActive ,ahk_class FFXIVGAME ;ff14がアクティブな時以外は実行しない
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
      SoundPlay,*64
      Return
   }

   SendText(text)
   {
      global WAITTIME_EACH_STROKE
      loop, parse, text
      {
         ControlSendRaw, ,%A_LoopField% ,ahk_class FFXIVGAME
         Sleep WAITTIME_EACH_STROKE
      }
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

   GetCrafterStatus(){
      global CRAFTER_WORK_POS_X, CRAFTER_WORK_POS_Y, CRAFTER_WORK_WIDTH, CRAFTER_WORK_HEIGHT
      WinGet, hWnd, ID, ahk_class FFXIVGAME
      hBitmap := HBitmapFromHwnd(hWnd, CRAFTER_WORK_POS_X, CRAFTER_WORK_POS_Y, CRAFTER_WORK_WIDTH, CRAFTER_WORK_HEIGHT)
      pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
      DllCall("DeleteObject", "Ptr", hBitmap)
      list := ocr(pIRandomAccessStream, "en")
      result := Object()
      result.Insert("workload", this.ParseProgress(list[1]))
      result.Insert("quality", this.ParseProgress(list[2]))
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
