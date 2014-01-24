::UTLib Integrator Installation
::This script is CC0 Public Domain (http://creativecommons.org/publicdomain/zero/1.0/)
@echo off
echo Checking if UTLib is intact...
if exist .\UTLib\shared\utlIntegrator.lua (
	for /D %%d in (.\*) do (
		if not exist %%d\shared\ (
			echo Creating shared directory in %%d
			mkdir %%d\shared\
		)
		echo.
		echo Linking Integrator to %%d\shared\utlIntegrator.lua
		if not exist %%d\shared\utlIntegrator.lua (
			mklink /H %%d\shared\utlIntegrator.lua .\UTLib\shared\utlIntegrator.lua 
		) else echo ! Integrator already exists here...
	)
)
pause