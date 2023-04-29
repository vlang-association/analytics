mkdir:
	mkdir -p ./bin

build: mkdir
	v cmd/analytics-server.v -o bin/analytics-server

start: build
	./bin/analytics-server -p 8100

build-dashboard: mkdir
	v cmd/dashboard/ -o bin/analytics-dashboard

start-dashboard: build-dashboard
	./bin/analytics-dashboard -p 8102

