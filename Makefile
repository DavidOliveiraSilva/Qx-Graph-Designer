all:
	rm -rf game.love
	zip -r game *
	mv game.zip game.love
	love game.love