ifneq (,)
.error This Makefile requires GNU Make.
endif

SHELL := /bin/bash
.ONESHELL:
containers=server client

.PHONY: all arch build deploy test down clean

OSFLAG 	:=
UNAME_P := $(shell uname -p)
ifeq ($(UNAME_P),x86_64)
	OSFLAG = amd64
endif
ifneq ($(filter arm%,$(UNAME_P)),)
	OSFLAG = arm
endif

all: arch build deploy test down clean

arch:
	@echo OSARCH=$(OSFLAG) > .env

build:
	docker build -t ishenle/ubuntu:18.04-$(OSFLAG) .

deploy:
	docker-compose -p project1 up -d
	sleep 3
	docker exec gateway /ip_masq.sh
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
