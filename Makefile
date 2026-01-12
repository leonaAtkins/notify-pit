.PHONY: build run stop test clean help

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker containers
	docker compose build

run: ## Start NotifyPit locally on port 4567
	docker compose up notifypit

stop: ## Stop all services
	docker compose down

test: ## Run the test harness inside Docker
	docker compose run --rm harness

local-test: ## Run tests locally (requires bundle install)
	bundle exec rspec spec/notify_pit_spec.rb

clean: ## Remove docker containers and volumes
	docker compose down --volumes --remove-orphans