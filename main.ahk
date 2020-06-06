#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

;定数
WAITTIME_EACH_STROKE := 64
SETTING_FILE_PATH := "setting.dat"

#Include SerDes.ahk
#Include ocr.ahk
#Include ff14commandparser.ahk

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


DumpArray(obj){
   text := SerDes(obj)
   msgbox %text%
   Return
}
