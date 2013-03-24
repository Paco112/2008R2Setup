#Import the script
Import-Module servermanager
Import-Module ".\menu.psm1"

$menu = "1 - Setup Roles ( NET-Framework-Core,  Desktop-Experience, qWave )","2 - Setup SuperFetch","3 - Setup Joystick & XBOX","4 - Tuning Windows","5 - Exit"
while(1)
{
	cls
	$selection = Menu $menu "PLEASE SELECT YOUR CHOICE"
	$selection = $selection.Substring(0,1)

	switch ($selection) 
	{ 
		1 {
			cls
			Add-WindowsFeature NET-Framework-Core
			Add-WindowsFeature Desktop-Experience 
			Add-WindowsFeature qWave
			
			set-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\services\Themes -name 'Start' -Type DWORD -value '0x00000002'
			set-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\Services\Audiosrv -name 'Start' -Type DWORD -value '0x00000002'
			Write-Host "[OK]"
		} 
		2 {
			set-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -name 'EnablePrefetcher' -Type DWORD -value '0x00000003'
			set-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -name 'EnableSuperfetch' -Type DWORD -value '0x00000003'
			set-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\SysMain" -name 'Start' -Type DWORD -value '0x00000002'
			Write-Host "[OK]"				
		} 
		3 {
			cd xinput
			. "./install.cmd"
			cd ..
			Write-Host "[OK]"
		} 
		4 {
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -name 'NetworkThrottlingIndex' -Type DWORD -value '0xffffffff'
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -name 'SystemResponsiveness' -Type DWORD -value '0x00000014'
			
			# Set Processor Scheduling to Foreground
			set-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -name 'Win32PrioritySeparation' -Type DWORD -value '0x00000026'

			# Disable Shutdown Event Tracker
			set-itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -name 'ShutdownReasonOn' -Type DWORD -value '0x00000000'

			# Disable Error Reporting
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\PCHealth\ErrorReporting" -name 'DoReport' -Type DWORD -value '0x00000000'
			
			# Increase IE8 connections
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" -name 'iexplore.exe' -Type DWORD -value '0x0000000a'
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" -name 'iexplore.exe' -Type DWORD -value '0x0000000a'

			# Disable CTRL+ALT+Delete
			set-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -name 'DisableCAD' -Type DWORD -value '0x00000001'
			
			# Enable thumbnails in Windows Explorer
			set-itemproperty -path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name 'IconsOnly' -Type DWORD -value '0x00000000'

			# Disable DEP Protection
			bcdedit.exe /set {current} nx AlwaysOff
			
			Write-Host "[OK]"
		} 
		5 { exit } 
		default {	}
	}
	cmd /c pause
}


