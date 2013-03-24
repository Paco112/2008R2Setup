cls
$Host.Ui.RawUi.BackGroundColor = "DarkBlue"
cls
cd C:\2008R2Setup

#Import the script
Import-Module servermanager
Import-Module ".\menu.psm1"

function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

function saveRound($val)
{
	if($mode -eq 1)
	{
		set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -name SetupRound -value "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe $ScriptPath\setup.ps1 $val"
	}
}

$ScriptPath = Get-ScriptDirectory

$mode = 0;
$round = 0;

if($args[0] -eq "auto")
{
	$mode = 1;
	# lecture de la clée registre SetupRound
	$keyRound = (get-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run").SetupRound

	if(!$keyRound)
	{
		New-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -name 'SetupRound' -value "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe $ScriptPath\setup.ps1 1"
		
		# Autologon
		New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name 'AutoAdminLogon' -value 1
		New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name 'DefaultUserName' -value $env:username
		New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name 'DefaultDomainName' -value $env:computername
		
		$passwd1_txt = 0;
		$passwd2_txt = 1;
		
		while($passwd1_txt -ne $passwd2_txt -or $passwd1_txt -eq "")
		{
			$passwd1 = Read-Host 'Please enter your password' -AsSecureString
			$passwd2 = Read-Host 'Please confirm your password' -AsSecureString
			
			$passwd1_txt = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwd1))
			$passwd2_txt = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwd2))
		}
		
		New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name 'DefaultPassword' -value $passwd1_txt | out-null
	}
	else
	{
		set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -name 'SetupRound' -value "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe $ScriptPath\setup.ps1 1"
	}
	
	$round = 1;
}
elseif($args[0] -gt 0)
{
	# mode auto
	$mode = 1;
	$round = $args[0];
}

$menu = "1 - Setup Roles NET-Framework-Core","2 - Setup Roles Desktop-Experience","3 - Config Service startup","4 - Setup Joystick & XBOX","5 - Setup MS DirectMusic Core Services","6 - Setup Games Explorer and gameux.dll","7 - Disable IE Security","8 - Tuning Windows","9 - Disable Error Reporting","10 - Disable DEP Protection","11 - Setup Role qWave","12 - Enable Aero ","13 - Exit"
while(1)
{	
	if($mode -eq 1)
	{
		$selection = $round
	}
	else
	{
		$selection = Menu $menu "PLEASE SELECT YOUR CHOICE"
		$selection = $selection.Substring(0,2).Trim()
	}

	switch ($selection) 
	{ 
		1 {
			Write-Host "Setup Role NET-Framework-Core ..." -nonewline
			saveRound(++$round)
			Add-WindowsFeature NET-Framework-Core -restart
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		2 {
			Write-Host "Setup Role Desktop-Experience ..." -nonewline
			saveRound(++$round)
			Add-WindowsFeature Desktop-Experience -restart
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
			exit
		}
		3 {
			Write-Host "Config services startup ..." -nonewline
			saveRound(++$round)
			set-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\services\Themes -name 'Start' -Type DWORD -value '0x00000002'
			set-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\Services\Audiosrv -name 'Start' -Type DWORD -value '0x00000002'
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}  
		4 {
			Write-Host "Setup Joystick & Xbox ..." -nonewline
			saveRound(++$round)
			cd xinput
			. "./install.cmd"
			cd ..
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		5 {
			Write-Host "Setup MS DirectMusic Core Services ..." -nonewline
			saveRound(++$round)
			cd dmusic
			. "./install.cmd"
			cd ..
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		6 {
			Write-Host "Setup Games Explorer and gameux.dll ..." -nonewline
			saveRound(++$round)
			cd gameux
			. "./install.cmd"
			cd ..
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		7 {
			Write-Host "Disabled IE Enhanced Security for Administrator ..." -nonewline
			saveRound(++$round)
			$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
			#$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
			Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
			#Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
			#Stop-Process -Name Explorer
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		8 {
			Write-Host "Tuning Windows ..." -nonewline
			saveRound(++$round)
			# Disable NetworkThrottlingIndex
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -name 'NetworkThrottlingIndex' -Type DWORD -value '0xffffffff'
			
			# Set Hight Priority cpu for multimedia
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -name 'SystemResponsiveness' -Type DWORD -value '0x00000014'
			
			# Force kernel in RAM
			#set-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name 'DisablePagingExecutive' -Type DWORD -value '0x00000001'
			
			# Set Processor Scheduling to Foreground
			set-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -name 'Win32PrioritySeparation' -Type DWORD -value '0x00000026'

			# Disable Shutdown Event Tracker
			New-Item -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -name 'Reliability'
			New-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -name 'ShutdownReasonOn' -Type DWORD -value 0

			# Increase IE8 connections
			#set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" -name 'iexplore.exe' -Type DWORD -value '0x0000000a'
			#set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" -name 'iexplore.exe' -Type DWORD -value '0x0000000a'

			# Disable CTRL+ALT+Delete
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -name 'disablecad' -value 1
			
			# Enable thumbnails in Windows Explorer
			set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name 'IconsOnly' -Type DWORD -value 0
			
			# Enable file hidden and ext hidden 
			set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name 'Hidden' -Type DWORD -value 1
			set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name 'HideFileExt' -Type DWORD -value 0
			
			# Set small icon on taskbar and lock taskbar
			set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name 'TaskbarSmallIcons' -Type DWORD -value 1
			set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name 'TaskbarSizeMove' -Type DWORD -value 0
			
			# Disable "Avertissement de sécurité" sur les .exe et .msi
			New-Item -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -name 'Associations'
			New-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" -name 'ModRiskFileTypes' -value ".exe;.msi"
			
			# Disable Check perf Aero
			New-ItemProperty -path "HKCU:\Software\Microsoft\Windows\DWM" -name 'UseMachineCheck' -Type DWORD -value 0
			New-ItemProperty -path "HKCU:\Software\Microsoft\Windows\DWM" -name 'Blur' -Type DWORD -value 0
			New-ItemProperty -path "HKCU:\Software\Microsoft\Windows\DWM" -name 'Animations' -Type DWORD -value 0
			
			# Enable Aero Peak
			set-itemproperty -path "HKCU:\Software\Microsoft\Windows\DWM" -name 'EnableAeroPeek' -Type DWORD -value '0x00000001'
			
			# Enable Verr Num
			set-itemproperty -path "REGISTRY::\HKEY_USERS\.DEFAULT\Control Panel\Keyboard" -name 'InitialKeyboardIndicators' -value 2
			
			# Disale date last access 
			cmd /c "fsutil behavior set disablelastaccess 1"
			
			# Disable NtfsDisable8dot3NameCreation
			cmd /c "fsutil behavior set disable8dot3 1"

			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		9 {
			Write-Host "Disable Error Reporting ..." -nonewline
			saveRound(++$round)
			# Disable Error Reporting
			serverWerOptin /disable
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		10 {
			Write-Host "Disable DEP Protection ..." -nonewline
			saveRound(++$round)
			# Disable DEP Protection
			cmd /c "bcdedit.exe /set {current} nx AlwaysOff"
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		11 {
			Write-Host "Setup Role qWave ..." -nonewline
			saveRound(++$round)
			Add-WindowsFeature qWave -restart
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
			exit
		}
		12 {
			# Enable Aero
			Write-Host "Enable Aero ..." -nonewline
			saveRound(++$round)
			start-process rundll32.exe -arg 'Shell32.dll,Control_RunDLL desk.cpl desk,@Themes /Action:OpenTheme /File:"C:\Windows\resources\Themes\aero.theme"' -WindowStyle Hidden
			Start-Sleep -s 5
			Write-Host "[ OK ]" -foregroundcolor DarkGreen
		}
		13 { 
			if($mode -eq 1)
			{
				# supprime la clée registre de lacement auto
				Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -name 'SetupRound'
				
				# Disable autologon
				start-process rundll32.exe -arg 'netplwiz.dll,ClearAutoLogon'
				
				Write-Host "SETUP FINISH ! Please REBOOT - Please REBOOT ! SETUP FINISH"
				Write-Host " "
				Write-Host "Reboot in 5 secondes"
				Start-Sleep -s 1
				Write-Host "Reboot in 4 secondes"
				Start-Sleep -s 1
				Write-Host "Reboot in 3 secondes" 
				Start-Sleep -s 1
				Write-Host "Reboot in 2 secondes"
				Start-Sleep -s 1
				Write-Host "Reboot in 1 seconde"
				Start-Sleep -s 1
				
				Restart-Computer
			}
			exit 
		} 
		default {	}
	}
	
	if($mode -eq 0)
	{
		cmd /c pause
	}
}


