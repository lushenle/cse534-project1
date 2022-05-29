ifneq (,)
.error This Makefile requires GNU Make.
endif

SHELL := /bin/bash
.ONESHELL:
containers=server client

.PHONY: all build deploy test down clean

all: build deploy test down clean

build:
	docker build --no-cache -t ishenle/ubuntu:18.04 .

deploy:
	docker-compose -p project1 up -d
	sleep 3
	@for container in $(containers); do \
		docker exec $$container ip route del default; \
		if [ $$container = "server" ]; then \
			docker exec $$container ip route add default via 10.0.0.100 ; \
		else \
			docker exec $$container ip route add default via 192.168.0.100 ; \
	  	fi \
	done

test:
	@for container in $(containers); do \
    		if [ $$container = "server" ]; then \
    		  	echo "PING: From Server to Client" ; \
    			docker exec $$container ping -c 1 -w 1 192.168.0.100 ; \
    			echo "" ; \
    			docker exec $$container ping -c 1 -w 1 192.168.0.10 ; \
    			echo "" ; \
    		else \
    		  	echo "PING: From Client to Server" ; \
    			docker exec $$container ping -c 1 -w 1 10.0.0.100 ; \
    			echo "" ; \
    			docker exec $$container ping -c 1 -w 1 10.0.0.10 ; \
    	  	fi \
    	done

down:
	docker-compose -p project1 down -v

clean:
	docker rmi ishenle/ubuntu:18.04
