# Переменные
#CONTAINER_NAME = some-postgres
CONTAINER_NAME = postgres_bank

DB_NAME = simple_bank

DB_USER = postgres
DB_PASSWORD = postgres
PORT = 5432


# Запуск контейнера PostgreSQL
postgres:
	docker run --name postgres_bank --network bank-network -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -d postgres:17.4-alpine3.21
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
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/Kosench/backendBankExample/db/sqlc Store

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
           --go-grpc_out=pb --go-grpc_opt=paths=source_relative \
           --grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
           --openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
		   proto/*.proto
		   statik -src=./doc/swagger -dest=./doc
evans:
	evans --host 127.0.0.1 --port 9090 -r repl --package pb

redis:
	docker run --name redis -p 6379:6379 -d redis:7.4.2-alpine

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)
.PHONY: postgres createdb dropdb stop migrateup migratedown migrateup1 migratedown1 sqlc server db_docs db_schema proto evans redis new_migration
