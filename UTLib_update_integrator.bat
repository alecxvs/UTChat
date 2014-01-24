::UTLib Integrator Installation
::This script is CC0 Public Domain (http://creativecommons.org/publicdomain/zero/1.0/)
@echo off
echo Checking if UTLib is intact...
if exist .\UTLib\shared\utlIntegrator.lua (
	for /D %%d in (.\*) do (
		if not %%d == .\UTLib (
			if exist %%d\shared\utlIntegrator.lua (
				del %%d\shared\utlIntegrator.lua
			)
			echo.
			echo Updating %%d\shared\utlIntegrator.lua
			mklink /H %%d\shared\utlIntegrator.lua .\UTLib\shared\utlIntegrator.lua 
		)
	)
)
pause