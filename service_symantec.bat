:: service_symantec.bat stop | start
:: This script enable or disable the EDR symantec environment
:: @author Kogium <kogium@valkyrie.zone>
:: @date 25/09/2020
:: version 1.6
::----------------------------------------------

:: hide extra stuff
@ECHO OFF

:: clear the screen
cls

:: Path to Sublime Text installation dir.
SET bin64path="%programfiles(x86)%\Symantec\Symantec Endpoint Protection\14.2.5323.2000.105\Bin"
SET bin32path="%programfiles%\Symantec\Symantec Endpoint Protection\14.2.5323.2000.105\Bin"
SET exe64path="%bin64path%\Smc.exe"
SET exe32path="%bin32path%\Smc.exe"

:: Context menu privilege.
call :check_Permissions

echo ===================================
:: get pid list
SET pnb=1
:: Update the detection of the service state status in windows System Services
for /f "tokens=2" %%s in ('sc query state^= all ^| find "SepMasterService"') do ( for /f "tokens=4" %%t in ('sc query %%s ^| find "STATE     "') do (
	IF "%%t" == "STOP_PENDING" set /A pnb=0
	IF "%%t" == "STOPPED" set /A pnb=0
))

:: Retrive command start or stop
SET command=%~1
IF "%command%"=="start" (
	
	:: detect status "start"
	if %pnb% gtr 0 (
		echo ===================================
		echo Symantec EDR is already sarted . . . press any key to leave.
		echo ===================================
		pause
		goto :EOF
	) else (
		SET command="-start"
	)
	
) else (
	IF "%command%"=="stop" (
		
		:: detect status "dead"
		if %pnb% equ 0 (
			echo ===================================
			echo Symantec EDR is already stopped . . . press any key to leave.
			echo ===================================
			pause
			goto :EOF
		) else (
			SET command="-stop"
		)
		
	) else (
		
		:: detect empty argument
		IF "%~1" == "" (
			if %pnb% gtr 0 (
				SET command="-stop"
			) else (
				if %pnb% equ 0 (
					SET command="-start"
				) else (
					SET command="-stop"
				)
			)
		) else (
			echo ===================================
			echo Argument are invalid . . . press any key to leave.
			echo ===================================
			pause
			goto :EOF
		)
	)
)

:: execute commande
IF exist "%exe64path%" (
    "%exe64path%" %command%
) else (
    IF exist "%exe32path%" (
		"%exe32path%" %command%
	) else (
		echo ===================================
		echo The symantec environment does not match . . . press any key to leave.
		echo ===================================
		pause
		goto :EOF
	)
)

echo ===================================
echo %command% done! press any key to leave.
echo ===================================
pause
goto :EOF



:check_Permissions
echo ===================================
echo # Administrative permissions required.
echo # Detecting permissions...
echo ===================================
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrative permissions confirmed.
    goto :EOF
) else (
    echo Failure: Current permissions inadequate. Try to get elevation...
    SET openwithsublime_elevation=1
    call "%elevate.CmdPath%" "%~fs0"
    exit
)
goto :EOF
