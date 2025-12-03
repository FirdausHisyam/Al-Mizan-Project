.PHONY: up down build logs test

# Docker Compose shortcuts
up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose build

logs:
	docker-compose logs -f

# Local development shortcuts
test:
	cd backend && cargo test
