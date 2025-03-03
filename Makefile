# Переменные
CONTAINER_NAME = some-postgres

DB_NAME = simple_bank

DB_USER = postgres
DB_PASSWORD = postgres
PORT = 5432


# Запуск контейнера PostgreSQL
postgres:
	docker run --name postgres --network bank-network -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -d postgres:latest
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
	migrate -path db/migration -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose up


migratedown:
	migrate -path db/migration -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose down

migrateup1:
	migrate -path db/migration -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose up 1

migratedown1:
	migrate -path db/migration -database "postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable" -verbose down 1

sqlc:
	sqlc generate


test:
	go test -v -cover ./...


server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/Kosench/backendBankExample/db/sqlc Store

.PHONY: postgres createdb dropdb stop migrateup migratedown migrateup1 migratedown1 sqlc server
