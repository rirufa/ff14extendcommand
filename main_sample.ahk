#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

#Include view.ahk

view := new View()

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
   if(view.ExecuteMacro(macro) == false)
   {
      msgbox %A_ThisHotkey%
   }
   Return

^D::
   view.CheckStatus()
   Return

^T::
   view.InitSetting()
   Return

Esc::
   ;ゲームにも送る
   ControlSend, ,{esc} ,ahk_class FFXIVGAME
   Reload

