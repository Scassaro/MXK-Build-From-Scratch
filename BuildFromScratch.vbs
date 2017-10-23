#$language = "VBScript"
#$interface = "1.0"

'This program is intended to speed up the initial configuration of a MXK system.
'Author: Stephen Cassaro
'Company: Dasan Zhone Solutions

'TODO: 1U support, maybe MALC LOL

crt.Screen.Synchronous = True

Sub Main
	
	'Login to the MXK System and create a connection to the network.
	LoginAndInitialize
	MsgBox("Your system is ready.")

End Sub

'Login to the MXK system using the default password.

Sub LoginAndInitialize

	'Login to the MXK system.
	'TODO: Allow custom login credentials
	
	crt.Screen.WaitForString "login: "
	crt.Screen.Send "admin" & chr(13)
	crt.Screen.WaitForString "password: "
	crt.Screen.Send "zhone" & chr(13)
	crt.Screen.WaitForString "zSH>"
	
	'Detemine MXK type to choose commands correctly.
	'TODO: Make this a three button system?
	
	Dim MXKType
	Do While MXKType <> "219" OR MXKType <> "MXK" OR MXKType <> "MXK-F"
		MXKType = InputBox("Is this a MXK, MXK-F, or a 219?", "MXK Type")
		If MXKType = "219" OR MXKType = "MXK" OR MXKType = "MXK-F" then
			Exit Do
		Else
			MsgBox("Error: Not a valid type of MXK system!")	
		End If
	Loop
	
	'Add all cards, as the 219 cannot be set up without at least one line card
	
	Call AddCards(MXKType)
	
	'Determine Linkagg status, and create Linkagg if needed, otherwise create the uplink.
	'TODO: Non-linkagg system support
	
	Dim LinkaggBool
	LinkaggBool = MsgBox("Will this be a Linkagged device?", vbYesNo, "Linkagg Status")
	If LinkaggBool = 6 Then
		Call CreateLinkagg(MXKType, LinkaggBool)
	Else
		Call BuildUplink(MXKType, LinkaggBool)
	End If

End Sub

'Adds all cards, depending on the type of system.

Sub AddCards(ByVal MXKType)
	
	'Still rudimentary, just goes in and randomly adds all cards whether they are present or not.
	
	Dim CardNum
	CardNum = 0
	If MXKType = "MXK" Then
		crt.Screen.Send "card add b"
		Do While CardNum < 18
			crt.Screen.Send "card add " & CardNum & chr(13)
			crt.Screen.WaitForString "zSH>"
			CardNum = CardNum + 1
		Loop
	ElseIf MXKType = "MXK-F" Then
		crt.Screen.Send "card add m2 group 1" & chr(13)
		crt.Screen.WaitForString "zSH>"
		crt.Screen.Send "card add a group 2" & chr(13)
		crt.Screen.WaitForString "zSH>"
		crt.Screen.Send "card add b group 2" & chr(13)
		crt.Screen.WaitForString "zSH>"
		Do While CardNum < 16
			crt.Screen.Send "card add " & CardNum & chr(13)
			crt.Screen.WaitForString "zSH>"
			CardNum = CardNum + 1
		Loop
		crt.Screen.WaitForString "Card in slot a is traffic ready."
	Else
		crt.Screen.Send "card add m2 group 1" & chr(13)
		crt.Screen.WaitForString "zSH>"
		crt.Screen.Send "card add 1 group 2" & chr(13)
		crt.Screen.WaitForString "zSH>"
		crt.Screen.Send "card add 2 group 2" & chr(13)
		crt.Screen.WaitForString "Card in slot 1 is traffic ready."
	End If

End Sub

'Build Link Aggregation and call BuildUplink to connect the MXK to the network.

Sub CreateLinkagg(ByVal MXKType, ByVal LinkaggBool)

	'Different Link Aggregation configurations must be used depending on the type of MXK system.
	'This function will build the Link Aggregation groups based on our input parameter, "MXKType".
	'TODO: Allow different ports to be used
	
	If MXKType = "MXK" Then
		crt.Screen.Send "linkagg add group one/linkagg link 1-a-2-0/eth mode active" & chr(13)
	ElseIf MXKType = "MXK-F" Then
		crt.Screen.Send "linkagg add group one/linkagg link 1-a-3-0/eth mode active" & chr(13)
	Else
		crt.Screen.Send "linkagg add group one/linkagg link 1-1-101-0/eth mode active" & chr(13)
	crt.Screen.WaitForString "zSH>"
	End If
	Call BuildUplink(MXKType, LinkaggBool)

End Sub

'Build the uplink bridge to the network.
'TODO: Allow asymmetric ipobridges, allow different uplink ports to be used

Sub BuildUplink(ByVal MXKType, ByVal LinkaggBool)

	'Determine which In-Band Management Vlan will be used and build the uplink for the IPOBridge.
	
	Dim ChosenVlan
	ChosenVlan = InputBox("What VLAN do you want your IPOBridge on?", "In-Band Management VLAN")
	If LinkaggBool = 6 Then
		crt.Screen.Send "bridge add one/linkagg tls vlan " & ChosenVlan & " tagged" & chr(13)
	Else
		If(MXKType = "MXK") Then
			crt.Screen.Send "bridge add 1-a-2-0/eth tls vlan " & ChosenVlan & " tagged" & chr(13)
		ElseIf(MXKType = "MXK-F") Then
			crt.Screen.Send "bridge add 1-a-3-0/eth tls vlan " & ChosenVlan & " tagged" & chr(13)
		Else
			crt.Screen.Send "bridge add 1-1-101-0/eth tls vlan " & ChosenVlan & " tagged" & chr(13)
		End If
	End If
	crt.Screen.WaitForString "zSH>"
	Call CreateRouting(MXKType, ChosenVlan)

End Sub
	
Sub CreateRouting(ByVal MXKType, ByVal ChosenVlan)

	'Determine IP Address the user wants to use and build the ipobridge interface.
	'TODO: Support custom subnet (needed?)
	
	Dim ChosenIPAddress
	ChosenIPAddress = InputBox("What IP Address do you want for this MXK?", "IP Address")
	If MXKType = "MXK" Then
		crt.Screen.Send "interface add 1-a-6-0/ipobridge vlan " & ChosenVlan & " " & ChosenIPAddress & "/24" & chr(13)
	Else
		crt.Screen.Send "interface add 1-m1-6-0/ipobridge vlan " & ChosenVlan & " " & ChosenIPAddress & "/24" & chr(13)
	End If
	crt.Screen.WaitForString "zSH>"
	
	'Parse IP Address to determine Default Route.
	
	'Create Array to hold IP bytes.
	
	Dim IPArray
	
	'Split into byte sized pieces :).
	
	IPArray = Split(ChosenIPAddress, ".")
	
	'Reassemble IP Address and append "254" to create the Default Route.
	
	crt.Screen.Send "route add default " & IPArray(0) & "." & IPArray(1) & "." & IPArray(2) & ".254 1" & chr(13)
	crt.Screen.WaitForString "zSH>"
	
End Sub