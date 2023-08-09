# Language: makefile
#############################
#Setup application
#############################
build:
	-make setup

setup:
	-@echo "== Running Initial Setup =="
	-cp -n env.example .env
	-docker stop $(docker ps -a -q)
	-docker compose up -d
	-bundle install
	-make setup_db
	-@echo "== Done setting up! =="

setup_db:
	-@echo "== Setting up Database =="
	-docker compose up -d development-texting_service-db
	-cp -n db/seeds.rb.sample db/seeds.rb
	-bundle exec rails db:drop
	-bundle exec rails db:create
	-bundle exec rails db:schema:load
	-bundle exec rails db:seed
	-@echo "== Done setting up Database! =="

#############################
#Run application
#############################
up:
	-docker compose up -d
	-bundle install
	-bundle exec rails db:migrate
	-bin/dev
