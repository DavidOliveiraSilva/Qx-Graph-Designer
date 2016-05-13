all:
	rm -rf graphing.love
	zip -r graphing *
	mv graphing.zip graphing.love
	love graphing.love