dev:
	docker compose -f ./docker-compose.dev.yml up --remove-orphans || make dev-down

dev-down:
	docker compose -f ./docker-compose.dev.yml down --remove-orphans

dev-update:
	docker compose -f ./docker-compose.dev.yml up --build -V --remove-orphans

dev-scale:
	docker compose -f ./docker-compose.dev.yml up --build -V  --scale immich-server=3 --remove-orphans