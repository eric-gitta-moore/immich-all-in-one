stats:
	juicefs stats ./jfslocal

bench:
	juicefs bench ./jfslocal

install:
	curl -sSL https://d.juicefs.com/install | sh -

mount:
	docker compose up

umount:
	docker compose down && sudo juicefs umount ./jfslocal

