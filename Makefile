.PHONY: all setup networks pxe ks clean

NUMBER_OF_NODES = $(shell wc -l < macs.txt)

all:
	./configure.sh

setup: networks pxe ks

networks:
	./setup-networks.sh

pxe:
	NUMBER_OF_NODES=$(NUMBER_OF_NODES) ./setup-pxe.sh

ks:
	NUMBER_OF_NODES=$(NUMBER_OF_NODES) ./generate-ks.py

password:
	python3 -c 'import crypt,getpass;\
	pw=getpass.getpass();\
	print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit());\
	' | xclip

clean:
	./clean.sh
