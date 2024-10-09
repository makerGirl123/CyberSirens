@echo off 

REM The Do Everything Script for Windows

REM --------------------------------------------------------------------------
REM Make sure you have the following files created and saved in the same 
REM directory as this file: allowedUsers.txt, adminUsers.txt
REM --------------------------------------------------------------------------


REM First things first... Are you running as Admin?
goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Detecting permissions...
    
    REM runs a command that needs admin
    net session >nul 2>&1

    REM if there is no error good
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
    ) else (
        echo Failure: Current permissions inadequate.
	echo ------------------------------------------------------------------
	echo If you're seeing this after clicking on a start menu icon, 
	echo then right click on the shortcut and select "Run As Administrator".
	REM ends script and returns to terminal
	exit /b
    )
    
pause
set "startDirec=%cd%"
echo What all do you want to do?
echo Choose an option:
echo 1. ABSOLUTELY EVERYTHING
echo 2. Find Files
echo 3. Password Policies
echo 4. Disable Guest
echo 5. User Management
echo 6. Create new User
echo 7. Firewall & Updates
echo 8. Services
echo 9. Auditing
REM ADD MORE LATER ---------------------------------------------------------

CHOICE /c 123456789
REM if %errorlevel% == 0 goto Ten
if %errorlevel% == 9 goto Nine
if %errorlevel% == 8 goto Eight
if %errorlevel% == 7 goto Seven
if %errorlevel% == 6 goto Six
if %errorLevel% == 5 goto Five
if %errorLevel% == 4 goto Four
if %errorLevel% == 3 goto Three
if %errorLevel% == 2 goto Two
if %errorLevel% == 1 goto One

:One
	REM use goto to go through all other choices
	call :Two
	call :Three
	call :Four
	call :Five
	call :Six
	call :Seven
	exit /b 

:Two
	REM Unwanted Files Search
	echo Starting File Search...
	set "startDirec=%cd%"

	REM asks user for the file path to search
	set /p filePath=What Directory would you like to search?

	cd %filePath%

	echo Starting search...

	dir *.jpg /s /a:h /b > unwantedFiles.txt
	dir *.jpeg /s /a:h /b >> unwantedFiles.txt
	dir *.png /s /a:h /b >> unwantedFiles.txt
	dir *.mp3 /s /a:h /b >> unwantedFiles.txt
	dir *.mp4 /s /a:h /b >> unwantedFiles.txt
	dir *.wav /s /a:h /b >> unwantedFiles.txt
	dir *.exe /s /a:h /b >> unwantedFiles.txt
	dir *.vbs /s /a:h /b >> unwantedFiles.txt
	dir *.xls* /s /a:h /b >> unwantedFiles.txt
	dir *.py* /s /a:h /b >> unwantedFiles.txt
	dir *.rb /s /a:h /b >> unwantedFiles.txt
	dir *.js /s /a:h /b >> unwantedFiles.txt

	echo Finished searching. View results in unwantedFiles.txt.
	echo Close unwantedFiles.txt to continue.

	REM Displays list of results in txt file
	unwantedFiles.txt
	pause >NUL

	echo Finding Hacktools now...
	findstr "Cain" programfiles.flashed
	if %errorlevel%==0 (
	echo Cain detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	findstr "nmap" programfiles.flashed
	if %errorlevel%==0 (
	echo Nmap detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	findstr "keylogger" programfiles.flashed
	if %errorlevel%==0 (
	echo Potential keylogger detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	findstr "Armitage" programfiles.flashed
	if %errorlevel%==0 (
	echo Potential Armitage detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	findstr "Metasploit" programfiles.flashed
	if %errorlevel%==0 (
	echo Potential Metasploit framework detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	findstr "Shellter" programfiles.flashed
	if %errorlevel%==0 (
	echo Potential Shellter detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	findstr "Wireshark" programfiles.flashed
	if %errorlevel%==0 (
	echo Potential Wireshark detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	findstr "Ccleaner" programfiles.flashed
	if %errorlevel%==0 (
	echo Potential CCleaner detected. Please take note, then press any key.
	pause >NUL
	)
	cls
	cd %startDirec%
	exit /b 
:Three
	echo Starting Password Policy Hardening...
	net accounts /maxpwage:90
	net accounts /minpwage:15
	net accounts /minpwlen:10
	net accounts /uniquepw:24

	net accounts /lockoutthreshold:5
	net accounts /lockoutduration:30
	net accounts /lockoutwindow:10
	echo Finished setting automatic password policies.

	echo Secpol.msc will be started for manual process
	start secpol.msc /wait
	pause
	exit /b 

:Four
	echo Disabling Guest account...
	net user Guest /active:no >nul
	if %errorLevel% = 1 (
		echo Disabling Guest Account failed
	) else (
		echo Guest account disabled
	)
	REM rename guest!!!!!!!!!
	exit /b 
:Five
	echo Checking Current Users...
	REM NOT SURE IF THIS CODE WORKS 
	REM LIKE... AT ALL...

	REM Creates a file of all current users
	wmic UserAccount get Name > currentUsers.txt

	echo Check currentUsers for accounts not listed in your allowed users file that you do want to keep
	echo such as Administrator or WDAGUtilityAccount
	echo Close currentUsers.txt when you are ready to continue.
	currentUsers.txt

	REM sets the file path of allowedUsers.txt to the currentUserPath variable
	FOR /F "tokens=*" %%b IN ('dir allowedUsers.txt /s /b') do (SET allowedUserPath=%%b)
	FOR /F "tokens=*" %%c IN ('dir currentUsers.txt /s /b') do (SET currentUserPath=%%c)


	REM Loops through each current user and checks if they are allowed
	for /F "skip=1" %%a in ('wmic UserAccount get Name') do (
	REM echo "%%a"
	set "userName=%%a"
	call :manageAccount userName
	)
	echo User Accounts Updated
	exit /b 

:manageAccount
	findstr /m %userName% %allowedUserPath% >nul 
	if %errorlevel%==1 (
	
		net user "%userName%" /active:no >nul
		echo Disabled %userName%
	) else (
		if %username%==%userName% (
			echo Didn't change %userName% password
		)
		else (
			net user "%userName%" CyberPatriot2022! /passwordreq:yes >nul
			echo Updated %userName% password
		)
	)
	goto:eof

:Six
	set /p newUsrChk="Do you want to create a new user? (y/n)"
	if %newUsrChk%==y (
		set /p userName2=What do you want to be the username?
		set /p adminChk="Do you want this user to be an admin? (y/n)"
	)
	if %adminChk%==y (
		net user "%userName2%" CyberPatriot2022! /add /passwordreq:yes >nul
	) else (
		net user "%userName2%" CyberPatriot2022! /add /passwordreq:yes >nul
	)
	echo New user created
	goto:eof

:Seven
	echo Enabling Firewall...
	netsh advfirewall set allprofiles state on >nul
	echo Firewall enabled.

	netsh advfirewall firewall set rule name="Remote Assistance (DCOM-In)" new enable=no 
	netsh advfirewall firewall set rule name="Remote Assistance (PNRP-In)" new enable=no 
	netsh advfirewall firewall set rule name="Remote Assistance (RA Server TCP-In)" new enable=no 
	netsh advfirewall firewall set rule name="Remote Assistance (SSDP TCP-In)" new enable=no 
	netsh advfirewall firewall set rule name="Remote Assistance (SSDP UDP-In)" new enable=no 
	netsh advfirewall firewall set rule name="Remote Assistance (TCP-In)" new enable=no 
	netsh advfirewall firewall set rule name="Telnet Server" new enable=no 
	netsh advfirewall firewall set rule name="netcat" new enable=no
	echo Set basic firewall rules.

	netsh advfirewall show allprofiles
	pause

	REM Windows auomatic updates
	echo "ENABLING AUTO-UPDATES"
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 3 /f
	goto:eof

:Eight
	echo Checking Services
	REM might need to add some stuff here...
	REM event log service definately on
	REM remote services based on README
	dism /online /disable-feature /featurename:IIS-WebServerRole >NUL
	dism /online /disable-feature /featurename:IIS-WebServer >NUL
	dism /online /disable-feature /featurename:IIS-CommonHttpFeatures >NUL
	dism /online /disable-feature /featurename:IIS-HttpErrors >NUL
	dism /online /disable-feature /featurename:IIS-HttpRedirect >NUL
	dism /online /disable-feature /featurename:IIS-ApplicationDevelopment >NUL
	dism /online /disable-feature /featurename:IIS-NetFxExtensibility >NUL
	dism /online /disable-feature /featurename:IIS-NetFxExtensibility45 >NUL
	dism /online /disable-feature /featurename:IIS-HealthAndDiagnostics >NUL
	dism /online /disable-feature /featurename:IIS-HttpLogging >NUL
	dism /online /disable-feature /featurename:IIS-LoggingLibraries >NUL
	dism /online /disable-feature /featurename:IIS-RequestMonitor >NUL
	dism /online /disable-feature /featurename:IIS-HttpTracing >NUL
	dism /online /disable-feature /featurename:IIS-Security >NUL
	dism /online /disable-feature /featurename:IIS-URLAuthorization >NUL
	dism /online /disable-feature /featurename:IIS-RequestFiltering >NUL
	dism /online /disable-feature /featurename:IIS-IPSecurity >NUL
	dism /online /disable-feature /featurename:IIS-Performance >NUL
	dism /online /disable-feature /featurename:IIS-HttpCompressionDynamic >NUL
	dism /online /disable-feature /featurename:IIS-WebServerManagementTools >NUL
	dism /online /disable-feature /featurename:IIS-ManagementScriptingTools >NUL
	dism /online /disable-feature /featurename:IIS-IIS6ManagementCompatibility >NUL
	dism /online /disable-feature /featurename:IIS-Metabase >NUL
	dism /online /disable-feature /featurename:IIS-HostableWebCore >NUL
	dism /online /disable-feature /featurename:IIS-StaticContent >NUL
	dism /online /disable-feature /featurename:IIS-DefaultDocument >NUL
	dism /online /disable-feature /featurename:IIS-DirectoryBrowsing >NUL
	dism /online /disable-feature /featurename:IIS-WebDAV >NUL
	dism /online /disable-feature /featurename:IIS-WebSockets >NUL
	dism /online /disable-feature /featurename:IIS-ApplicationInit >NUL
	dism /online /disable-feature /featurename:IIS-ASPNET >NUL
	dism /online /disable-feature /featurename:IIS-ASPNET45 >NUL
	dism /online /disable-feature /featurename:IIS-ASP >NUL
	dism /online /disable-feature /featurename:IIS-CGI >NUL
	dism /online /disable-feature /featurename:IIS-ISAPIExtensions >NUL
	dism /online /disable-feature /featurename:IIS-ISAPIFilter >NUL
	dism /online /disable-feature /featurename:IIS-ServerSideIncludes >NUL
	dism /online /disable-feature /featurename:IIS-CustomLogging >NUL
	dism /online /disable-feature /featurename:IIS-BasicAuthentication >NUL
	dism /online /disable-feature /featurename:IIS-HttpCompressionStatic >NUL
	dism /online /disable-feature /featurename:IIS-ManagementConsole >NUL
	dism /online /disable-feature /featurename:IIS-ManagementService >NUL
	dism /online /disable-feature /featurename:IIS-WMICompatibility >NUL
	dism /online /disable-feature /featurename:IIS-LegacyScripts >NUL
	dism /online /disable-feature /featurename:IIS-LegacySnapIn >NUL
	dism /online /disable-feature /featurename:IIS-FTPServer >NUL
	dism /online /disable-feature /featurename:IIS-FTPSvc >NUL
	dism /online /disable-feature /featurename:IIS-FTPExtensibility >NUL
	dism /online /disable-feature /featurename:TFTP >NUL
	dism /online /disable-feature /featurename:TelnetClient >NUL
	dism /online /disable-feature /featurename:TelnetServer >NUL


	echo Managing registry keys...
	::Windows auomatic updates
	reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AutoInstallMinorUpdates /t REG_DWORD /d 1 /f
	reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 0 /f
	reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AUOptions /t REG_DWORD /d 4 /f
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 4 /f
	reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
	reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v ElevateNonAdmins /t REG_DWORD /d 0 /f
	reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoWindowsUpdate /t REG_DWORD /d 0 /f
	reg add "HKLM\SYSTEM\Internet Communication Management\Internet Communication" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
	reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
	::Restrict CD ROM drive
	reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateCDRoms /t REG_DWORD /d 1 /f
	::Disallow remote access to floppy disks
	reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateFloppies /t REG_DWORD /d 1 /f
	::Disable auto Admin logon
	reg ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_DWORD /d 0 /f
	::Clear page file (Will take longer to shutdown)
	reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f
	::Prevent users from installing printer drivers 
	reg ADD "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v AddPrinterDrivers /t REG_DWORD /d 1 /f
	::Add auditing to Lsass.exe
	reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
	::Enable LSA protection
	reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v RunAsPPL /t REG_DWORD /d 00000001 /f
	::Limit use of blank passwords
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
	::Auditing access of Global System Objects
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v auditbaseobjects /t REG_DWORD /d 1 /f
	::Auditing Backup and Restore
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v fullprivilegeauditing /t REG_DWORD /d 1 /f
	::Restrict Anonymous Enumeration #1
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v restrictanonymous /t REG_DWORD /d 1 /f
	::Restrict Anonymous Enumeration #2
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v restrictanonymoussam /t REG_DWORD /d 1 /f
	::Disable storage of domain passwords
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v disabledomaincreds /t REG_DWORD /d 1 /f
	::Take away Anonymous user Everyone permissions
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v everyoneincludesanonymous /t REG_DWORD /d 0 /f
	::Allow Machine ID for NTLM
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v UseMachineId /t REG_DWORD /d 0 /f
	::Do not display last user on logon
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v dontdisplaylastusername /t REG_DWORD /d 1 /f
	::Enable UAC
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
	::UAC setting (Prompt on Secure Desktop)
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
	::Enable Installer Detection
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableInstallerDetection /t REG_DWORD /d 1 /f
	::Disable undocking without logon
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v undockwithoutlogon /t REG_DWORD /d 0 /f
	::Enable CTRL+ALT+DEL
	reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v DisableCAD /t REG_DWORD /d 0 /f
	::Max password age
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v MaximumPasswordAge /t REG_DWORD /d 15 /f
	::Disable machine account password changes
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v DisablePasswordChange /t REG_DWORD /d 1 /f
	::Require strong session key
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireStrongKey /t REG_DWORD /d 1 /f
	::Require Sign/Seal
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v RequireSignOrSeal /t REG_DWORD /d 1 /f
	::Sign Channel
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SignSecureChannel /t REG_DWORD /d 1 /f
	::Seal Channel
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /v SealSecureChannel /t REG_DWORD /d 1 /f
	::Set idle time to 45 minutes
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v autodisconnect /t REG_DWORD /d 45 /f
	::Require Security Signature - Disabled pursuant to checklist:::
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v enablesecuritysignature /t REG_DWORD /d 0 /f
	::Enable Security Signature - Disabled pursuant to checklist:::
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v requiresecuritysignature /t REG_DWORD /d 0 /f
	::Clear null session pipes
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v NullSessionPipes /t REG_MULTI_SZ /d "" /f
	::Restict Anonymous user access to named pipes and shares
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v NullSessionShares /t REG_MULTI_SZ /d "" /f
	::Encrypt SMB Passwords
	reg ADD HKLM\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters /v EnablePlainTextPassword /t REG_DWORD /d 0 /f
	::Clear remote registry paths
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths /v Machine /t REG_MULTI_SZ /d "" /f
	::Clear remote registry paths and sub-paths
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedPaths /v Machine /t REG_MULTI_SZ /d "" /f
	::Enable smart screen for IE8
	reg ADD "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV8 /t REG_DWORD /d 1 /f
	::Enable smart screen for IE9 and up
	reg ADD "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f
	::Disable IE password caching
	reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v DisablePasswordCaching /t REG_DWORD /d 1 /f
	::Warn users if website has a bad certificate
	reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonBadCertRecving /t REG_DWORD /d 1 /f
	::Warn users if website redirects
	reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnPostRedirect /t REG_DWORD /d 1 /f
	::Enable Do Not Track
	reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main" /v DoNotTrack /t REG_DWORD /d 1 /f
	reg ADD "HKCU\Software\Microsoft\Internet Explorer\Download" /v RunInvalidSignatures /t REG_DWORD /d 1 /f
	reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings" /v LOCALMACHINE_CD_UNLOCK /t REG_DWORD /d 1 /f
	reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonZoneCrossing /t REG_DWORD /d 1 /f
	::Show hidden files
	reg ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f
	::Disable sticky keys
	reg ADD "HKU\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f
	::Show super hidden files
	reg ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
	::Disable dump file creation
	reg ADD HKLM\SYSTEM\CurrentControlSet\Control\CrashControl /v CrashDumpEnabled /t REG_DWORD /d 0 /f
	::Disable autoruns
	reg ADD HKCU\SYSTEM\CurrentControlSet\Services\CDROM /v AutoRun /t REG_DWORD /d 1 /f
	echo Managed registry keys
	goto:eof

:Nine
	echo Checking Auditing Processes
	auditpol /set /category:* /success:enable >nul
	auditpol /set /category:* /failure:enable >nul
	echo Auditing success and failures enabled
	goto:eof
	
