IMAGE='jonathanporta/docker-fedora-chromium:latest'

build: build-docker

build-docker:
	docker build -t $(IMAGE) .

run: build
	docker run -it $(IMAGE) /bin/bash
