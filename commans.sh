docker volume create postgres_vol_1
docker volume create postgres_vol_2
docker volume create clickhouse_vol

docker network create app_net

#POSTGRES_1
docker run --rm -d \
 --name postgres_1 \
 -e POSTGRES_PASSWORD=postgres_admin \
 -e POSTGRES_USER=postgres_admin \
 -e POSTGRES_DB=test_app \
 -v postgres_vol_1:/var/lib/postgresql/data \
 --net=app_net \
 -p 5432:5432 \
 postgres:14



#SUPERSET
docker run --rm -d --net=app_net -p 80:8088 -e "SUPERSET_SECRET_KEY=secret" --name superset apache/superset

docker exec -it superset superset fab create-admin \
              --username admin \
              --firstname Superset \
              --lastname Admin \
              --email admin@superset.com \
              --password admin

docker exec -it superset superset db upgrade
docker exec -it superset superset init

#CLICKHOISE
docker run --rm -d \
--name clickhouse \
--net=app_net \
-v clickhouse_vol:/var/lib/clickhouse \
clickhouse/clickhouse-server

#Superset-Clickhouse
docker exec superset pip install clickhouse-connect>=0.6.8
docker restart superset

#POSTGRES_2
docker run --rm -d \
 --name postgres_2 \
 -e POSTGRES_PASSWORD=postgres_some_password \
 -e POSTGRES_USER=postgres_some_user \
 -e POSTGRES_DB=app_db \
 -v postgres_vol_2:/var/lib/postgresql/data \
 --net=app_net \
 -p 5432:5432 \
 postgres:14


#REMOVE
docker stop postgres_1 postgres_2 clickhouse superset
docker volume prune