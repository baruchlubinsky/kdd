#! /usr/bin/zsh 

docker run --rm -d \
    --name kdd-db \
    -e POSTGRES_DB=kdd_dev \
    -e POSTGRES_USER=kdd_dev \
    -e POSTGRES_PASSWORD=postgres \
    --volume="type=bind,src=$PWD/.db,dst=/var/lib/postgresql/data" \
    -p 127.0.0.1:5444:5432 \
    postgres:latest