:user_configuration

:: Path to Flex SDK
::set FLEX_SDK=C:\flex_sdk
::set FLEX_SDK=D:\SDKs\AIRSDK
set FLEX_SDK=D:\Tools - SDKs\Flex 4.14.1 AIR 19

:validation
if not exist "%FLEX_SDK%" goto flexsdk
goto succeed

:flexsdk
echo.
echo ERROR: incorrect path to Flex SDK in 'bat\SetupSDK.bat'
echo.
echo %FLEX_SDK%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%FLEX_SDK%\bin;%PATH%

