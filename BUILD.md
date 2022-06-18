## Normally

```sh
go mod download
make docs
make test
make build
go build .
```

## Docker

```sh
docker-compose build
docker-compose up -d
docker-compose kill && docker-compose rm -f
```
