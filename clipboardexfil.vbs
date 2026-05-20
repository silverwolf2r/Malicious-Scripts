Option Explicit

Dim http, url, dataObj
Dim clipboardText, postData
Dim fso

url = "https://your-url-here.com"

Function UrlEncode(str)
    Dim i, charCode, char, result
    result = ""

    For i = 1 To Len(str)
        char = Mid(str, i, 1)
        charCode = Asc(char)

        Select Case charCode
            Case 48 To 57, 65 To 90, 97 To 122
                result = result & char
            Case 32
                result = result & "+"
            Case Else
                result = result & "%" & Right("0" & Hex(charCode), 2)
        End Select
    Next

    UrlEncode = result
End Function

On Error Resume Next

'-----------------------------
' Get clipboard text
'-----------------------------
Do
Set dataObj = CreateObject("MSForms.DataObject")

If Err.Number <> 0 Then
    WScript.Echo "Failed to create MSForms.DataObject. Error: " & Err.Description
    WScript.Quit 1
End If

dataObj.GetFromClipboard
clipboardText = dataObj.GetText

If Err.Number <> 0 Then
    WScript.Echo "Failed to read clipboard. Error: " & Err.Description
    WScript.Quit 1
End If

If Len(clipboardText) = 0 Then
    WScript.Echo "Clipboard is empty."
    WScript.Quit 0
End If

'-----------------------------
' Build POST data (properly encoded)
'-----------------------------
postData = "clip=" & UrlEncode(clipboardText)

'-----------------------------
' Create HTTP object
'-----------------------------
Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")

If Err.Number <> 0 Then
    WScript.Echo "Failed to create HTTP object. Error: " & Err.Description
    WScript.Quit 1
End If

'-----------------------------
' Send request
'-----------------------------
http.Open "POST", url, False
http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
http.setRequestHeader "User-Agent", "VBScript-Client"

http.Send postData

'-----------------------------
' Check response
'-----------------------------
If Err.Number <> 0 Then
    WScript.Echo "HTTP request failed. Error: " & Err.Description
    WScript.Quit 1
End If

If http.Status >= 200 And http.Status < 300 Then
    WScript.Echo "Success. Server response:"
    WScript.Echo http.ResponseText
Else
    WScript.Echo "Request failed. HTTP Status: " & http.Status
    WScript.Echo http.ResponseText
End If

On Error GoTo 0

WScript.Sleep 500  ' check every 0.5 second
Loop