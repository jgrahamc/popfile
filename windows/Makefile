.PHONY: all build package

all: package

build: setup.exe
package: popfile-windows.zip

setup.exe: installer.nsi
setup.exe: ../engine/*.pl ../engine/Classifier/*.pm
	@echo Making installer $@...
	@/cygdrive/c/Program\ Files/NSIS/makensis.exe /V2 installer.nsi

popfile-windows.zip: setup.exe	
	@echo Packaging release file $@...
	@gzip -S .zip -q setup.exe
	@rm -f $@
	@mv setup.exe.zip $@
	
	