::UTLib Integrator Uninstallation
::This script is CC0 Public Domain (http://creativecommons.org/publicdomain/zero/1.0/)
@echo off
echo Parsing Modules
for /D %%d in (.\*) do (
	if not %%d == .\UTLib (
		if exist %%d\shared\utlIntegrator.lua (
			echo.
			echo Removing %%d\shared\utlIntegrator.lua
			del %%d\shared\utlIntegrator.lua
		)
	)
)
pause