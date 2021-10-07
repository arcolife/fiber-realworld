#!/bin/sh
chmod o+w ./database 
docker-compose up
docker-compose down
rm -f ./database/realworld.db
