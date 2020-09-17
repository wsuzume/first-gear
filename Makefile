APPNAME=ignite

APP_SOURCE=app/Dockerfile
APP_IMAGE=${APPNAME}/app:latest
APP_CONTAINER=app-server
APP_HOSTNAME=ignite

.PHONY: stop
stop:
	docker container stop `docker container ls -q`

.PHONY: clean
clean:
	docker container prune

.PHONY: app_image
app_image:
	docker image build -f ${APP_SOURCE} -t ${APP_IMAGE} ./app

.PHONY: app_shell
app_shell:
	docker container run -it --rm -p 8080:80 \
		-v ${PWD}:/go/src/github.com/ignite \
		--workdir /go/src/github.com/ignite/app \
		${APP_IMAGE}

.PHONY: serve
serve:
	docker-compose \
		-f docker-compose/reverse_proxy.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/app_server.yml \
		up -d
	sleep 5
	docker-compose -f docker-compose/maintenance.yml down

.PHONY: stop_serve
stop_serve:
	docker-compose \
		-f docker-compose-deploy.yml \
		-f docker-compose-maintenance.yml \
		-f docker-compose.yml \
		down

.PHONY: init
init:
	docker-compose -f docker-compose.yml up

.PHONY: deploy
deploy:
	docker-compose -f docker-compose-deploy.yml up

.PHONY: start_maintenance
start_maintenance:
	docker-compose -f docker-compose/maintenance.yml up -d
	sleep 15
	docker-compose -f docker-compose/app_server.yml down

.PHONY: end_maintenance
end_maintenance:
	docker-compose -f docker-compose/app_server.yml up -d
	sleep 15
	docker-compose -f docker-compose/maintenance.yml down

newcert:
	docker exec -it reverse_proxy certbot certonly --nginx --agree-tos \
		-m youremail@email.com \
		-d example.com \
		-d ignite.example.com

recert:
	docker exec -it reverse_proxy certbot renew --dry-run

local_config:
	echo "ROOTDIR=`pwd`" > .env
	docker-compose -p local \
		-f docker-compose/reverse-proxy.yml \
		-f docker-compose/app-server.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/env/local/reverse-proxy.yml \
		config
	
castor_config:
	echo "ROOTDIR=`pwd`" > .env
	docker-compose -p local \
		-f docker-compose/reverse-proxy.yml \
		-f docker-compose/app-server.yml \
		-f docker-compose/maintenance.yml \
		-f docker-compose/env/castor/reverse-proxy.yml \
		config
	
