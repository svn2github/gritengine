:: Copyright (c) 2010 Dieter 'DaBeast^' Beckers, Dave Cunningham
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
:: THE SOFTWARE.

:: This script uses the extract.exe executable to convert from GTA formats to
:: Grit formats.  It requires a working install of GTA San Andreas or an 
:: install of Gostown Paradise to work from.  If you have not purchased GTA San
:: Andreas you are not authorised to use this script.  The directory where these
:: files reside is specified with SADIR.

:: The MOD variable indicates to extract.exe which source files
:: (IMG/dff/txd/ide/ipl) to use.  Options for this are: gostown and gtasa

@echo off

set SADIR=C:\Program Files\Rockstar Games\GTA San Andreas
set MOD=gtasa
set MODNAME=Vanilla GTA San Andreas

cls
echo      ___           ___                             
echo     /  /\         /  /\        ___           ___   
echo    /  /:/_       /  /::\      /  /\         /  /\  
echo   /  /:/ /\     /  /:/\:\    /  /:/        /  /:/  
echo  /  /:/_/::\   /  /:/~/:/   /__/::\       /  /:/   
echo /__/:/__\/\:\ /__/:/ /:/___ \__\/\:\__   /  /::\   
echo \  \:\ /~~/:/ \  \:\/:::::/    \  \:\/\ /__/:/\:\  
echo  \  \:\  /:/   \  \::/~~~~      \__\::/ \__\/  \:\ 
echo   \  \:\/:/     \  \:\          /__/:/       \  \:\
echo    \  \::/       \  \:\         \__\/         \__\/
echo     \__\/         \__\/                            
echo   Grand Theft Auto converter for Grit Game Engine
echo.
echo *****************************************************************
echo Default selected San Andreas install folder:
echo "%SADIR%"
echo *****************************************************************
echo Default selected mod:
echo "%MODNAME%"
echo ****************************************************************
echo Options:
echo 1 - Export with defaults
echo 2 - Export vanilla San Andreas (and specify folder)
echo 3 - Export Gostown Paradise total conversion (and specify folder)
echo 4 - WTF is this?  Exit now!
echo ****************************************************************

:AGAIN
SET /P M=Type 1, 2, 3, or 4, then press ENTER:  
IF "%M%"=="1" GOTO DO_EXTRACT
IF "%M%"=="2" GOTO NEED_DIR
IF "%M%"=="3" GOTO GP
IF "%M%"=="4" exit
echo Not a recognised option: "%M%".
goto AGAIN

:GP
set MOD=gostown
set MODNAME=Gostown Paradise
goto NEED_DIR

:NEED_DIR
set DEFAULT=%SADIR%
echo.
cls
echo ************************************************************
echo You selected "%MODNAME%" to convert.
echo Please enter install folder, e.g.:
echo %DEFAULT%
echo Or press enter to use the above default.
echo (You can exit now by typing exit)
echo ************************************************************
SET /P SADIR=Install folder:  
IF "%SADIR%"=="exit" exit
IF "%SADIR%"=="" set SADIR="%DEFAULT%"
goto DO_EXTRACT

:DO_EXTRACT
echo.
cls
echo Extracting mod "%MODNAME%" from "%SADIR%".  This may take a while.
echo (Note that errors in the original files will produce warnings in the following output, but can be ignored.)
echo.
extract.exe "%mod%" "%SADIR%" ..
IF ERRORLEVEL 1 goto FAIL
goto SUCCESS

:FAIL
echo Conversion failed.
goto QUIT

:SUCCESS
echo Conversion completed successfully.
goto QUIT

:QUIT
echo.
pause
exit
