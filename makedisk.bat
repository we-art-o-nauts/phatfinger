
rem -- SPINDLE 3.1 

set result_disk1=%date:~-4%_%date:~3,2%_%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%_viewer.d64
set pathdef="binaries\kickass-cruncher-plugins-2.0.jar;binaries\KickAss.jar"

rem -- main startup file (Basic Screen Fader)
del /f /s /q "bin"
java -cp %pathdef% kickass.KickAssembler viewer.asm -odir /bin

rem BUILD THE DISK!
rem SPIN COMMANDS = -v = VERBOSE, -o NAME OF FILE TO OUTPUT, -t = HEADER, -r = resident page, -b = Buffer page, -z = ZP, -e = enter point for fist loaded PRG
spin.exe -v -o "%result_disk1%" -t PHATFINGER -r 02 -b 03 -z 5 -e c000 script