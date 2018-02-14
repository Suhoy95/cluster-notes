.PHONY: all setup networks pxe ks clean

NUMBER_OF_NODES = 3

all:
	./configure.sh

setup: networks pxe ks

networks:
	./setup-networks.sh

pxe:
	NUMBER_OF_NODES=$(NUMBER_OF_NODES) ./setup-pxe.sh

ks:
	NUMBER_OF_NODES=$(NUMBER_OF_NODES) ./generate-ks.py

# virtlib
start:
	true

stop:
	true

start_pxe:
	true

clean:
	./clean.sh
