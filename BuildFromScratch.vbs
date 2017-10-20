#$language = "VBScript"
#$interface = "1.0"

'This program is intended to speed up the initial configuration of a MXK system.
'Author: Stephen Cassaro
'Company: Dasan Zhone Solutions

crt.Screen.Synchronous = True

Sub Main
	
	'Detemine MXK type to choose commands correctly
	Dim MXKType
	Do While MXKType <> "219" OR MXKType <> "MXK" OR MXKType <> "MXK-F"
	MXKType = InputBox("Is this a MXK, MXK-F, or a 219?", "MXK Type")
	If MXKType = "219" OR MXKType = "MXK" OR MXKType = "MXK-F" then
		Exit Do
	Else
		MsgBox("Error: Not a valid type of MXK system!")	
	End If
	Loop
	
	' Determine Linkagg status
	Dim Linkagg
	Linkagg = MsgBox("Will this be a Linkagged device?", vbYesNo, "Linkagg Status")
	
	
	strNumber = Wscript.StdIn.ReadLine
	ipaddress = UserInput ("What IP Address would you like for this MXK?")
	crt.Screen.Send "admin" & chr(13)
	crt.Screen.Send "zhone" & chr(13)
	crt.Screen.WaitForString "zSH>"
	crt.Screen.Send "bridge add 1-a-2-0/eth tls vlan 3502 tagged"
	crt.Screen.WaitForString "zSH>"
	'crt.Screen.Send "interface add

End Sub

Sub DetermineParameters
	
	

End Sub