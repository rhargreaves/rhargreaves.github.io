IMAGE_NAME=blog

build:
	docker build -t $(IMAGE_NAME) .

run: build
	docker run --rm \
		-p 4000:4000 \
		-v $(shell pwd):/app \
		-it \
		$(IMAGE_NAME)

.PHONY: build run
