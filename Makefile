.PHONY: build test lint run dc-build dc-test dc-lint dc-up clean help

# --- Local Development Commands (Requires Ruby 4.0.0 locally) ---

local-install: ## Install gems locally
	bundle install

local-test: ## Run tests locally with coverage
	bundle exec rspec

local-lint: ## Run RuboCop linter locally
	bundle exec rubocop -A

local-run: ## Run NotifyPit locally on port 4567
	bundle exec ruby -Ilib -rnotify_pit -e "NotifyPit::App.run!(port: 4567, bind: '0.0.0.0')"

# --- Docker Commands ---

build: ## Build Docker images
	docker compose build

serve: ## Run NotifyPit in Docker
	docker compose up notifypit

test: build ## Run tests inside Docker
	docker compose run --rm test

lint: ## Run linter inside Docker
	docker compose run --rm lint

stop: ## Stop Docker containers without removing them
	docker compose stop

remove: ## Stop and remove Docker containers, networks, and images
	docker compose down --remove-orphans

# --- Utility ---

clean: remove ## Clean up local coverage, cache, and Docker resources
	rm -rf coverage .simplecov .rubocop_cache
	docker system prune -f --volumes

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'