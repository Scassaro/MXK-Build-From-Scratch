#$language = "VBScript"
#$interface = "1.0"

crt.Screen.Synchronous = True

Sub Main

	crt.Screen.Send "admin" & chr(13)
	crt.Screen.Send "zhone" & chr(13)
	crt.Screen.WaitforString "zSH>"
	crt.Screen.Send

End Sub