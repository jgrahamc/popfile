.PHONY: all build

POPFILE_WINDOWS_ZIP := popfile-$(POPFILE_VERSION)-windows.zip
BUILD_ZIP=../engine/wzzip -P $(POPFILE_WINDOWS_ZIP) -a $^

all: build
build: $(POPFILE_WINDOWS_ZIP)
$(POPFILE_WINDOWS_ZIP): setup.exe
	rm -f $@
	$(BUILD_ZIP)

setup.exe: ../engine/*.pl ../engine/Classifier/*.pm ../engine/skins/*.css ../engine/skins/*.gif
setup.exe: installer.nsi ioA.ini ioB.ini CBP.nsh
	@../NSIS/makensis.exe /V4 $<
