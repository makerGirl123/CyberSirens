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

echo What all do you want to do?
echo Choose an option:
echo 1. ABSOLUTELY EVERYTHING
echo 2. Find Files
echo 3. Password Policies
echo 4. Disable Guest
REM ADD MORE LATER ---------------------------------------------------------

CHOICE /c 12345 /m ": "
if errorLevel 1 goto One
if errorLevel 2 goto Two
if errorLevel 3 goto Three
if errorLevel 4 goto Four
if errorLevel 5 goto Five

:One
	REM use goto to go through all other choices
	goto Two
	goto Three
	goto Five

:Two
	REM Unwanted Files Search
	echo Starting File Search...

	REM asks user for the file path to search
	set /p filePath=What Directory would you like to search?

	cd %filePath%

	REM Checks for an error, if found it restarts the File Search section code
	if %errorLevel% == 3(
		echo Specified path could not be found.
		goto Two
	)

	echo Starting search...

	dir *.jpg /s /a:h > unwantedFiles.txt
	dir *.jpeg /s /a:h >> unwantedFiles.txt
	dir *.png /s /a:h >> unwantedFiles.txt
	dir *.mp3 /s /a:h >> unwantedFiles.txt
	dir *.mp4 /s /a:h >> unwantedFiles.txt
	dir *.wav /s /a:h >> unwantedFiles.txt
	dir *.exe /s /a:h >> unwantedFiles.txt
	dir *.vbs /s /a:h >> unwantedFiles.txt
	dir *.xls* /s /a:h >> unwantedFiles.txt
	dir *.py* /s /a:h >> unwantedFiles.txt
	dir *.rb /s /a:h >> unwantedFiles.txt
	dir *.js /s /a:h >> unwantedFiles.txt

	echo Finished searching. View results in unwantedFiles.txt.

	REM Displays list of results in txt file
	unwantedFiles.txt	
:Three
	echo Starting Password Policy Hardening...
	net accounts /maxpwage:90
	net accounts /minpwage:15
	net accounts /minpwlen:10
	net accounts /uniquepw:24

	net accounts /lockoutthreshold:5
	net accounts /lockoutduration:30
	net accounts /lockoutwindow:10
	
	echo Finished setting password policies.

:Four
	echo Disabling Guest account...
	net user Guest /active:no >nul
	
	if errorLevel = 1 (
		echo Disabling Guest Account failed
	) else (
		echo Guest account disabled
	)
	
:Five
	echo Checking Current Users...
	REM NOT SURE IF THIS CODE WORKS 
	REM LIKE... AT ALL...

	wmic UserAccount get Name > currentUsers.txt
	for /f "skip=1" &&G in currentUsers.txt do (
		if "&&G" in allowedUsers.txt (
			net user "&&G" CyberPatriot2022! /passwordreq:yes
		) else (
			net user "&&G" /active:no
		)
	for /f &&G in allowedUsers.txt do (
		if "&&G" in currentUsers.txt (
			CHOICE /m "Do you want to create a user for %&&G%? "
			if errorLevel = 1 (
				net user "&&G" CyberPatriot2022! /add /passwordreq:yes 
				echo New user created
			)
		)	
	)












