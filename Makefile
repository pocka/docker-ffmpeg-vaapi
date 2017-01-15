.SUFFIXES:

.PHONY: container
container:
	docker build -t pocka/ffmpeg-vaapi .

