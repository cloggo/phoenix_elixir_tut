APP_NAME=hello

REPO_NAME=$(shell echo $(APP_NAME) | awk '{for(i=1;i<=NF;i++){ $$i=toupper(substr($$i,1,1)) substr($$i,2) }}1')
IMAGE=bitwalker/alpine-elixir-phoenix:latest
CURDIR=$(shell pwd)
DOCKER_CMD=docker run --rm -v $(CURDIR):/opt/app -v $(CURDIR)/mix:/opt/mix -it $(IMAGE)
DOCKER_COMPOSE_CMD=docker-compose run --rm -T api

define ECTO_DB_CONFIG

config :$(APP_NAME), $(REPO_NAME).Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "db",
  port: "5432"
endef

export ECTO_DB_CONFIG
export APP_NAME

.PHONY: init run stop clean

init:
	$(DOCKER_CMD) mix local.hex --force
	$(DOCKER_CMD) mix archive.install --force hex phx_new
	$(DOCKER_CMD) mix phx.new --install $(APP_NAME)
	$(DOCKER_CMD) mix local.rebar --force
	sed -i '' 's|http: .*|http: [ip: {0, 0, 0, 0}, port: 4000],|g' $(APP_NAME)/config/dev.exs
	@echo "$$ECTO_DB_CONFIG" >> $(APP_NAME)/config/config.exs
	$(DOCKER_COMPOSE_CMD) sh -c "mix ecto.create"

run:
	docker-compose up -d

stop:
	docker-compose down

clean:
	$(RM) -rf $(APP_NAME) pgdata
