mkdir:
	mkdir -p ./bin

build: mkdir
	v cmd/analytics-server.v -o bin/analytics-server

start: build
	./bin/analytics-server -p 8082

