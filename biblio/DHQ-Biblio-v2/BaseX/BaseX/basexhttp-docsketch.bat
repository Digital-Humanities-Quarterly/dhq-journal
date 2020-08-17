REM Place this file in a directory inside BaseX installation

@echo off
setLocal EnableDelayedExpansion

REM Path to this script
set PWD=%~dp0

REM Core and library classes
set CP=%PWD%/../BaseX.jar
set LIB=%PWD%/../lib
for /R "%LIB%" %%a in (*.jar) do set CP=!CP!;%%a

REM Options for virtual machine
set VM=-Xmx1g
set BASEXOPTIONS=-Dorg.basex.WEBPATH=C:\Users\Wendell\Documents\GitHub\DocSketch

REM Run code
java %BASEXOPTIONS% -cp "%CP%;." %VM% org.basex.BaseXHTTP %*
