check-scripts:
	shellcheck ./*.bash

build-dist:
	mkdir bin
	zip ./bin/mrh.zip ./*.bash