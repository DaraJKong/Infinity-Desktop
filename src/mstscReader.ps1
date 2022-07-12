Add-Type -AssemblyName 'UIAutomationClient'

#Start mstsc.exe with the argument /l, retain a process reference in $mstscProc
$mstscProc = Start-Process -FilePath 'mstsc.exe' -ArgumentList '/l' -PassThru
try {
  $handle = $null
  #MainWindowHandle sometimes returns 0, this while loop is a workaround
  while ((-not $mstscProc.HasExited) -and ($null -eq $handle))
  {
    Start-Sleep -Milliseconds 50
    $mstscProc.Refresh()
    if ($mstscProc.MainWindowHandle -ne 0)
    {
      $handle = $mstscProc.MainWindowHandle
    }
  }

  $cTrue = [System.Windows.Automation.PropertyCondition]::TrueCondition
  #Get the root element of the mstsc.exe process by handle
  $root = [System.Windows.Automation.AutomationElement]::FromHandle($handle)

  $rawText = $root.FindAll("Children", $cTrue) | 
    Select-Object -ExpandProperty Current | 
    # I used inspect.exe from the WinSDK to determine the AutomationId for the element containing the text
    Where-Object AutomationId -ieq 'ContentText' | 
    Select-Object -ExpandProperty Name  
}
finally {
  $mstscProc | Stop-Process -Force  
}

$monitors = @()

#split the raw text an process one line at a time
$rawText -split '\r?\n' | ForEach-Object {
  $parts = @()
  try {
    #Convert the line format "0: 1920 x 1080; (0, 0, 1919, 1079)" into numbers seperated by , then split
    $parts = @($_.replace(':', ',').replace(' x ', ',').replace(';', ',').replace('(', '').replace(')', '').replace(' ', '').Trim() -split ',')    
  }
  catch {
    #if any exceptions occur we assume the line is malformed
    $_ | Write-Verbose
  }
  
  if ($parts.Length -eq 7) {
    # a wellformed line should have 7 parts
    $properties = [ordered]@{
      Index = [int]$parts[0]
      Width = [int]$parts[1]
      Height = [int]$parts[2]
      Left = [int]$parts[3]
      Top = [int]$parts[4]
      Right = [int]$parts[5]
      Bottom = [int]$parts[6]
    }

    New-Object -TypeName psobject -Property $properties | Write-Output
	
	$monitors += ,$properties
  }
}

ConvertTo-Json -InputObject $monitors | Set-Content -Path .\mstscMonitors.json