.PHONY: all build package

all: package

build: setup.exe
package: popfile-windows.zip

setup.exe: installer.nsi
setup.exe: ../engine/*.pl ../engine/Classifier/*.pm ../engine/skins/*.css
	@echo Making installer $@...
	@/cygdrive/c/Program\ Files/NSIS/makensis.exe /V2 installer.nsi

setup2.exe: installer2.nsi io*.ini
setup2.exe: ../engine/*.pl ../engine/Classifier/*.pm ../engine/skins/*.css
	@echo Making installer $@...
	@../NSIS/makensis.exe /V4 installer2.nsi

popfile-windows.zip: setup.exe	
	@echo Packaging release file $@...
	@gzip -S .zip -q setup.exe
	@rm -f $@
	@mv setup.exe.zip $@
	
	