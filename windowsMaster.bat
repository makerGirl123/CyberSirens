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
echo 7. Firewall
echo 8. Admin Accounts
REM ADD MORE LATER ---------------------------------------------------------

CHOICE /c 12345678
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
	if errorLevel = 1 (
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
	CHOICE /m "Do you want to create a new user? "
	if %errorLevel% == 1 (
		set /p name=What do you want to be the username?
		CHOICE /m Do you want this user to be an admin?
	if %errorlevel% == 1 (
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
	goto:eof

:Eight
	echo Checking Admin Accounts
	REM might need to add some stuff here...
	REM rename admin!!!!!!!
	goto:eof

:Nine
	echo Checking Auditing Processes
	auditpol /set /category:* /success:enable >nul
	auditpol /set /category:* /failure:enable >nul
	echo Auditing success and failures enabled
	goto:eof
:Ten
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
	echo Disabled unnecessary services
	goto:eof
