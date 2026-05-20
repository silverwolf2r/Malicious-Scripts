#run on idle
# Function to retrieve system sleep timeout settings
function Get-SleepTimeout {
    $powerConfigOutput = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE
    $sleepTimeoutValue = $powerConfigOutput -match "\d+" | Out-Null
    $sleepTimeout = [int]($matches[0])
    return [math]::round($sleepTimeout / 60)
}
 
# Function to get the system idle time in seconds using Windows API
function Get-IdleTime {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class IdleTime {
        [StructLayout(LayoutKind.Sequential)]
        public struct LASTINPUTINFO {
            public uint cbSize;
            public uint dwTime;
        }

        [DllImport("user32.dll")]
        public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        public static uint GetIdleTime() {
            LASTINPUTINFO lastInPut = new LASTINPUTINFO();
            lastInPut.cbSize = (uint)System.Runtime.InteropServices.Marshal.SizeOf(lastInPut);
            if (!GetLastInputInfo(ref lastInPut)) {
                throw new Exception("GetLastInputInfo failed");
            }
            return (uint)Environment.TickCount - lastInPut.dwTime;
        }
    }
"@

    # Get idle time in seconds
    return [IdleTime]::GetIdleTime() / 1000
}

# Get the sleep timeout in minutes
$sleepTimeoutMinutes = Get-SleepTimeout
