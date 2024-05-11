# Check if the script is running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    # Relaunch the script as administrator
    Start-Process -FilePath PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Your script logic starts here

# Check if the external GPU is connected
Write-Output "Checking for external GPU..."
if (Get-PnpDevice | Where-Object { $_.FriendlyName -like "*NVIDIA GeForce RTX 4060 Ti*" }) {
    Write-Output "External GPU (NVIDIA GeForce RTX 4060 Ti) detected."
    $internalGPU = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Intel(R) UHD Graphics 620*" }
    if ($internalGPU) {
        Write-Output "Internal GPU (Intel(R) UHD Graphics 620) detected."
        if ($internalGPU.Status -eq "OK") {
            Write-Output "Internal GPU is currently enabled."
            $confirmDisable = Read-Host "Do you want to disable the internal GPU? (Y/N)"
            if ($confirmDisable -eq "Y" -or $confirmDisable -eq "y") {
                Write-Output "Disabling internal GPU..."
                Disable-PnpDevice -InstanceId $internalGPU.InstanceId -Confirm:$false
                Write-Output "Internal GPU disabled."
            } else {
                Write-Output "Internal GPU not disabled."
            }
        } else {
            Write-Output "Internal GPU is already disabled."
            $confirmEnable = Read-Host "Do you want to enable the internal GPU? (Y/N)"
            if ($confirmEnable -eq "Y" -or $confirmEnable -eq "y") {
                Write-Output "Enabling internal GPU..."
                Enable-PnpDevice -InstanceId $internalGPU.InstanceId -Confirm:$false
                Write-Output "Internal GPU enabled."
            } else {
                Write-Output "Internal GPU not enabled."
            }
        }
    } else {
        Write-Output "Internal GPU (Intel(R) UHD Graphics 620) not detected."
    }
} else {
    Write-Output "External GPU (NVIDIA GeForce RTX 4060 Ti) not detected."
    $internalGPU = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Intel(R) UHD Graphics 620*" }
    if ($internalGPU) {
        Write-Output "Internal GPU (Intel(R) UHD Graphics 620) detected."
        if ($internalGPU.Status -ne "OK") {
            Write-Output "Internal GPU is currently disabled."
            $confirmEnable = Read-Host "Do you want to enable the internal GPU? (Y/N)"
            if ($confirmEnable -eq "Y" -or $confirmEnable -eq "y") {
                Write-Output "Enabling internal GPU..."
                Enable-PnpDevice -InstanceId $internalGPU.InstanceId -Confirm:$false
                Write-Output "Internal GPU enabled."
            } else {
                Write-Output "Internal GPU not enabled."
            }
        } else {
            Write-Output "Internal GPU is already enabled."
        }
    } else {
        Write-Output "Internal GPU (Intel(R) UHD Graphics 620) not detected."
    }
}
