$CurDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$file = $CurDir + '\out.txt'

$IfTmaxInFile = $false
$TmaxInFile=""
$Tmax = 0

try{
	Write-Host "Open out.txt file and look for Tmax value"
	$content = Get-Content $file
	for ($i=0; $i -lt $content.length; $i++) {
		$line = $content[$i].trim() -replace '\s{1,}', ' '
		if($line -match 'Tmax(\s{0,})=') {
			$IfTmaxInFile = $true
			$TmaxInFile = $line
			Write-Host "Raw line with Tmax value in File is:" $line
			break
		}
	}
}
catch {
	Write-Warning $_
	Write-Host "Can't open out.txt file!"
}

if($IfTmaxInFile) {
	try{
		$TmaxInFile = $TmaxInFile.replace('Tmax', '').replace('=','').trim()
		if($TmaxInFile -match '^(0|([1-9]\d*))(\.\d+)?$'){
			Write-Host "Tmax in File is" $Matches[0]
			$TmaxInFile = $Matches[0]
			If ($TmaxInFile.Contains(".")) {
				$TmaxInFile = $TmaxInFile.Substring(0, $TmaxInFile.IndexOf("."))
			}
			$Tmax = [int]$TmaxInFile

			if ($Tmax -lt 300) {
				Write-Host "Tmax in file" $Tmax "is less than 300!"
				$Tmax = 300
			}
		} else{
			Write-Warning "Tmax in file is not a normal number!"
			$Tmax = 300
		}
	} catch {
		Write-Warning $_
		Write-Warning "Tmax in file is not a normal number!"
		$Tmax = 300
	}
} else {
	Write-Warning "Can't get Tmax from out.txt!"
	$Tmax = 300
}

Write-Host "Final Tmax is:" $Tmax

REG ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Media Foundation\SVR" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Media Foundation\SVR" /v EDRMaxLuminance /t REG_DWORD /d $Tmax /f

Exit
