# ProxyTray.ps1 - System tray icon with hover status + toggle

# Set server address and port
$PROXY_SERVER = "xx.xx.xx.xx:xxxx"
$REG_KEY = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set icons
$iconOn  = [System.Drawing.SystemIcons]::Shield
$iconOff = [System.Drawing.SystemIcons]::Error

# Create NotifyIcon
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Visible = $true

# Context menu
$context = New-Object System.Windows.Forms.ContextMenuStrip
$context.Items.Add("Toggle Proxy", $null, { ToggleProxy }) | Out-Null
$context.Items.Add("Exit", $null, { $notify.Visible = $false; $notify.Dispose(); exit }) | Out-Null
$notify.ContextMenuStrip = $context

# Toggle function
function ToggleProxy {
    $current = (Get-ItemProperty -Path $REG_KEY -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
    if ($current -eq 1) {
        Set-ItemProperty -Path $REG_KEY -Name ProxyEnable -Value 0
        UpdateIcon $false
    } else {
        Set-ItemProperty -Path $REG_KEY -Name ProxyEnable -Value 1
        Set-ItemProperty -Path $REG_KEY -Name ProxyServer -Value $PROXY_SERVER -ErrorAction SilentlyContinue
        UpdateIcon $true
    }
    # Flush DNS
    ipconfig /flushdns | Out-Null
}

# Update icon & tooltip
function UpdateIcon($isOn) {
    if ($isOn) {
        $notify.Icon = $iconOn
        $notify.Text = "Proxy: ON ($PROXY_SERVER)"
    } else {
        $notify.Icon = $iconOff
        $notify.Text = "Proxy: OFF"
    }
}

# Initial state
$current = (Get-ItemProperty -Path $REG_KEY -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
UpdateIcon ($current -eq 1)

# Left-click = toggle
$notify.Add_Click({ if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) { ToggleProxy } })

# Keep script running
[System.Windows.Forms.Application]::Run()