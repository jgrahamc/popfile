.PHONY: all build

all: build

build: setup.exe

setup.exe: ../engine/*.pl ../engine/Classifier/*.pm ../engine/skins/*.css ../engine/skins/*.gif
setup.exe: installer.nsi
	@../NSIS/makensis.exe /V4 $<
	@rm $@
	@mv setup2.exe $@


	