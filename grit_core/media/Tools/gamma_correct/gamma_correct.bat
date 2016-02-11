@echo off
@cd "%~dp1"
@"%~dp0luaimg.exe" -F gamma_correct.lua %1

IF ERRORLEVEL 1 pause