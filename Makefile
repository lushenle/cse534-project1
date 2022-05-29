ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: all build deploy down clean

all: build deploy down clean

build:
	docker build --no-cache -t ishenle/ubuntu:18.04 .

deploy:
	docker-compose -p project1 up -d

down:
	docker-compose -p project1 down -v
clean:
	docker rmi ishenle/ubuntu:18.04
