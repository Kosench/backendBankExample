# Переменные
CONTAINER_NAME = some-postgres

DB_NAME = simple_bank

DB_USER = postgres
DB_PASSWORD = postgres
PORT = 5432


# Запуск контейнера PostgreSQL
postgres:
	docker run --name $(CONTAINER_NAME) -e POSTGRES_PASSWORD=$(DB_PASSWORD) -p $(PORT):5432 -d postgres

# Создание базы данных
createdb:
	docker exec -it $(CONTAINER_NAME) createdb --username=$(DB_USER) --owner=$(DB_USER) $(DB_NAME)

# Удаление базы данных
dropdb:
	docker exec -it $(CONTAINER_NAME) dropdb -U $(DB_USER) $(DB_NAME)

# Остановка и удаление контейнера
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)



migrateup:
	migrate -path db/migration -database "postgresql://postgres:postgres@127.0.0.1:5432/simple_bank?sslmode=disable" -verbose up


migratedown:
	migrate -path db/migration -database "postgresql://postgres:postgres@127.0.0.1:5432/simple_bank?sslmode=disable" -verbose down


sqlc:
	sqlc generate

test:
	go test -v -cover ./...

.PHONY: postgres createdb dropdb stop migrateup migratedown sqlc
