web: HTTP_PORT=$PORT bin/thrust bin/rails server
release: bin/rails db:prepare && DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bin/rails db:schema:load:cache db:schema:load:queue db:schema:load:cable
